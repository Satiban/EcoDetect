import 'package:flutter/material.dart';
import '../../domain/entidades/insignia.dart';

/// Servicio para mostrar notificaciones cuando se desbloquean insignias
class ServicioNotificacionesInsignias {
  /// Muestra un diálogo celebrando el desbloqueo de una insignia
  static void mostrarNotificacionInsignia(
    BuildContext context,
    Insignia insignia,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _DialogoInsigniaDesbloqueada(insignia: insignia);
      },
    );
  }

  /// Muestra múltiples insignias desbloqueadas
  static void mostrarNotificacionesInsignias(
    BuildContext context,
    List<Insignia> insignias,
  ) {
    if (insignias.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _DialogoMultiplesInsignias(insignias: insignias);
      },
    );
  }

  /// Muestra un SnackBar simple para insignia desbloqueada
  static void mostrarSnackBarInsignia(
    BuildContext context,
    Insignia insignia,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(insignia.icono, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Insignia desbloqueada',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(insignia.nombre),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: insignia.color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Widget de diálogo para mostrar una insignia desbloqueada
class _DialogoInsigniaDesbloqueada extends StatefulWidget {
  final Insignia insignia;

  const _DialogoInsigniaDesbloqueada({required this.insignia});

  @override
  State<_DialogoInsigniaDesbloqueada> createState() =>
      _DialogoInsigniaDesbloqueadaState();
}

class _DialogoInsigniaDesbloqueadaState
    extends State<_DialogoInsigniaDesbloqueada>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: widget.insignia.color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    const Text(
                      'Insignia Desbloqueada',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Icono de la insignia con efecto brillante
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: widget.insignia.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.insignia.color,
                          width: 4,
                        ),
                      ),
                      child: Icon(
                        widget.insignia.icono,
                        size: 64,
                        color: widget.insignia.color,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nombre de la insignia
                    Text(
                      widget.insignia.nombre,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: widget.insignia.color,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Descripción
                    Text(
                      widget.insignia.descripcion,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Botón de continuar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.insignia.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget de diálogo para mostrar múltiples insignias desbloqueadas
class _DialogoMultiplesInsignias extends StatelessWidget {
  final List<Insignia> insignias;

  const _DialogoMultiplesInsignias({required this.insignias});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Insignias Desbloqueadas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Has desbloqueado ${insignias.length} insignias',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Lista de insignias
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: insignias.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final insignia = insignias[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: insignia.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: insignia.color),
                    ),
                    child: Row(
                      children: [
                        Icon(insignia.icono, color: insignia.color, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                insignia.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: insignia.color,
                                ),
                              ),
                              Text(
                                insignia.descripcion,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Botón de continuar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
