import 'package:flutter/foundation.dart';
import '../../domain/casos_uso/analizar_imagen_caso_uso.dart';
import '../../domain/entidades/resultado_analisis.dart';

/// Estados posibles del análisis
enum EstadoAnalisis {
  inicial,
  analizando,
  completado,
  error,
}

/// Provider para gestionar el estado del análisis de imágenes
///
/// Usa ChangeNotifier para notificar a los widgets cuando hay cambios
class ProveedorAnalisis extends ChangeNotifier {
  final AnalizarImagenCasoUso _analizarImagenCasoUso;

  ProveedorAnalisis(this._analizarImagenCasoUso);

  // Estado
  EstadoAnalisis _estado = EstadoAnalisis.inicial;
  ResultadoAnalisis? _resultado;
  String? _rutaImagenActual;
  String? _mensajeError;

  // Getters
  EstadoAnalisis get estado => _estado;
  ResultadoAnalisis? get resultado => _resultado;
  String? get rutaImagenActual => _rutaImagenActual;
  String? get mensajeError => _mensajeError;

  bool get estaAnalizando => _estado == EstadoAnalisis.analizando;
  bool get tieneResultado => _estado == EstadoAnalisis.completado && _resultado != null;
  bool get tieneError => _estado == EstadoAnalisis.error;

  /// Analiza una imagen
  Future<void> analizarImagen(String rutaImagen) async {
    _estado = EstadoAnalisis.analizando;
    _rutaImagenActual = rutaImagen;
    _mensajeError = null;
    _resultado = null;
    notifyListeners();

    try {
      // Ejecutar el caso de uso
      final resultado = await _analizarImagenCasoUso.ejecutar(rutaImagen);

      _resultado = resultado;
      _estado = EstadoAnalisis.completado;
      _mensajeError = null;
    } catch (e) {
      _estado = EstadoAnalisis.error;
      _mensajeError = e.toString();
      _resultado = null;
    } finally {
      notifyListeners();
    }
  }

  /// Reinicia el estado para un nuevo análisis
  void reiniciar() {
    _estado = EstadoAnalisis.inicial;
    _resultado = null;
    _rutaImagenActual = null;
    _mensajeError = null;
    notifyListeners();
  }
}
