import 'package:flutter/material.dart';
import 'colores_app.dart';

/// Tema visual minimalista de la aplicación
class TemaApp {
  // Evitar instanciación
  TemaApp._();

  /// Tema claro principal
  static ThemeData get temaClaro {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: ColoresApp.primario,
        secondary: ColoresApp.secundario,
        tertiary: ColoresApp.acento,
        surface: ColoresApp.fondoTarjeta,
        error: ColoresApp.error,
      ),
      scaffoldBackgroundColor: ColoresApp.fondoClaro,

      // Tipografía minimalista
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ColoresApp.textoOscuro,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ColoresApp.textoOscuro,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoOscuro,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoOscuro,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ColoresApp.textoOscuro,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: ColoresApp.textoSecundario,
          height: 1.5,
        ),
      ),

      // Estilo de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.primario,
          foregroundColor: ColoresApp.textoClaro,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Estilo de tarjetas
      cardTheme: const CardThemeData(
        color: ColoresApp.fondoTarjeta,
        elevation: 2,
        shadowColor: ColoresApp.sombra,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.all(8),
      ),

      // AppBar minimalista
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresApp.fondoClaro,
        foregroundColor: ColoresApp.textoOscuro,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoOscuro,
        ),
      ),
    );
  }
}
