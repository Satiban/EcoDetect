import 'package:flutter/material.dart';
import '../../../../core/tema/colores_app.dart';

/// Botón de acción principal reutilizable con diseño moderno
class BotonAccionPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback? onPresionado;
  final IconData? icono;
  final bool esDestructivo;

  const BotonAccionPrincipal({
    super.key,
    required this.texto,
    this.onPresionado,
    this.icono,
    this.esDestructivo = false,
  });

  @override
  Widget build(BuildContext context) {
    final gradiente = esDestructivo
        ? const LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: ColoresApp.gradientePrimario,
          );

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: gradiente,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: esDestructivo
                ? ColoresApp.error.withValues(alpha: 0.4)
                : ColoresApp.primario.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPresionado,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icono != null) ...[
                  Icon(icono, size: 26, color: ColoresApp.textoClaro),
                  const SizedBox(width: 12),
                ],
                Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.textoClaro,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
