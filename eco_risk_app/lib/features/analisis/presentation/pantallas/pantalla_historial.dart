import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/tema/colores_app.dart';
import '../../../../core/database/servicio_historial.dart';
import '../../domain/entidades/historial_analisis.dart';
import '../../domain/entidades/nivel_riesgo.dart';

/// Pantalla minimalista para mostrar el historial
class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({super.key});

  @override
  State<PantallaHistorial> createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> {
  ServicioHistorial? _servicio;
  List<HistorialAnalisis> _historial = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final prefs = await SharedPreferences.getInstance();
    _servicio = ServicioHistorial(prefs);
    await _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    if (_servicio == null) return;

    setState(() => _isLoading = true);
    try {
      final historial = await _servicio!.obtenerHistorial();
      if (mounted) {
        setState(() {
          _historial = historial;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _eliminarAnalisis(int index) async {
    await _servicio?.eliminarAnalisis(index);
    await _cargarHistorial();
  }

  Future<void> _limpiarTodo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text('¿Eliminar todo el historial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _servicio?.limpiarHistorial();
      await _cargarHistorial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ColoresApp.textoOscuro,
        elevation: 0,
        title: const Text('Historial', style: TextStyle(fontWeight: FontWeight.w300)),
        actions: [
          if (_historial.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _limpiarTodo,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historial.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Sin análisis',
                        style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _historial.length,
                  itemBuilder: (context, index) {
                    return _buildItem(_historial[index], index);
                  },
                ),
    );
  }

  Widget _buildItem(HistorialAnalisis item, int index) {
    final formatter = DateFormat('dd/MM/yy HH:mm');
    final color = _getColor(item.nivelRiesgo);

    return Dismissible(
      key: Key('${item.fechaAnalisis.toIso8601String()}$index'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _eliminarAnalisis(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Imagen miniatura
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              child: File(item.rutaImagen).existsSync()
                  ? Image.file(
                      File(item.rutaImagen),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),

            // Información
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tipoContaminacion,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(item.fechaAnalisis),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            // Nivel de riesgo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${item.indiceRiesgo.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(NivelRiesgo nivel) {
    switch (nivel) {
      case NivelRiesgo.bajo:
        return ColoresApp.riesgoBajo;
      case NivelRiesgo.medio:
        return ColoresApp.riesgoMedio;
      case NivelRiesgo.alto:
        return ColoresApp.riesgoAlto;
      case NivelRiesgo.muyAlto:
        return ColoresApp.riesgoMuyAlto;
    }
  }
}
