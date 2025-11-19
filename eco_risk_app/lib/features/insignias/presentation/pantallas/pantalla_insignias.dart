import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entidades/insignia.dart';
import '../providers/proveedor_insignias.dart';

/// Pantalla para visualizar todas las insignias del usuario
class PantallaInsignias extends StatefulWidget {
  const PantallaInsignias({super.key});

  @override
  State<PantallaInsignias> createState() => _PantallaInsigniasState();
}

class _PantallaInsigniasState extends State<PantallaInsignias> {
  @override
  void initState() {
    super.initState();
    // Cargar insignias al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProveedorInsignias>().cargarInsignias();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Insignias'),
        elevation: 0,
      ),
      body: Consumer<ProveedorInsignias>(
        builder: (context, proveedor, child) {
          if (proveedor.estaCargando) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (proveedor.tieneError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      proveedor.mensajeError ?? 'Error desconocido',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => proveedor.cargarInsignias(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Cabecera con estadísticas
              SliverToBoxAdapter(
                child: _CabeceraEstadisticas(proveedor: proveedor),
              ),

              // Sección de insignias desbloqueadas
              if (proveedor.insigniasDesbloqueadas.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Text(
                      'Desbloqueadas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final insignia = proveedor.insigniasDesbloqueadas[index];
                        return _TarjetaInsignia(
                          insignia: insignia,
                          desbloqueada: true,
                        );
                      },
                      childCount: proveedor.insigniasDesbloqueadas.length,
                    ),
                  ),
                ),
              ],

              // Sección de insignias bloqueadas
              if (proveedor.insigniasBloqueadas.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Text(
                      'Por desbloquear',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final insignia = proveedor.insigniasBloqueadas[index];
                        return _TarjetaInsignia(
                          insignia: insignia,
                          desbloqueada: false,
                        );
                      },
                      childCount: proveedor.insigniasBloqueadas.length,
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget de cabecera con estadísticas de insignias
class _CabeceraEstadisticas extends StatelessWidget {
  final ProveedorInsignias proveedor;

  const _CabeceraEstadisticas({required this.proveedor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Tu Progreso',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _EstadisticaItem(
                icono: Icons.military_tech,
                valor: '${proveedor.totalDesbloqueadas}',
                etiqueta: 'Desbloqueadas',
              ),
              _EstadisticaItem(
                icono: Icons.lock_open,
                valor: '${proveedor.totalInsignias}',
                etiqueta: 'Total',
              ),
              _EstadisticaItem(
                icono: Icons.trending_up,
                valor: '${(proveedor.porcentajeCompletado * 100).toInt()}%',
                etiqueta: 'Completado',
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: proveedor.porcentajeCompletado,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar un item de estadística
class _EstadisticaItem extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;

  const _EstadisticaItem({
    required this.icono,
    required this.valor,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icono, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          etiqueta,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Widget de tarjeta de insignia
class _TarjetaInsignia extends StatelessWidget {
  final Insignia insignia;
  final bool desbloqueada;

  const _TarjetaInsignia({
    required this.insignia,
    required this.desbloqueada,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _mostrarDetalles(context),
      child: Container(
        decoration: BoxDecoration(
          color: desbloqueada
              ? Colors.white
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: desbloqueada ? insignia.color : Colors.grey.shade400,
            width: 2,
          ),
          boxShadow: desbloqueada
              ? [
                  BoxShadow(
                    color: insignia.color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: desbloqueada
                    ? insignia.color.withValues(alpha: 0.1)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                insignia.icono,
                size: 36,
                color: desbloqueada ? insignia.color : Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 12),

            // Nombre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                insignia.nombre,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: desbloqueada ? Colors.black87 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // Progreso o fecha de desbloqueo
            if (desbloqueada && insignia.fechaDesbloqueo != null)
              Text(
                _formatearFecha(insignia.fechaDesbloqueo!),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              )
            else if (!desbloqueada)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      '${insignia.progreso}/${insignia.metaProgreso}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: insignia.porcentajeProgreso,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          insignia.color.withValues(alpha: 0.6),
                        ),
                        minHeight: 6,
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

  void _mostrarDetalles(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _DialogoDetallesInsignia(insignia: insignia),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}

/// Diálogo con detalles de una insignia
class _DialogoDetallesInsignia extends StatelessWidget {
  final Insignia insignia;

  const _DialogoDetallesInsignia({required this.insignia});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono grande
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: insignia.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: insignia.color, width: 3),
              ),
              child: Icon(
                insignia.icono,
                size: 50,
                color: insignia.color,
              ),
            ),

            const SizedBox(height: 20),

            // Nombre
            Text(
              insignia.nombre,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: insignia.color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Descripción
            Text(
              insignia.descripcion,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Progreso o estado
            if (insignia.desbloqueada)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Desbloqueada',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Text(
                    'Progreso: ${insignia.progreso}/${insignia.metaProgreso}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: insignia.porcentajeProgreso,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(insignia.color),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Botón cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: insignia.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
