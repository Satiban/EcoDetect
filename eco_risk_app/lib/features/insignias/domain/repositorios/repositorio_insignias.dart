import '../entidades/insignia.dart';

/// Repositorio abstracto para gestionar las insignias
abstract class RepositorioInsignias {
  /// Obtiene todas las insignias del usuario
  Future<List<Insignia>> obtenerTodasLasInsignias();

  /// Obtiene una insignia específica por su ID
  Future<Insignia?> obtenerInsigniaPorId(String id);

  /// Actualiza el progreso de una insignia
  Future<void> actualizarProgreso(String id, int nuevoProgreso);

  /// Desbloquea una insignia
  Future<void> desbloquearInsignia(String id);

  /// Obtiene el número total de análisis realizados
  Future<int> obtenerTotalAnalisis();

  /// Incrementa el contador de análisis totales
  Future<void> incrementarContadorAnalisis();

  /// Incrementa el contador de detección de alto riesgo
  Future<void> incrementarContadorAltoRiesgo();

  /// Incrementa el contador de zonas limpias
  Future<void> incrementarContadorZonasLimpias();

  /// Verifica qué insignias pueden desbloquearse y las desbloquea
  Future<List<Insignia>> verificarYDesbloquearInsignias();
}
