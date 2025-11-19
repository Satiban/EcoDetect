import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constantes/textos.dart';
import 'core/tema/tema_app.dart';
import 'features/analisis/data/repositorios/repositorio_analisis_impl.dart';
import 'features/analisis/data/servicios/servicio_analisis_simulado.dart';
import 'features/analisis/domain/casos_uso/analizar_imagen_caso_uso.dart';
import 'features/auth/presentation/pantallas/pantalla_login.dart';
import 'features/analisis/presentation/providers/proveedor_analisis.dart';
import 'features/insignias/data/repositorios/repositorio_insignias_impl.dart';
import 'features/insignias/data/servicios/servicio_carga_insignias.dart';
import 'features/insignias/domain/casos_uso/obtener_insignias_caso_uso.dart';
import 'features/insignias/domain/casos_uso/registrar_analisis_caso_uso.dart';
import 'features/insignias/domain/casos_uso/verificar_insignias_caso_uso.dart';
import 'features/insignias/presentation/providers/proveedor_insignias.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcoRiskApp());
}

/// Aplicación principal
class EcoRiskApp extends StatefulWidget {
  const EcoRiskApp({super.key});

  @override
  State<EcoRiskApp> createState() => _EcoRiskAppState();
}

class _EcoRiskAppState extends State<EcoRiskApp> {
  SharedPreferences? _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Error al inicializar SharedPreferences: $e');
      // En caso de error, continuar sin SharedPreferences
      _prefs = null;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: TemaApp.temaClaro,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_prefs == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: TemaApp.temaClaro,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al inicializar la aplicacion',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No se pudo inicializar el almacenamiento local',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      _initializeApp();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        // Proveedor de análisis de imágenes
        ChangeNotifierProvider(
          create: (_) => ProveedorAnalisis(
            AnalizarImagenCasoUso(
              RepositorioAnalisisImpl(
                ServicioAnalisisSimulado(),
              ),
            ),
          ),
        ),

        // Proveedor de insignias
        ChangeNotifierProvider(
          create: (_) {
            final servicioCarga = ServicioCargaInsignias();
            final repositorio = RepositorioInsigniasImpl(_prefs!, servicioCarga);
            return ProveedorInsignias(
              obtenerInsigniasCasoUso: ObtenerInsigniasCasoUso(repositorio),
              verificarInsigniasCasoUso: VerificarInsigniasCasoUso(repositorio),
              registrarAnalisisCasoUso: RegistrarAnalisisCasoUso(repositorio),
            );
          },
        ),
      ],
      child: MaterialApp(
        title: Textos.nombreApp,
        debugShowCheckedModeBanner: false,
        theme: TemaApp.temaClaro,
        home: const PantallaLogin(),
      ),
    );
  }
}
