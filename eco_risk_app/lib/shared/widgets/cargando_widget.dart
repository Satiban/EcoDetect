import 'package:flutter/material.dart';
import '../../core/tema/colores_app.dart';

/// Widget de carga minimalista y reutilizable
class CargandoWidget extends StatelessWidget {
  final String? mensaje;

  const CargandoWidget({
    super.key,
    this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.primario),
          ),
          if (mensaje != null) ...[
            const SizedBox(height: 24),
            Text(
              mensaje!,
              style: const TextStyle(
                fontSize: 16,
                color: ColoresApp.textoSecundario,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
