// En Flutter
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> calcularImpactoAmbiental(List<Map<String, dynamic>> detecciones) async {
  final url = Uri.parse('http://TU_IP:8000/calcular-impacto');
  
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'detecciones': detecciones
    }),
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al calcular impacto');
  }
}

// Uso:
final resultado = await calcularImpactoAmbiental([
  {'material': 'botella_plastico', 'cantidad': 5},
  {'material': 'lata_aluminio', 'cantidad': 3}
]);

print('Puntos ganados: ${resultado['resumen_total']['puntos_ecologicos_totales']}');