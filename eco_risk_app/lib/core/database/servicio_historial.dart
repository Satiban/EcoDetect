import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/analisis/domain/entidades/historial_analisis.dart';

/// Servicio simple para gestionar el historial usando SharedPreferences
class ServicioHistorial {
  static const String _keyHistorial = 'historial_analisis';
  final SharedPreferences _prefs;

  ServicioHistorial(this._prefs);

  /// Guarda un análisis en el historial
  Future<void> guardarAnalisis(HistorialAnalisis analisis) async {
    final historial = await obtenerHistorial();
    historial.insert(0, analisis); // Insertar al inicio

    // Limitar a 50 análisis máximo
    if (historial.length > 50) {
      historial.removeRange(50, historial.length);
    }

    await _guardarHistorial(historial);
  }

  /// Obtiene todo el historial
  Future<List<HistorialAnalisis>> obtenerHistorial() async {
    final jsonString = _prefs.getString(_keyHistorial);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => HistorialAnalisis.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Elimina un análisis del historial
  Future<void> eliminarAnalisis(int index) async {
    final historial = await obtenerHistorial();
    if (index >= 0 && index < historial.length) {
      historial.removeAt(index);
      await _guardarHistorial(historial);
    }
  }

  /// Limpia todo el historial
  Future<void> limpiarHistorial() async {
    await _prefs.remove(_keyHistorial);
  }

  /// Guarda el historial en SharedPreferences
  Future<void> _guardarHistorial(List<HistorialAnalisis> historial) async {
    final jsonList = historial.map((h) => h.toMap()).toList();
    final jsonString = json.encode(jsonList);
    await _prefs.setString(_keyHistorial, jsonString);
  }
}
