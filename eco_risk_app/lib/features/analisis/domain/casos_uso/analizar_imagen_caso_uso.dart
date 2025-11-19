import '../entidades/resultado_analisis.dart';
import '../repositorios/repositorio_analisis.dart';

/// Caso de uso: Analizar imagen para detectar contaminación
///
/// Este caso de uso encapsula la lógica de negocio principal:
/// 1. Validar la imagen
/// 2. Delegar el análisis al repositorio
/// 3. Procesar y retornar el resultado
///
/// Ventajas:
/// - Lógica de negocio desacoplada de la UI
/// - Fácil de testear unitariamente
/// - Reutilizable en diferentes partes de la app
class AnalizarImagenCasoUso {
  final RepositorioAnalisis _repositorio;

  AnalizarImagenCasoUso(this._repositorio);

  /// Ejecuta el análisis de la imagen
  ///
  /// [rutaImagen] - Ruta local de la imagen a analizar
  ///
  /// Retorna un [ResultadoAnalisis] con el índice de riesgo,
  /// nivel categorizado y recomendaciones.
  ///
  /// Lanza [ArgumentError] si la ruta está vacía
  /// Lanza [Exception] si el análisis falla
  Future<ResultadoAnalisis> ejecutar(String rutaImagen) async {
    // Validación básica
    if (rutaImagen.isEmpty) {
      throw ArgumentError('La ruta de la imagen no puede estar vacía');
    }

    // Delegar al repositorio (puede ser implementación simulada o real)
    try {
      final resultado = await _repositorio.analizarImagen(rutaImagen);
      return resultado;
    } catch (e) {
      // Aquí podrías agregar logging, métricas, etc.
      rethrow;
    }
  }
}
