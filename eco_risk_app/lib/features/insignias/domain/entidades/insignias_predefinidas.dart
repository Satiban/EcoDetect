import 'package:flutter/material.dart';
import 'insignia.dart';

/// Catálogo de insignias predefinidas de la aplicación
class InsigniasPredefinidas {
  static List<Insignia> obtenerTodasLasInsignias() {
    return [
      // Insignias por cantidad de análisis
      const Insignia(
        id: 'primer_analisis',
        tipo: TipoInsignia.primerAnalisis,
        nombre: 'Primer Paso',
        descripcion: 'Realizaste tu primer análisis de contaminación',
        icono: Icons.eco_outlined,
        color: Color(0xFF4CAF50),
        metaProgreso: 1,
      ),
      const Insignia(
        id: 'analisis_5',
        tipo: TipoInsignia.analisis5,
        nombre: 'Explorador Ecológico',
        descripcion: 'Completaste 5 análisis de contaminación',
        icono: Icons.explore,
        color: Color(0xFF66BB6A),
        metaProgreso: 5,
      ),
      const Insignia(
        id: 'analisis_10',
        tipo: TipoInsignia.analisis10,
        nombre: 'Investigador Ambiental',
        descripcion: 'Completaste 10 análisis de contaminación',
        icono: Icons.science,
        color: Color(0xFF26A69A),
        metaProgreso: 10,
      ),
      const Insignia(
        id: 'analisis_25',
        tipo: TipoInsignia.analisis25,
        nombre: 'Experto en Detección',
        descripcion: 'Completaste 25 análisis de contaminación',
        icono: Icons.psychology,
        color: Color(0xFF00897B),
        metaProgreso: 25,
      ),
      const Insignia(
        id: 'analisis_50',
        tipo: TipoInsignia.analisis50,
        nombre: 'Maestro Ambiental',
        descripcion: 'Completaste 50 análisis de contaminación',
        icono: Icons.military_tech,
        color: Color(0xFFFFB300),
        metaProgreso: 50,
      ),

      // Insignias especiales
      const Insignia(
        id: 'detector_experto',
        tipo: TipoInsignia.detectorExperto,
        nombre: 'Detector Experto',
        descripcion: 'Detectaste contaminación de alto riesgo 3 veces',
        icono: Icons.warning_amber,
        color: Color(0xFFFF6F00),
        metaProgreso: 3,
      ),
      const Insignia(
        id: 'guardian_verde',
        tipo: TipoInsignia.guardianVerde,
        nombre: 'Guardián Verde',
        descripcion: 'Identificaste zonas limpias 10 veces',
        icono: Icons.park,
        color: Color(0xFF2E7D32),
        metaProgreso: 10,
      ),
      const Insignia(
        id: 'cazador_plasticos',
        tipo: TipoInsignia.cazadorPlasticos,
        nombre: 'Cazador de Plásticos',
        descripcion: 'Detectaste contaminación por plásticos 5 veces',
        icono: Icons.delete_outline,
        color: Color(0xFF1976D2),
        metaProgreso: 5,
      ),
      const Insignia(
        id: 'defensor_agua',
        tipo: TipoInsignia.defensorAgua,
        nombre: 'Defensor del Agua',
        descripcion: 'Analizaste fuentes de agua 7 veces',
        icono: Icons.water_drop,
        color: Color(0xFF0288D1),
        metaProgreso: 7,
      ),
      const Insignia(
        id: 'protector_aire',
        tipo: TipoInsignia.protectorAire,
        nombre: 'Protector del Aire',
        descripcion: 'Detectaste contaminación atmosférica 5 veces',
        icono: Icons.air,
        color: Color(0xFF5E35B1),
        metaProgreso: 5,
      ),
    ];
  }
}
