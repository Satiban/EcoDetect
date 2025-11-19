# EcoRisk - Detección de Contaminación Ambiental

Aplicación móvil Flutter para detectar contaminación mediante análisis de imágenes.

## Descripción

EcoRisk es una aplicación que permite a los usuarios:
- Capturar o seleccionar imágenes de su entorno
- Analizar el nivel de contaminación en la imagen
- Obtener un índice de riesgo (0-100) y recomendaciones específicas

## Arquitectura

El proyecto sigue los principios de **Clean Architecture** organizado en capas:

```
lib/
├── core/                           # Configuración compartida
│   ├── constantes/                 # Textos y valores constantes
│   └── tema/                       # Colores y tema visual
├── features/                       # Funcionalidades (módulos)
│   └── analisis/
│       ├── domain/                 # Capa de dominio (lógica de negocio)
│       │   ├── entidades/          # Modelos de negocio
│       │   ├── repositorios/       # Interfaces (contratos)
│       │   └── casos_uso/          # Lógica de aplicación
│       ├── data/                   # Capa de datos (implementaciones)
│       │   ├── repositorios/       # Implementaciones concretas
│       │   └── servicios/          # Servicios externos/simulados
│       └── presentation/           # Capa de presentación (UI)
│           ├── pantallas/          # Pantallas de la app
│           ├── widgets/            # Componentes UI reutilizables
│           └── providers/          # Gestión de estado
└── shared/                         # Widgets compartidos entre módulos
```

### Ventajas de esta arquitectura:

✅ **Separación de responsabilidades**: Cada capa tiene una responsabilidad clara
✅ **Testeable**: Lógica de negocio desacoplada de la UI
✅ **Escalable**: Fácil agregar nuevas funcionalidades
✅ **Mantenible**: Código organizado y fácil de entender
✅ **Flexible**: Cambiar implementaciones sin afectar otras capas

## Requisitos

- Flutter 3.0 o superior
- Dart SDK 3.0 o superior
- Android Studio / VS Code con extensión de Flutter
- Un dispositivo físico o emulador para probar la cámara

## Instalación

### 1. Clonar o descargar el proyecto

```bash
cd eco_risk_app
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Verificar configuración

```bash
flutter doctor
```

Asegúrate de que todos los checkmarks estén en verde.

### 4. Ejecutar la aplicación

```bash
# En un emulador/dispositivo conectado
flutter run

# Para compilar en modo release
flutter run --release
```

## Dependencias Principales

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `provider` | ^6.1.1 | Gestión de estado simple y eficiente |
| `image_picker` | ^1.0.7 | Selección de imágenes desde cámara/galería |

## Uso de la Aplicación

### Flujo Principal

1. **Pantalla de Inicio**: Presenta la app y botón para "Analizar una foto"
2. **Selección de Imagen**: Permite tomar foto o elegir de galería
3. **Análisis**: Procesa la imagen (actualmente simulado)
4. **Resultado**: Muestra índice de riesgo, nivel y recomendaciones

### Niveles de Riesgo

| Índice | Nivel | Color | Descripción |
|--------|-------|-------|-------------|
| 0-39 | Bajo | Verde | Condiciones ambientales aceptables |
| 40-69 | Medio | Naranja | Nivel moderado, monitorear el área |
| 70-100 | Alto | Rojo | Nivel alto, evitar el área |

## 🔌 Puntos de Integración con IA/Backend Real

### Opción 1: Reemplazar el Servicio Simulado

**Archivo**: `lib/features/analisis/data/servicios/servicio_analisis_simulado.dart`

Este servicio actualmente genera resultados aleatorios. Puedes:

1. **Mantener la misma interfaz** pero cambiar la implementación:
   ```dart
   // Crear nuevo archivo: servicio_analisis_ia.dart
   class ServicioAnalisisIA {
     Future<double> analizarImagen(String rutaImagen) async {
       // TODO: Integrar con TensorFlow Lite, ML Kit, o tu modelo de IA
       // Ejemplo conceptual:
       final bytes = await File(rutaImagen).readAsBytes();
       final resultado = await tuModeloIA.predecir(bytes);
       return resultado.indiceContaminacion;
     }
   }
   ```

2. **Actualizar la inyección** en `lib/main.dart:33`:
   ```dart
   // Cambiar:
   ServicioAnalisisSimulado()
   // Por:
   ServicioAnalisisIA()
   ```

### Opción 2: Crear Repositorio con API REST

**Archivo**: Crear `lib/features/analisis/data/repositorios/repositorio_analisis_remoto.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class RepositorioAnalisisRemoto implements RepositorioAnalisis {
  final String baseUrl;

  RepositorioAnalisisRemoto(this.baseUrl);

  @override
  Future<ResultadoAnalisis> analizarImagen(String rutaImagen) async {
    // 1. Leer la imagen
    final bytes = await File(rutaImagen).readAsBytes();

    // 2. Crear multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/analizar')
    );
    request.files.add(
      http.MultipartFile.fromBytes('imagen', bytes, filename: 'foto.jpg')
    );

    // 3. Enviar y esperar respuesta
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var json = jsonDecode(responseData);

    // 4. Mapear respuesta a modelo de dominio
    return ResultadoAnalisis.desdeIndice(
      indice: json['indice_riesgo'].toDouble(),
      metadatos: {
        'api_version': json['version'],
        'timestamp': json['timestamp'],
      },
    );
  }
}
```

Luego actualizar `main.dart:32`:
```dart
RepositorioAnalisisRemoto('https://tu-api.com')
```

### Opción 3: Modelo Local con TensorFlow Lite

1. Agregar dependencia en `pubspec.yaml`:
   ```yaml
   dependencies:
     tflite_flutter: ^0.10.0
   ```

2. Crear servicio:
   ```dart
   class ServicioAnalisisTFLite {
     late Interpreter _interpreter;

     Future<void> cargarModelo() async {
       _interpreter = await Interpreter.fromAsset('modelo_contaminacion.tflite');
     }

     Future<double> analizarImagen(String rutaImagen) async {
       // Preprocesar imagen
       var imagen = await preprocesarImagen(rutaImagen);

       // Ejecutar inferencia
       var output = List.filled(1, 0.0).reshape([1, 1]);
       _interpreter.run(imagen, output);

       return output[0][0] * 100; // Normalizar a 0-100
     }
   }
   ```

### Dónde Cambiar el Código

| Ubicación | Archivo | Qué Cambiar |
|-----------|---------|-------------|
| **Inyección de dependencias** | `lib/main.dart:28-36` | Reemplazar `ServicioAnalisisSimulado` por tu implementación real |
| **Lógica de análisis** | `lib/features/analisis/data/servicios/` | Crear nuevo servicio con tu modelo de IA |
| **Repositorio** | `lib/features/analisis/data/repositorios/` | Implementar nueva clase si usas API REST |
| **Configuración** | `pubspec.yaml` | Agregar dependencias de ML/HTTP según necesites |

## Estructura de Archivos Clave

### 📱 Presentación (UI)

- `pantalla_inicio.dart`: Pantalla de bienvenida
- `pantalla_seleccion_imagen.dart`: Captura/selección de imagen
- `pantalla_resultado.dart`: Muestra resultados del análisis
- `tarjeta_indice_riesgo.dart`: Componente visual del índice
- `boton_accion_principal.dart`: Botón reutilizable

### 🧠 Dominio (Lógica de Negocio)

- `resultado_analisis.dart`: Modelo de datos del resultado
- `nivel_riesgo.dart`: Enumeración de niveles (Bajo/Medio/Alto)
- `repositorio_analisis.dart`: **Interfaz** (contrato) para análisis
- `analizar_imagen_caso_uso.dart`: Caso de uso principal

### 💾 Datos (Implementaciones)

- `servicio_analisis_simulado.dart`: ⚠️ **Implementación temporal simulada**
- `repositorio_analisis_impl.dart`: Implementación del repositorio

### 🎨 Core

- `colores_app.dart`: Paleta de colores minimalista
- `tema_app.dart`: Configuración del tema visual
- `textos.dart`: Textos estáticos (facilita i18n futura)

## Personalización

### Cambiar Colores

Edita `lib/core/tema/colores_app.dart`:

```dart
static const Color primario = Color(0xFF4CAF50); // Cambiar aquí
static const Color riesgoBajo = Color(0xFF4CAF50);
static const Color riesgoMedio = Color(0xFFFFA726);
static const Color riesgoAlto = Color(0xFFEF5350);
```

### Cambiar Textos

Edita `lib/core/constantes/textos.dart`:

```dart
static const String nombreApp = 'EcoRisk'; // Cambiar nombre
static const String subtituloApp = 'Tu subtítulo aquí';
```

### Ajustar Rangos de Riesgo

Edita `lib/features/analisis/domain/entidades/nivel_riesgo.dart:20-28`:

```dart
static NivelRiesgo desdeIndice(double indice) {
  if (indice < 30) {  // Cambiar umbral bajo
    return NivelRiesgo.bajo;
  } else if (indice < 60) {  // Cambiar umbral medio
    return NivelRiesgo.medio;
  } else {
    return NivelRiesgo.alto;
  }
}
```

## Testing

```bash
# Ejecutar todos los tests
flutter test

# Con cobertura
flutter test --coverage

# Test específico
flutter test test/features/analisis/domain/entidades/nivel_riesgo_test.dart
```

## Compilación para Producción

### Android

```bash
flutter build apk --release
# APK en: build/app/outputs/flutter-apk/app-release.apk

# O para App Bundle (recomendado para Google Play)
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
# Requiere Mac y Xcode configurado
```

## Roadmap / Próximas Funcionalidades

- [ ] Integración con modelo de IA real
- [ ] Historial de análisis realizados
- [ ] Exportar reportes en PDF
- [ ] Compartir resultados por redes sociales
- [ ] Modo offline con caché
- [ ] Dashboard web administrativo
- [ ] API REST para múltiples clientes
- [ ] Notificaciones push para alertas
- [ ] Geolocalización de análisis
- [ ] Internacionalización (i18n)

## Troubleshooting

### Error: "No se puede seleccionar imagen"

**Causa**: Permisos no configurados

**Solución Android**: Agregar en `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**Solución iOS**: Agregar en `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para analizar contaminación</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a las fotos para analizar contaminación</string>
```

### Error: "Gradle build failed"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

## Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## Contacto

Para preguntas o soporte, por favor abre un issue en el repositorio.

---

**Desarrollado con 💚 para un futuro más limpio**
