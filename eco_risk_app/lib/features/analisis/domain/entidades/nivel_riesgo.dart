/// Enumeración que representa los niveles de riesgo ambiental
enum NivelRiesgo {
  bajo,
  medio,
  alto,
  muyAlto;

  /// Obtiene el texto legible del nivel de riesgo
  String get texto {
    switch (this) {
      case NivelRiesgo.bajo:
        return 'Bajo';
      case NivelRiesgo.medio:
        return 'Medio';
      case NivelRiesgo.alto:
        return 'Alto';
      case NivelRiesgo.muyAlto:
        return 'Muy Alto';
    }
  }

  /// Determina el nivel de riesgo según un índice numérico (0-100)
  static NivelRiesgo desdeIndice(double indice) {
    if (indice < 30) {
      return NivelRiesgo.bajo;
    } else if (indice < 60) {
      return NivelRiesgo.medio;
    } else if (indice < 85) {
      return NivelRiesgo.alto;
    } else {
      return NivelRiesgo.muyAlto;
    }
  }
}
