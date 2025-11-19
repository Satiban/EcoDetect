import '../entidades/insignia.dart';
import '../repositorios/repositorio_insignias.dart';

/// Caso de uso para verificar y desbloquear insignias
class VerificarInsigniasCasoUso {
  final RepositorioInsignias _repositorio;

  VerificarInsigniasCasoUso(this._repositorio);

  /// Ejecuta la verificación de insignias y retorna las que se desbloquearon
  Future<List<Insignia>> ejecutar() async {
    return await _repositorio.verificarYDesbloquearInsignias();
  }
}
