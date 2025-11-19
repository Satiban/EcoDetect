import 'package:flutter/material.dart';
import '../../../../core/tema/colores_app.dart';
import '../../domain/entidades/nivel_riesgo.dart';
import '../../domain/entidades/resultado_analisis.dart';

/// Tarjeta que muestra el índice y nivel de riesgo de forma visual
class TarjetaIndiceRiesgo extends StatelessWidget {
  final ResultadoAnalisis resultado;

  const TarjetaIndiceRiesgo({
    super.key,
    required this.resultado,
  });

  @override
  Widget build(BuildContext context) {
    final colorNivel = _obtenerColorNivel(resultado.nivelRiesgo);
    final colorNivelClaro = _obtenerColorNivelClaro(resultado.nivelRiesgo);
    final gradienteNivel = _obtenerGradienteNivel(resultado.nivelRiesgo);

    return Container(
      decoration: BoxDecoration(
        color: ColoresApp.fondoTarjeta,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorNivel.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            // Indicador circular del índice con gradiente
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorNivel.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Círculo de progreso con gradiente
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: CustomPaint(
                      painter: _CirculoGradientePainter(
                        progreso: resultado.indiceRiesgo / 100,
                        colorInicio: colorNivel,
                        colorFin: colorNivelClaro,
                      ),
                    ),
                  ),
                  // Valor numérico
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: gradienteNivel,
                        ).createShader(bounds),
                        child: Text(
                          resultado.indiceRiesgo.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Text(
                        'de 100',
                        style: TextStyle(
                          fontSize: 14,
                          color: ColoresApp.textoSecundario,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Etiqueta de nivel con gradiente
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradienteNivel,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: colorNivel.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _obtenerIconoNivel(resultado.nivelRiesgo),
                    color: ColoresApp.textoClaro,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Riesgo ${resultado.nivelRiesgo.texto}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.textoClaro,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Recomendación mejorada
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColoresApp.fondoClaro,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ColoresApp.borde,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColoresApp.secundario.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb,
                          color: ColoresApp.secundario,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Recomendación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.textoOscuro,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resultado.recomendacion,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: ColoresApp.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene el color según el nivel de riesgo
  Color _obtenerColorNivel(NivelRiesgo nivel) {
    switch (nivel) {
      case NivelRiesgo.bajo:
        return ColoresApp.riesgoBajo;
      case NivelRiesgo.medio:
        return ColoresApp.riesgoMedio;
      case NivelRiesgo.alto:
        return ColoresApp.riesgoAlto;
      case NivelRiesgo.muyAlto:
        return ColoresApp.riesgoMuyAlto;
    }
  }

  /// Obtiene el color claro según el nivel de riesgo
  Color _obtenerColorNivelClaro(NivelRiesgo nivel) {
    switch (nivel) {
      case NivelRiesgo.bajo:
        return ColoresApp.riesgoBajoClaro;
      case NivelRiesgo.medio:
        return ColoresApp.riesgoMedioClaro;
      case NivelRiesgo.alto:
        return ColoresApp.riesgoAltoClaro;
      case NivelRiesgo.muyAlto:
        return ColoresApp.riesgoMuyAltoClaro;
    }
  }

  /// Obtiene el gradiente según el nivel de riesgo
  List<Color> _obtenerGradienteNivel(NivelRiesgo nivel) {
    switch (nivel) {
      case NivelRiesgo.bajo:
        return [ColoresApp.riesgoBajo, ColoresApp.riesgoBajoClaro];
      case NivelRiesgo.medio:
        return [ColoresApp.riesgoMedio, ColoresApp.riesgoMedioClaro];
      case NivelRiesgo.alto:
        return [ColoresApp.riesgoAlto, ColoresApp.riesgoAltoClaro];
      case NivelRiesgo.muyAlto:
        return [ColoresApp.riesgoMuyAlto, ColoresApp.riesgoMuyAltoClaro];
    }
  }

  /// Obtiene el icono según el nivel de riesgo
  IconData _obtenerIconoNivel(NivelRiesgo nivel) {
    switch (nivel) {
      case NivelRiesgo.bajo:
        return Icons.check_circle;
      case NivelRiesgo.medio:
        return Icons.warning_amber;
      case NivelRiesgo.alto:
        return Icons.error;
      case NivelRiesgo.muyAlto:
        return Icons.dangerous;
    }
  }
}

/// Painter personalizado para dibujar un círculo de progreso con gradiente
class _CirculoGradientePainter extends CustomPainter {
  final double progreso;
  final Color colorInicio;
  final Color colorFin;

  _CirculoGradientePainter({
    required this.progreso,
    required this.colorInicio,
    required this.colorFin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Círculo de fondo
    final paintBackground = Paint()
      ..color = ColoresApp.borde
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    canvas.drawCircle(center, radius - 7, paintBackground);

    // Arco de progreso con gradiente
    final rect = Rect.fromCircle(center: center, radius: radius - 7);
    final gradient = SweepGradient(
      colors: [colorInicio, colorFin, colorInicio],
      stops: const [0.0, 0.5, 1.0],
      startAngle: -1.5708, // -90 grados
    );

    final paintGradient = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -1.5708, // Comienza desde arriba (-90 grados)
      2 * 3.14159 * progreso, // Ángulo basado en el progreso
      false,
      paintGradient,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
