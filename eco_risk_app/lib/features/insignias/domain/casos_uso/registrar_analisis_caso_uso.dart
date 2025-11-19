import '../../../analisis/domain/entidades/nivel_riesgo.dart';
import '../entidades/insignia.dart';
import '../repositorios/repositorio_insignias.dart';

/// Caso de uso para registrar un análisis y actualizar contadores de insignias
class RegistrarAnalisisCasoUso {
  final RepositorioInsignias _repositorio;

  RegistrarAnalisisCasoUso(this._repositorio);

  /// Registra un análisis y retorna las insignias desbloqueadas
  Future<List<Insignia>> ejecutar(NivelRiesgo nivelRiesgo) async {
    // Incrementar contador general de análisis
    await _repositorio.incrementarContadorAnalisis();

    // Incrementar contadores específicos según el nivel de riesgo
    switch (nivelRiesgo) {
      case NivelRiesgo.alto:
      case NivelRiesgo.muyAlto:
        await _repositorio.incrementarContadorAltoRiesgo();
        break;
      case NivelRiesgo.bajo:
        await _repositorio.incrementarContadorZonasLimpias();
        break;
      case NivelRiesgo.medio:
        // No hay contador específico para riesgo medio
        break;
    }

    // Verificar y desbloquear insignias
    return await _repositorio.verificarYDesbloquearInsignias();
  }
}
