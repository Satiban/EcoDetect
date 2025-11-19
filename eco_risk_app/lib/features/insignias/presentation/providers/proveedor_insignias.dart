import 'package:flutter/foundation.dart';
import '../../domain/entidades/insignia.dart';
import '../../domain/casos_uso/obtener_insignias_caso_uso.dart';
import '../../domain/casos_uso/verificar_insignias_caso_uso.dart';
import '../../domain/casos_uso/registrar_analisis_caso_uso.dart';
import '../../../analisis/domain/entidades/nivel_riesgo.dart';

/// Proveedor de estado para gestionar las insignias del usuario
class ProveedorInsignias extends ChangeNotifier {
  final ObtenerInsigniasCasoUso _obtenerInsigniasCasoUso;
  final VerificarInsigniasCasoUso _verificarInsigniasCasoUso;
  final RegistrarAnalisisCasoUso _registrarAnalisisCasoUso;

  List<Insignia> _insignias = [];
  bool _estaCargando = false;
  bool _inicializado = false;
  String? _mensajeError;

  ProveedorInsignias({
    required ObtenerInsigniasCasoUso obtenerInsigniasCasoUso,
    required VerificarInsigniasCasoUso verificarInsigniasCasoUso,
    required RegistrarAnalisisCasoUso registrarAnalisisCasoUso,
  })  : _obtenerInsigniasCasoUso = obtenerInsigniasCasoUso,
        _verificarInsigniasCasoUso = verificarInsigniasCasoUso,
        _registrarAnalisisCasoUso = registrarAnalisisCasoUso {
    // Cargar insignias al crear el proveedor
    cargarInsignias();
  }

  // Getters
  List<Insignia> get insignias => _insignias;
  bool get estaCargando => _estaCargando;
  String? get mensajeError => _mensajeError;
  bool get tieneError => _mensajeError != null;

  // Obtener insignias desbloqueadas
  List<Insignia> get insigniasDesbloqueadas =>
      _insignias.where((i) => i.desbloqueada).toList();

  // Obtener insignias bloqueadas
  List<Insignia> get insigniasBloqueadas =>
      _insignias.where((i) => !i.desbloqueada).toList();

  // Estadísticas
  int get totalInsignias => _insignias.length;
  int get totalDesbloqueadas => insigniasDesbloqueadas.length;
  double get porcentajeCompletado {
    if (totalInsignias == 0) return 0;
    return totalDesbloqueadas / totalInsignias;
  }

  /// Carga todas las insignias
  Future<void> cargarInsignias() async {
    if (_inicializado && !_estaCargando) return;

    try {
      _estaCargando = true;
      _mensajeError = null;
      if (_inicializado) notifyListeners();

      _insignias = await _obtenerInsigniasCasoUso.ejecutar();
      _inicializado = true;

      _estaCargando = false;
      notifyListeners();
    } catch (e) {
      _estaCargando = false;
      _inicializado = true;
      _mensajeError = 'Error al cargar insignias: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Registra un análisis y verifica si se desbloquean insignias
  /// Retorna la lista de insignias recién desbloqueadas
  Future<List<Insignia>> registrarAnalisis(NivelRiesgo nivelRiesgo) async {
    try {
      final insigniasDesbloqueadas = await _registrarAnalisisCasoUso.ejecutar(nivelRiesgo);

      // Recargar todas las insignias para actualizar la UI
      await cargarInsignias();

      return insigniasDesbloqueadas;
    } catch (e) {
      _mensajeError = 'Error al registrar análisis: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  /// Verifica y desbloquea insignias sin registrar un nuevo análisis
  Future<List<Insignia>> verificarInsignias() async {
    try {
      final insigniasDesbloqueadas = await _verificarInsigniasCasoUso.ejecutar();

      // Recargar todas las insignias para actualizar la UI
      await cargarInsignias();

      return insigniasDesbloqueadas;
    } catch (e) {
      _mensajeError = 'Error al verificar insignias: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  /// Reinicia el estado del proveedor
  void reiniciar() {
    _insignias = [];
    _estaCargando = false;
    _mensajeError = null;
    notifyListeners();
  }
}
