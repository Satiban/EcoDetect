import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constantes/textos.dart';
import '../../../../core/database/servicio_historial.dart';
import '../../../../shared/widgets/cargando_widget.dart';
import '../../../insignias/data/servicios/servicio_notificaciones_insignias.dart';
import '../../../insignias/presentation/providers/proveedor_insignias.dart';
import '../../domain/entidades/historial_analisis.dart';
import '../../domain/entidades/resultado_analisis.dart';
import '../providers/proveedor_analisis.dart';
import '../widgets/boton_accion_principal.dart';
import '../widgets/tarjeta_indice_riesgo.dart';
import 'pantalla_insignias_export.dart';

/// Pantalla que muestra el resultado del análisis
class PantallaResultado extends StatefulWidget {
  const PantallaResultado({super.key});

  @override
  State<PantallaResultado> createState() => _PantallaResultadoState();
}

class _PantallaResultadoState extends State<PantallaResultado> {
  bool _insigniasRegistradas = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registrarInsignias();
      _guardarEnHistorial();
    });
  }

  Future<void> _guardarEnHistorial() async {
    final proveedorAnalisis = context.read<ProveedorAnalisis>();

    if (proveedorAnalisis.tieneResultado && proveedorAnalisis.rutaImagenActual != null) {
      final resultado = proveedorAnalisis.resultado!;
      final rutaImagen = proveedorAnalisis.rutaImagenActual!;

      final historial = HistorialAnalisis(
        rutaImagen: rutaImagen,
        indiceRiesgo: resultado.indiceRiesgo,
        nivelRiesgo: resultado.nivelRiesgo,
        tipoContaminacion: resultado.tipoContaminacion,
        fechaAnalisis: resultado.fechaAnalisis,
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        final servicio = ServicioHistorial(prefs);
        await servicio.guardarAnalisis(historial);
      } catch (e) {
        debugPrint('Error al guardar en historial: $e');
      }
    }
  }

  Future<void> _registrarInsignias() async {
    if (_insigniasRegistradas) return;

    final proveedorAnalisis = context.read<ProveedorAnalisis>();
    final proveedorInsignias = context.read<ProveedorInsignias>();

    if (proveedorAnalisis.tieneResultado) {
      final resultado = proveedorAnalisis.resultado!;

      // Registrar el análisis y verificar insignias
      final insigniasDesbloqueadas = await proveedorInsignias.registrarAnalisis(
        resultado.nivelRiesgo,
      );

      // Mostrar notificaciones de insignias desbloqueadas
      if (mounted && insigniasDesbloqueadas.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          ServicioNotificacionesInsignias.mostrarNotificacionesInsignias(
            context,
            insigniasDesbloqueadas,
          );
        }
      }

      _insigniasRegistradas = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Textos.tituloResultado),
        automaticallyImplyLeading: false,
        actions: [
          // Botón para ver insignias
          IconButton(
            icon: const Icon(Icons.military_tech),
            tooltip: 'Mis Insignias',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PantallaInsignias(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProveedorAnalisis>(
        builder: (context, proveedor, child) {
          // Estado de carga
          if (proveedor.estaAnalizando) {
            return const CargandoWidget(
              mensaje: Textos.analizando,
            );
          }

          // Estado de error
          if (proveedor.tieneError) {
            return _VistaError(
              mensaje: proveedor.mensajeError ?? Textos.errorAnalisis,
            );
          }

          // Estado de resultado exitoso
          if (proveedor.tieneResultado) {
            return _VistaResultado(
              proveedor: proveedor,
            );
          }

          // Estado inicial (no debería ocurrir en esta pantalla)
          return const Center(
            child: Text('No hay datos disponibles'),
          );
        },
      ),
    );
  }
}

/// Vista del resultado exitoso
class _VistaResultado extends StatelessWidget {
  final ProveedorAnalisis proveedor;

  const _VistaResultado({required this.proveedor});

  @override
  Widget build(BuildContext context) {
    final resultado = proveedor.resultado!;
    final rutaImagen = proveedor.rutaImagenActual;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen analizada
          if (rutaImagen != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(rutaImagen),
                height: 250,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 24),

          // Tarjeta con el índice de riesgo
          TarjetaIndiceRiesgo(resultado: resultado),

          const SizedBox(height: 24),

          // Información adicional
          _SeccionInformacion(resultado: resultado),

          const SizedBox(height: 32),

          // Botón para nuevo análisis
          BotonAccionPrincipal(
            texto: Textos.botonNuevoAnalisis,
            icono: Icons.refresh,
            onPresionado: () {
              proveedor.reiniciar();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}

/// Sección con información adicional del análisis
class _SeccionInformacion extends StatelessWidget {
  final ResultadoAnalisis resultado;

  const _SeccionInformacion({required this.resultado});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ItemInformacion(
              icono: Icons.access_time,
              titulo: 'Fecha de análisis',
              valor: _formatearFecha(resultado.fechaAnalisis),
            ),
            const Divider(height: 24),
            _ItemInformacion(
              icono: Icons.analytics,
              titulo: 'Versión del análisis',
              valor: resultado.metadatos?['version_analisis'] ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}

/// Item de información individual
class _ItemInformacion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _ItemInformacion({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Vista de error
class _VistaError extends StatelessWidget {
  final String mensaje;

  const _VistaError({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Error en el análisis',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
