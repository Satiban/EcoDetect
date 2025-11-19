import 'nivel_riesgo.dart';

/// Entidad que representa un registro de análisis en el historial
class HistorialAnalisis {
  final String rutaImagen;
  final double indiceRiesgo;
  final NivelRiesgo nivelRiesgo;
  final String tipoContaminacion;
  final DateTime fechaAnalisis;

  const HistorialAnalisis({
    required this.rutaImagen,
    required this.indiceRiesgo,
    required this.nivelRiesgo,
    required this.tipoContaminacion,
    required this.fechaAnalisis,
  });

  /// Convierte la entidad a un mapa para guardar
  Map<String, dynamic> toMap() {
    return {
      'rutaImagen': rutaImagen,
      'indiceRiesgo': indiceRiesgo,
      'nivelRiesgo': nivelRiesgo.index,
      'tipoContaminacion': tipoContaminacion,
      'fechaAnalisis': fechaAnalisis.toIso8601String(),
    };
  }

  /// Crea una entidad desde un mapa
  factory HistorialAnalisis.fromMap(Map<String, dynamic> map) {
    return HistorialAnalisis(
      rutaImagen: map['rutaImagen'] as String,
      indiceRiesgo: (map['indiceRiesgo'] as num).toDouble(),
      nivelRiesgo: NivelRiesgo.values[map['nivelRiesgo'] as int],
      tipoContaminacion: map['tipoContaminacion'] as String,
      fechaAnalisis: DateTime.parse(map['fechaAnalisis'] as String),
    );
  }
}
