import 'package:flutter/material.dart';

/// Paleta de colores con esquema azul y verde
class ColoresApp {
  // Evitar instanciación
  ColoresApp._();

  // Colores principales - Azul
  static const Color primario = Color(0xFF1976D2); // Azul principal
  static const Color primarioOscuro = Color(0xFF0D47A1); // Azul oscuro
  static const Color primarioClaro = Color(0xFF42A5F5); // Azul claro

  // Colores secundarios - Verde
  static const Color secundario = Color(0xFF388E3C); // Verde
  static const Color secundarioOscuro = Color(0xFF1B5E20); // Verde oscuro
  static const Color secundarioClaro = Color(0xFF66BB6A); // Verde claro

  // Color de acento
  static const Color acento = Color(0xFF00BCD4); // Cyan
  static const Color acentoOscuro = Color(0xFF00838F); // Cyan oscuro

  // Colores de fondo
  static const Color fondoClaro = Color(0xFFF5F7FA); // Gris azulado muy claro
  static const Color fondoMedio = Color(0xFFE3F2FD); // Azul muy claro
  static const Color fondoTarjeta = Color(0xFFFFFFFF); // Blanco
  static const Color fondoOscuro = Color(0xFF1A237E); // Azul oscuro

  // Colores de texto
  static const Color textoOscuro = Color(0xFF1A237E); // Azul muy oscuro
  static const Color textoSecundario = Color(0xFF546E7A); // Gris azulado
  static const Color textoClaro = Color(0xFFFFFFFF); // Blanco
  static const Color textoMedio = Color(0xFF607D8B); // Gris azul medio

  // Colores de estado - Niveles de riesgo
  static const Color riesgoBajo = Color(0xFF4CAF50); // Verde
  static const Color riesgoBajoClaro = Color(0xFF81C784); // Verde claro
  static const Color riesgoMedio = Color(0xFFFFA726); // Naranja
  static const Color riesgoMedioClaro = Color(0xFFFFB74D); // Naranja claro
  static const Color riesgoAlto = Color(0xFFFF7043); // Naranja rojizo
  static const Color riesgoAltoClaro = Color(0xFFFF8A65); // Naranja rojizo claro
  static const Color riesgoMuyAlto = Color(0xFFE53935); // Rojo
  static const Color riesgoMuyAltoClaro = Color(0xFFEF5350); // Rojo claro

  // Colores funcionales
  static const Color exito = Color(0xFF4CAF50); // Verde
  static const Color advertencia = Color(0xFFFFA726); // Naranja
  static const Color error = Color(0xFFE53935); // Rojo
  static const Color informacion = Color(0xFF42A5F5); // Azul

  // Gradientes predefinidos
  static const List<Color> gradientePrimario = [
    Color(0xFF1976D2), // Azul
    Color(0xFF42A5F5), // Azul claro
  ];

  static const List<Color> gradienteSecundario = [
    Color(0xFF388E3C), // Verde
    Color(0xFF66BB6A), // Verde claro
  ];

  static const List<Color> gradienteAzulVerde = [
    Color(0xFF1976D2), // Azul
    Color(0xFF388E3C), // Verde
  ];

  static const List<Color> gradienteExito = [
    Color(0xFF4CAF50), // Verde
    Color(0xFF81C784), // Verde claro
  ];

  // Sombras y bordes
  static const Color sombra = Color(0x1A000000);
  static const Color sombra02 = Color(0x33000000);
  static const Color borde = Color(0xFFB0BEC5); // Gris azul claro
  static const Color bordeOscuro = Color(0xFF607D8B); // Gris azul
}
