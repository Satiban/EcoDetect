/// Textos estáticos de la aplicación
/// Facilita la internacionalización futura
class Textos {
  // Evitar instanciación
  Textos._();

  // Pantalla de inicio
  static const String nombreApp = 'EcoRisk';
  static const String subtituloApp = 'Detección de contaminación mediante imágenes';
  static const String botonAnalizarFoto = 'Analizar una foto';
  static const String descripcionInicio =
      'Toma una foto o selecciona una imagen de tu galería para analizar el nivel de contaminación ambiental.';

  // Pantalla de selección
  static const String tituloSeleccion = 'Seleccionar imagen';
  static const String botonCamara = 'Tomar foto';
  static const String botonGaleria = 'Elegir de galería';
  static const String botonCancelar = 'Cancelar';

  // Pantalla de resultado
  static const String tituloResultado = 'Resultado del análisis';
  static const String labelIndiceRiesgo = 'Índice de riesgo';
  static const String labelNivelRiesgo = 'Nivel de riesgo';
  static const String labelRecomendacion = 'Recomendación';
  static const String botonNuevoAnalisis = 'Realizar nuevo análisis';

  // Niveles de riesgo
  static const String nivelBajo = 'Bajo';
  static const String nivelMedio = 'Medio';
  static const String nivelAlto = 'Alto';

  // Recomendaciones según nivel
  static const String recomendacionBaja =
      'El nivel de contaminación detectado es bajo. El área presenta condiciones ambientales aceptables.';
  static const String recomendacionMedia =
      'Se detectó un nivel moderado de contaminación. Se recomienda monitorear el área y tomar medidas preventivas.';
  static const String recomendacionAlta =
      'Alerta: Se detectó un nivel alto de contaminación. Se recomienda evitar el área y reportar a las autoridades ambientales correspondientes.';

  // Mensajes de estado
  static const String analizando = 'Analizando imagen...';
  static const String errorAnalisis = 'Error al analizar la imagen';
  static const String errorSeleccion = 'No se pudo seleccionar la imagen';
}
