import 'package:flutter/material.dart';

/// Tipos de insignias disponibles en la aplicación
enum TipoInsignia {
  primerAnalisis,
  analisis5,
  analisis10,
  analisis25,
  analisis50,
  detectorExperto,
  guardianVerde,
  cazadorPlasticos,
  defensorAgua,
  protectorAire,
}

/// Entidad que representa una insignia en el dominio
class Insignia {
  final String id;
  final TipoInsignia tipo;
  final String nombre;
  final String descripcion;
  final IconData icono;
  final Color color;
  final bool desbloqueada;
  final DateTime? fechaDesbloqueo;
  final int progreso;
  final int metaProgreso;

  const Insignia({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
    this.desbloqueada = false,
    this.fechaDesbloqueo,
    this.progreso = 0,
    required this.metaProgreso,
  });

  /// Crea una copia de la insignia con los campos actualizados
  Insignia copyWith({
    String? id,
    TipoInsignia? tipo,
    String? nombre,
    String? descripcion,
    IconData? icono,
    Color? color,
    bool? desbloqueada,
    DateTime? fechaDesbloqueo,
    int? progreso,
    int? metaProgreso,
  }) {
    return Insignia(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      desbloqueada: desbloqueada ?? this.desbloqueada,
      fechaDesbloqueo: fechaDesbloqueo ?? this.fechaDesbloqueo,
      progreso: progreso ?? this.progreso,
      metaProgreso: metaProgreso ?? this.metaProgreso,
    );
  }

  /// Calcula el porcentaje de progreso (0.0 a 1.0)
  double get porcentajeProgreso {
    if (desbloqueada) return 1.0;
    if (metaProgreso == 0) return 0.0;
    return (progreso / metaProgreso).clamp(0.0, 1.0);
  }

  /// Verifica si la insignia está lista para desbloquearse
  bool get puedeDesbloquearse => progreso >= metaProgreso && !desbloqueada;
}
