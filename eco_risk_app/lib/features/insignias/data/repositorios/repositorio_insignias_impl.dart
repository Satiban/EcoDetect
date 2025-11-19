import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entidades/insignia.dart';
import '../../domain/repositorios/repositorio_insignias.dart';
import '../servicios/servicio_carga_insignias.dart';

/// Implementación del repositorio de insignias usando SharedPreferences
class RepositorioInsigniasImpl implements RepositorioInsignias {
  static const String _keyInsignias = 'insignias_usuario';
  static const String _keyTotalAnalisis = 'total_analisis';
  static const String _keyAltoRiesgo = 'contador_alto_riesgo';
  static const String _keyZonasLimpias = 'contador_zonas_limpias';

  final SharedPreferences _prefs;
  final ServicioCargaInsignias _servicioCargaInsignias;

  // Cache de insignias predefinidas para evitar cargar el JSON múltiples veces
  List<Insignia>? _insigniasPredefinidas;

  RepositorioInsigniasImpl(this._prefs, this._servicioCargaInsignias);

  @override
  Future<List<Insignia>> obtenerTodasLasInsignias() async {
    // Cargar insignias predefinidas desde JSON (con cache)
    _insigniasPredefinidas ??= await _servicioCargaInsignias.cargarInsigniasDesdeAssets();

    final insigniasGuardadas = await _cargarInsigniasGuardadas();

    // Combinar insignias predefinidas con el progreso guardado
    return _insigniasPredefinidas!.map((insigniaPredefinida) {
      final insigniaGuardada = insigniasGuardadas[insigniaPredefinida.id];
      if (insigniaGuardada != null) {
        return insigniaPredefinida.copyWith(
          desbloqueada: insigniaGuardada['desbloqueada'] as bool? ?? false,
          fechaDesbloqueo: insigniaGuardada['fechaDesbloqueo'] != null
              ? DateTime.parse(insigniaGuardada['fechaDesbloqueo'] as String)
              : null,
          progreso: insigniaGuardada['progreso'] as int? ?? 0,
        );
      }
      return insigniaPredefinida;
    }).toList();
  }

  @override
  Future<Insignia?> obtenerInsigniaPorId(String id) async {
    final insignias = await obtenerTodasLasInsignias();
    try {
      return insignias.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> actualizarProgreso(String id, int nuevoProgreso) async {
    final insigniasGuardadas = await _cargarInsigniasGuardadas();

    insigniasGuardadas[id] = {
      ...?insigniasGuardadas[id],
      'progreso': nuevoProgreso,
    };

    await _guardarInsignias(insigniasGuardadas);
  }

  @override
  Future<void> desbloquearInsignia(String id) async {
    final insigniasGuardadas = await _cargarInsigniasGuardadas();

    insigniasGuardadas[id] = {
      ...?insigniasGuardadas[id],
      'desbloqueada': true,
      'fechaDesbloqueo': DateTime.now().toIso8601String(),
    };

    await _guardarInsignias(insigniasGuardadas);
  }

  @override
  Future<int> obtenerTotalAnalisis() async {
    return _prefs.getInt(_keyTotalAnalisis) ?? 0;
  }

  @override
  Future<void> incrementarContadorAnalisis() async {
    final total = await obtenerTotalAnalisis();
    await _prefs.setInt(_keyTotalAnalisis, total + 1);
  }

  @override
  Future<void> incrementarContadorAltoRiesgo() async {
    final total = _prefs.getInt(_keyAltoRiesgo) ?? 0;
    await _prefs.setInt(_keyAltoRiesgo, total + 1);
  }

  @override
  Future<void> incrementarContadorZonasLimpias() async {
    final total = _prefs.getInt(_keyZonasLimpias) ?? 0;
    await _prefs.setInt(_keyZonasLimpias, total + 1);
  }

  @override
  Future<List<Insignia>> verificarYDesbloquearInsignias() async {
    final insignias = await obtenerTodasLasInsignias();
    final totalAnalisis = await obtenerTotalAnalisis();
    final contadorAltoRiesgo = _prefs.getInt(_keyAltoRiesgo) ?? 0;
    final contadorZonasLimpias = _prefs.getInt(_keyZonasLimpias) ?? 0;

    final insigniasDesbloqueadas = <Insignia>[];

    for (final insignia in insignias) {
      if (insignia.desbloqueada) continue;

      int progresoActual = 0;

      // Calcular progreso según el tipo de insignia
      switch (insignia.tipo) {
        case TipoInsignia.primerAnalisis:
        case TipoInsignia.analisis5:
        case TipoInsignia.analisis10:
        case TipoInsignia.analisis25:
        case TipoInsignia.analisis50:
          progresoActual = totalAnalisis;
          break;
        case TipoInsignia.detectorExperto:
          progresoActual = contadorAltoRiesgo;
          break;
        case TipoInsignia.guardianVerde:
          progresoActual = contadorZonasLimpias;
          break;
        case TipoInsignia.cazadorPlasticos:
        case TipoInsignia.defensorAgua:
        case TipoInsignia.protectorAire:
          // Estas insignias requieren lógica adicional basada en el tipo de contaminación
          // Por ahora se dejan con progreso 0 (se pueden implementar más adelante)
          progresoActual = 0;
          break;
      }

      // Actualizar progreso
      await actualizarProgreso(insignia.id, progresoActual);

      // Verificar si se puede desbloquear
      if (progresoActual >= insignia.metaProgreso) {
        await desbloquearInsignia(insignia.id);
        final insigniaActualizada = insignia.copyWith(
          desbloqueada: true,
          fechaDesbloqueo: DateTime.now(),
          progreso: progresoActual,
        );
        insigniasDesbloqueadas.add(insigniaActualizada);
      }
    }

    return insigniasDesbloqueadas;
  }

  // Métodos privados de ayuda

  Future<Map<String, Map<String, dynamic>>> _cargarInsigniasGuardadas() async {
    final jsonString = _prefs.getString(_keyInsignias);
    if (jsonString == null) return {};

    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      return decoded.map((key, value) => MapEntry(
        key,
        Map<String, dynamic>.from(value as Map),
      ));
    } catch (_) {
      return {};
    }
  }

  Future<void> _guardarInsignias(Map<String, Map<String, dynamic>> insignias) async {
    final jsonString = json.encode(insignias);
    await _prefs.setString(_keyInsignias, jsonString);
  }
}
