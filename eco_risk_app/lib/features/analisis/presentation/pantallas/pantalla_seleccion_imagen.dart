import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constantes/textos.dart';
import '../../../../core/tema/colores_app.dart';
import '../providers/proveedor_analisis.dart';
import 'pantalla_resultado.dart';

/// Pantalla para seleccionar una imagen desde cámara o galería
class PantallaSeleccionImagen extends StatelessWidget {
  const PantallaSeleccionImagen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Textos.tituloSeleccion),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icono ilustrativo
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 100,
              color: ColoresApp.primario.withValues(alpha: 0.5),
            ),

            const SizedBox(height: 48),

            // Botón de cámara
            _BotonSeleccion(
              icono: Icons.camera_alt,
              texto: Textos.botonCamara,
              onPresionado: () => _seleccionarImagen(
                context,
                ImageSource.camera,
              ),
            ),

            const SizedBox(height: 16),

            // Botón de galería
            _BotonSeleccion(
              icono: Icons.photo_library,
              texto: Textos.botonGaleria,
              onPresionado: () => _seleccionarImagen(
                context,
                ImageSource.gallery,
              ),
            ),

            const SizedBox(height: 32),

            // Botón cancelar
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                Textos.botonCancelar,
                style: TextStyle(
                  color: ColoresApp.textoSecundario,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Maneja la selección de imagen desde cámara o galería
  Future<void> _seleccionarImagen(
    BuildContext context,
    ImageSource fuente,
  ) async {
    try {
      final picker = ImagePicker();
      final imagen = await picker.pickImage(source: fuente);

      if (imagen == null) {
        // Usuario canceló la selección
        return;
      }

      if (!context.mounted) return;

      // Obtener el provider y analizar la imagen
      final proveedor = context.read<ProveedorAnalisis>();
      await proveedor.analizarImagen(imagen.path);

      if (!context.mounted) return;

      // Navegar a la pantalla de resultado
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PantallaResultado(),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      // Mostrar error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${Textos.errorSeleccion}: ${e.toString()}'),
          backgroundColor: ColoresApp.error,
        ),
      );
    }
  }
}

/// Widget de botón de selección personalizado
class _BotonSeleccion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onPresionado;

  const _BotonSeleccion({
    required this.icono,
    required this.texto,
    required this.onPresionado,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPresionado,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ColoresApp.fondoTarjeta,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColoresApp.primario, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ColoresApp.primario.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                color: ColoresApp.primario,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColoresApp.textoOscuro,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: ColoresApp.primario,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
