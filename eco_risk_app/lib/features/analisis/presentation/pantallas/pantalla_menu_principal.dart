import 'package:flutter/material.dart';
import '../../../../core/tema/colores_app.dart';
import 'pantalla_seleccion_imagen.dart';
import 'pantalla_historial.dart';

/// Pantalla de menú principal con estilo moderno tipo app de comida
class PantallaMenuPrincipal extends StatefulWidget {
  const PantallaMenuPrincipal({super.key});

  @override
  State<PantallaMenuPrincipal> createState() => _PantallaMenuPrincipalState();
}

class _PantallaMenuPrincipalState extends State<PantallaMenuPrincipal> {
  int _selectedCategory = 0;
  final List<String> _categories = [
    'Análisis',
    'Historial',
    'Insignias',
    'Más'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0), // Beige/gray background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header: Hamburger + Bell icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.menu, color: Colors.black, size: 28),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.black, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Title
                const Text(
                  'EcoRisk',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Análisis ecológico inteligente',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 24),

                // Large rounded card container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Left section: Info with hierarchical text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Comienza hoy',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Analiza fotos de tu entorno',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const PantallaSeleccionImagen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.camera_alt,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Analizar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Right section: Circular image
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: ColoresApp.primario.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: ColoresApp.primario,
                          size: 56,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Category pills
                const Text(
                  'Categorías',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategory == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = index;
                          });
                          // Handle navigation
                          if (index == 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PantallaSeleccionImagen(),
                              ),
                            );
                          } else if (index == 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PantallaHistorial(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: !isSelected
                                ? Border.all(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    width: 1)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              _categories[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Centered motivational text
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '🌍 "Cada análisis cuenta para cuidar nuestro planeta"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      // Floating navigation bar at bottom
      bottomNavigationBar: _FloatingBottomNav(
        onAnalisisTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PantallaSeleccionImagen(),
            ),
          );
        },
        onHistorialTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PantallaHistorial(),
            ),
          );
        },
      ),
    );
  }
}

/// Floating bottom navigation bar with minimalist design
class _FloatingBottomNav extends StatelessWidget {
  final VoidCallback onAnalisisTap;
  final VoidCallback onHistorialTap;

  const _FloatingBottomNav({
    required this.onAnalisisTap,
    required this.onHistorialTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Análisis icon
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
              onPressed: onAnalisisTap,
              tooltip: 'Analizar',
            ),
            // Historial icon
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white, size: 24),
              onPressed: onHistorialTap,
              tooltip: 'Historial',
            ),
            // Home icon
            IconButton(
              icon: const Icon(Icons.home_outlined,
                  color: Colors.white, size: 24),
              onPressed: () {},
              tooltip: 'Inicio',
            ),
            // More icon
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white, size: 24),
              onPressed: () {},
              tooltip: 'Más',
            ),
          ],
        ),
      ),
    );
  }
}
