import '../entidades/insignia.dart';
import '../repositorios/repositorio_insignias.dart';

/// Caso de uso para obtener todas las insignias del usuario
class ObtenerInsigniasCasoUso {
  final RepositorioInsignias _repositorio;

  ObtenerInsigniasCasoUso(this._repositorio);

  /// Ejecuta la obtención de todas las insignias
  Future<List<Insignia>> ejecutar() async {
    return await _repositorio.obtenerTodasLasInsignias();
  }
}
