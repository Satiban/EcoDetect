import 'nivel_riesgo.dart';

/// Entidad que representa el resultado del análisis de contaminación
class ResultadoAnalisis {
  /// Índice numérico de riesgo (0-100)
  final double indiceRiesgo;

  /// Nivel de riesgo categorizado
  final NivelRiesgo nivelRiesgo;

  /// Recomendación textual basada en el análisis
  final String recomendacion;

  /// Tipo de contaminación detectada
  final String tipoContaminacion;

  /// Timestamp del análisis
  final DateTime fechaAnalisis;

  /// Datos adicionales del análisis (opcional, para futuras extensiones)
  final Map<String, dynamic>? metadatos;

  ResultadoAnalisis({
    required this.indiceRiesgo,
    required this.nivelRiesgo,
    required this.recomendacion,
    required this.tipoContaminacion,
    required this.fechaAnalisis,
    this.metadatos,
  });

  /// Constructor de fábrica que calcula automáticamente el nivel y recomendación
  factory ResultadoAnalisis.desdeIndice({
    required double indice,
    String? tipoContaminacion,
    Map<String, dynamic>? metadatos,
  }) {
    final nivel = NivelRiesgo.desdeIndice(indice);
    final recomendacion = _obtenerRecomendacion(nivel);
    final tipo = tipoContaminacion ?? _obtenerTipoContaminacion(nivel);

    return ResultadoAnalisis(
      indiceRiesgo: indice,
      nivelRiesgo: nivel,
      recomendacion: recomendacion,
      tipoContaminacion: tipo,
      fechaAnalisis: DateTime.now(),
      metadatos: metadatos,
    );
  }

  /// Obtiene el tipo de contaminación según el nivel de riesgo
  static String _obtenerTipoContaminacion(NivelRiesgo nivel) {
    switch (nivel) {
      case NivelRiesgo.bajo:
        return 'Contaminación leve o nula';
      case NivelRiesgo.medio:
        return 'Contaminación moderada';
      case NivelRiesgo.alto:
        return 'Contaminación alta';
      case NivelRiesgo.muyAlto:
        return 'Contaminación crítica';
    }
  }

  /// Obtiene la recomendación textual según el nivel de riesgo
  static String _obtenerRecomendacion(NivelRiesgo nivel) {
    switch (nivel) {
      case NivelRiesgo.bajo:
        return 'El nivel de contaminación detectado es bajo. El área presenta condiciones ambientales aceptables.';
      case NivelRiesgo.medio:
        return 'Se detectó un nivel moderado de contaminación. Se recomienda monitorear el área y tomar medidas preventivas.';
      case NivelRiesgo.alto:
        return 'Alerta: Se detectó un nivel alto de contaminación. Se recomienda evitar el área y reportar a las autoridades ambientales.';
      case NivelRiesgo.muyAlto:
        return 'PELIGRO: Nivel crítico de contaminación detectado. Evacue el área inmediatamente y contacte a las autoridades ambientales.';
    }
  }

  /// Copia la entidad con campos modificados
  ResultadoAnalisis copyWith({
    double? indiceRiesgo,
    NivelRiesgo? nivelRiesgo,
    String? recomendacion,
    String? tipoContaminacion,
    DateTime? fechaAnalisis,
    Map<String, dynamic>? metadatos,
  }) {
    return ResultadoAnalisis(
      indiceRiesgo: indiceRiesgo ?? this.indiceRiesgo,
      nivelRiesgo: nivelRiesgo ?? this.nivelRiesgo,
      recomendacion: recomendacion ?? this.recomendacion,
      tipoContaminacion: tipoContaminacion ?? this.tipoContaminacion,
      fechaAnalisis: fechaAnalisis ?? this.fechaAnalisis,
      metadatos: metadatos ?? this.metadatos,
    );
  }
}
