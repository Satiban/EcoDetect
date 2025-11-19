// Test básico de la aplicación EcoRisk
//
// Para más información sobre testing en Flutter:
// https://flutter.dev/docs/cookbook/testing/widget/introduction

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eco_risk_app/main.dart';
import 'package:eco_risk_app/core/constantes/textos.dart';

void main() {
  testWidgets('La app muestra la pantalla de inicio correctamente', (WidgetTester tester) async {
    // Inicializar SharedPreferences para testing
    SharedPreferences.setMockInitialValues({});

    // Construir la app y renderizar un frame
    await tester.pumpWidget(const EcoRiskApp());

    // Esperar a que se complete la inicialización
    await tester.pumpAndSettle();

    // Verificar que el nombre de la app está presente
    expect(find.text(Textos.nombreApp), findsOneWidget);

    // Verificar que el botón principal está presente
    expect(find.text(Textos.botonAnalizarFoto), findsOneWidget);

    // Verificar que el icono eco está presente
    expect(find.byIcon(Icons.eco), findsOneWidget);
  });
}
