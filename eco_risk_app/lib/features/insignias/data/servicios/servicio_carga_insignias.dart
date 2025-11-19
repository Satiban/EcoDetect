import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entidades/insignia.dart';

/// Servicio para cargar las insignias desde JSON
/// Este servicio puede adaptarse para cargar desde una API en el futuro
class ServicioCargaInsignias {
  /// Carga las insignias desde un archivo JSON en assets
  /// En el futuro, este método puede modificarse para cargar desde una API
  Future<List<Insignia>> cargarInsigniasDesdeAssets() async {
    try {
      // Cargar el archivo JSON desde assets
      final String jsonString = await rootBundle.loadString('assets/insignias.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Extraer la lista de insignias del JSON
      final List<dynamic> insigniasJson = jsonData['insignias'] as List<dynamic>;

      // Convertir cada item JSON a una entidad Insignia
      return insigniasJson.map((json) => _insigniaDesdeJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // En caso de error, retornar lista vacía
      // En producción, esto debería manejarse mejor
      debugPrint('Error al cargar insignias desde assets: $e');
      return [];
    }
  }

  /// Método para cargar insignias desde una API
  /// Este método está preparado para integrarse con un backend en el futuro
  ///
  /// Ejemplo de uso futuro:
  /// ```dart
  /// final insignias = await servicioCargaInsignias.cargarInsigniasDesdeAPI(
  ///   'https://api.ecorisk.com/insignias',
  ///   headers: {'Authorization': 'Bearer token'}
  /// );
  /// ```
  Future<List<Insignia>> cargarInsigniasDesdeAPI(String url, {Map<String, String>? headers}) async {
    // TODO: Implementar cuando se tenga la API disponible
    // final response = await http.get(Uri.parse(url), headers: headers);
    // if (response.statusCode == 200) {
    //   final Map<String, dynamic> jsonData = json.decode(response.body);
    //   final List<dynamic> insigniasJson = jsonData['insignias'] as List<dynamic>;
    //   return insigniasJson.map((json) => _insigniaDesdeJson(json as Map<String, dynamic>)).toList();
    // }
    throw UnimplementedError('La carga desde API aún no está implementada');
  }

  /// Convierte un mapa JSON a una entidad Insignia
  Insignia _insigniaDesdeJson(Map<String, dynamic> json) {
    return Insignia(
      id: json['id'] as String,
      tipo: _tipoInsigniaDesdeString(json['tipo'] as String),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      icono: _iconoDesdeString(json['icono'] as String),
      color: _colorDesdeHex(json['color'] as String),
      metaProgreso: json['metaProgreso'] as int,
      desbloqueada: false,
      progreso: 0,
    );
  }

  /// Convierte un string a un TipoInsignia
  TipoInsignia _tipoInsigniaDesdeString(String tipo) {
    switch (tipo) {
      case 'primerAnalisis':
        return TipoInsignia.primerAnalisis;
      case 'analisis5':
        return TipoInsignia.analisis5;
      case 'analisis10':
        return TipoInsignia.analisis10;
      case 'analisis25':
        return TipoInsignia.analisis25;
      case 'analisis50':
        return TipoInsignia.analisis50;
      case 'detectorExperto':
        return TipoInsignia.detectorExperto;
      case 'guardianVerde':
        return TipoInsignia.guardianVerde;
      case 'cazadorPlasticos':
        return TipoInsignia.cazadorPlasticos;
      case 'defensorAgua':
        return TipoInsignia.defensorAgua;
      case 'protectorAire':
        return TipoInsignia.protectorAire;
      default:
        return TipoInsignia.primerAnalisis;
    }
  }

  /// Convierte un string de nombre de icono a IconData
  IconData _iconoDesdeString(String nombreIcono) {
    switch (nombreIcono) {
      case 'eco_outlined':
        return Icons.eco_outlined;
      case 'explore':
        return Icons.explore;
      case 'science':
        return Icons.science;
      case 'psychology':
        return Icons.psychology;
      case 'military_tech':
        return Icons.military_tech;
      case 'warning_amber':
        return Icons.warning_amber;
      case 'park':
        return Icons.park;
      case 'delete_outline':
        return Icons.delete_outline;
      case 'water_drop':
        return Icons.water_drop;
      case 'air':
        return Icons.air;
      default:
        return Icons.eco;
    }
  }

  /// Convierte un string hexadecimal a Color
  Color _colorDesdeHex(String hex) {
    // Remover el # si existe
    final String hexColor = hex.replaceAll('#', '');
    // Convertir a int y crear el Color
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}
