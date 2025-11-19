import '../../domain/entidades/resultado_analisis.dart';
import '../../domain/repositorios/repositorio_analisis.dart';
import '../servicios/servicio_analisis_simulado.dart';

/// Implementación concreta del repositorio de análisis
///
/// Esta implementación usa el servicio simulado, pero puedes
/// crear otras implementaciones para:
/// - Análisis con IA local (TensorFlow Lite)
/// - Análisis remoto (API REST)
/// - Análisis híbrido (local + remoto)
/// - Análisis offline con caché
///
/// 🔌 PUNTO DE INTEGRACIÓN: Para conectar un backend real:
/// 1. Crea una nueva clase RepositorioAnalisisRemoto
/// 2. Implementa la interfaz RepositorioAnalisis
/// 3. Reemplaza la inyección en main.dart o tu DI container
class RepositorioAnalisisImpl implements RepositorioAnalisis {
  final ServicioAnalisisSimulado _servicio;

  RepositorioAnalisisImpl(this._servicio);

  @override
  Future<ResultadoAnalisis> analizarImagen(String rutaImagen) async {
    try {
      // Llamar al servicio de análisis (actualmente simulado)
      final indiceRiesgo = await _servicio.analizarImagen(rutaImagen);

      // Crear el resultado usando el factory que calcula automáticamente
      // el nivel de riesgo y la recomendación
      final resultado = ResultadoAnalisis.desdeIndice(
        indice: indiceRiesgo,
        metadatos: {
          'ruta_imagen': rutaImagen,
          'version_analisis': '1.0.0-simulado',
        },
      );

      return resultado;
    } catch (e) {
      // Propagar el error con contexto adicional
      throw Exception('Error al analizar la imagen: ${e.toString()}');
    }
  }
}
