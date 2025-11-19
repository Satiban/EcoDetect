import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constantes/textos.dart';
import '../../../../core/tema/colores_app.dart';
import '../../../insignias/presentation/pantallas/pantalla_insignias.dart';
import '../../../insignias/presentation/providers/proveedor_insignias.dart';
import '../widgets/boton_accion_principal.dart';
import 'pantalla_seleccion_imagen.dart';

/// Pantalla inicial de la aplicación con diseño moderno
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColoresApp.fondoClaro,
              Color(0xFFFFFFFF),
              ColoresApp.fondoMedio,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botón de insignias en la parte superior
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColoresApp.fondoTarjeta,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: ColoresApp.primario.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PantallaInsignias(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.military_tech,
                                color: ColoresApp.secundario,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Consumer<ProveedorInsignias>(
                                builder: (context, proveedor, child) {
                                  return Text(
                                    '${proveedor.totalDesbloqueadas}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ColoresApp.textoOscuro,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Icono principal con gradiente y animación
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: ColoresApp.gradienteSecundario,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColoresApp.primario.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco,
                    size: 70,
                    color: ColoresApp.textoClaro,
                  ),
                ),

                const SizedBox(height: 40),

                // Nombre de la app
                Text(
                  Textos.nombreApp,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: ColoresApp.primario,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtítulo con gradiente
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      ColoresApp.secundario,
                      ColoresApp.primarioClaro,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    Textos.subtituloApp,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // Tarjeta de descripción mejorada
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ColoresApp.fondoTarjeta,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ColoresApp.borde,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: ColoresApp.sombra,
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColoresApp.informacion.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: ColoresApp.informacion,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          Textos.descripcionInicio,
                          style: TextStyle(
                            fontSize: 15,
                            color: ColoresApp.textoSecundario,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Botón principal con efecto
                BotonAccionPrincipal(
                  texto: Textos.botonAnalizarFoto,
                  icono: Icons.camera_alt,
                  onPresionado: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaSeleccionImagen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
