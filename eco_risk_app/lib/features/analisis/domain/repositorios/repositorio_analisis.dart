import '../entidades/resultado_analisis.dart';

/// Interfaz (puerto) del repositorio de análisis
///
/// Esta abstracción permite cambiar la implementación sin afectar
/// la lógica de negocio. Puedes implementar versiones que:
/// - Usen un modelo de IA local
/// - Llamen a un microservicio REST
/// - Usen un servicio cloud (AWS Rekognition, Google Vision, etc.)
/// - Combinen múltiples fuentes
///
/// 🔌 PUNTO DE INTEGRACIÓN: Implementa esta interfaz para conectar
/// tu backend real de IA o cualquier servicio externo.
abstract class RepositorioAnalisis {
  /// Analiza una imagen y devuelve el resultado del análisis
  ///
  /// [rutaImagen] - Ruta local de la imagen a analizar
  ///
  /// Retorna un [ResultadoAnalisis] con el índice de riesgo y recomendaciones
  ///
  /// Puede lanzar excepciones si:
  /// - La imagen no existe o no se puede leer
  /// - El servicio de análisis falla
  /// - Hay problemas de conectividad (en caso de servicios remotos)
  Future<ResultadoAnalisis> analizarImagen(String rutaImagen);
}
