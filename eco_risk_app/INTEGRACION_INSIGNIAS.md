# Integracion del Sistema de Insignias

## Descripcion

El sistema de insignias carga los datos desde un archivo JSON. Actualmente usa un archivo local pero se puede cambiar facilmente para usar una API externa.

## Estructura del JSON

El archivo assets/insignias.json contiene todas las insignias:

```json
{
  "version": "1.0",
  "insignias": [
    {
      "id": "identificador_unico",
      "tipo": "tipoInsignia",
      "nombre": "Nombre de la Insignia",
      "descripcion": "Descripcion de lo que representa",
      "icono": "nombre_del_icono",
      "color": "#HEXCOLOR",
      "metaProgreso": 10,
      "categoria": "categoria"
    }
  ]
}
```

## Campos del JSON

- id: Identificador unico de la insignia
- tipo: Tipo de insignia que determina como se desbloquea
- nombre: Nombre mostrado al usuario
- descripcion: Descripcion de como obtener la insignia
- icono: Nombre del icono de Material Icons
- color: Color en formato hexadecimal con #
- metaProgreso: Numero de acciones necesarias para desbloquear
- categoria: Categoria de la insignia (analisis, especial, etc)

## Tipos de Insignia

- primerAnalisis - Se desbloquea con el primer analisis
- analisis5 - Se desbloquea con 5 analisis
- analisis10 - Se desbloquea con 10 analisis
- analisis25 - Se desbloquea con 25 analisis
- analisis50 - Se desbloquea con 50 analisis
- detectorExperto - Se desbloquea detectando alto riesgo 3 veces
- guardianVerde - Se desbloquea identificando zonas limpias 10 veces
- cazadorPlasticos - No implementado aun
- defensorAgua - No implementado aun
- protectorAire - No implementado aun

## Iconos Soportados

eco_outlined, eco, explore, science, psychology, military_tech, warning_amber, park, delete_outline, water_drop, air

Para agregar mas iconos, editar el metodo _iconoDesdeString en servicio_carga_insignias.dart

## Como Cambiar el JSON Local

1. Editar el archivo assets/insignias.json
2. Seguir la estructura JSON de arriba
3. Ejecutar flutter clean y flutter pub get
4. Reconstruir la aplicacion

## Como Integrar con API

El servicio ServicioCargaInsignias tiene un metodo para cargar desde API:

### Paso 1: Implementar el metodo en servicio_carga_insignias.dart

Agregar dependencia http al pubspec.yaml:

```yaml
dependencies:
  http: ^1.1.0
```

Luego implementar:

```dart
import 'package:http/http.dart' as http;

Future<List<Insignia>> cargarInsigniasDesdeAPI(String url, {Map<String, String>? headers}) async {
  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> insigniasJson = jsonData['insignias'] as List<dynamic>;
      return insigniasJson.map((json) => _insigniaDesdeJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error al cargar insignias: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error al cargar insignias desde API: $e');
    return await cargarInsigniasDesdeAssets();
  }
}
```

### Paso 2: Modificar el repositorio

En repositorio_insignias_impl.dart cambiar:

```dart
// De esto:
_insigniasPredefinidas ??= await _servicioCargaInsignias.cargarInsigniasDesdeAssets();

// A esto:
_insigniasPredefinidas ??= await _servicioCargaInsignias.cargarInsigniasDesdeAPI(
  'https://api.tudominio.com/insignias',
  headers: {'Authorization': 'Bearer $token'}
);
```

## Formato del Endpoint

El endpoint debe retornar el mismo formato que el JSON local:

GET /api/insignias

```json
{
  "version": "1.0",
  "insignias": [
    {
      "id": "primer_analisis",
      "tipo": "primerAnalisis",
      "nombre": "Primer Paso",
      "descripcion": "Realizaste tu primer analisis",
      "icono": "eco_outlined",
      "color": "#4CAF50",
      "metaProgreso": 1,
      "categoria": "analisis"
    }
  ]
}
```

## Como Agregar Nuevos Tipos de Insignia

### 1. Actualizar el enum en insignia.dart

```dart
enum TipoInsignia {
  primerAnalisis,
  // ... existentes ...
  nuevoTipo,
}
```

### 2. Actualizar el mapeo en servicio_carga_insignias.dart

```dart
TipoInsignia _tipoInsigniaDesdeString(String tipo) {
  switch (tipo) {
    // ... casos existentes ...
    case 'nuevoTipo':
      return TipoInsignia.nuevoTipo;
    // ...
  }
}
```

### 3. Implementar la logica en repositorio_insignias_impl.dart

```dart
switch (insignia.tipo) {
  // ... casos existentes ...
  case TipoInsignia.nuevoTipo:
    progresoActual = _calcularProgresoNuevoTipo();
    break;
}
```

### 4. Agregar al JSON

```json
{
  "id": "nuevo_tipo_1",
  "tipo": "nuevoTipo",
  "nombre": "Nombre de la Nueva Insignia",
  "descripcion": "Descripcion",
  "icono": "icono_material",
  "color": "#FFFFFF",
  "metaProgreso": 5,
  "categoria": "nueva"
}
```

## Sincronizacion con Backend

Para sincronizar el progreso del usuario:

1. Crear un servicio de sincronizacion
2. Enviar el progreso al backend cuando se desbloquea una insignia
3. Recuperar el progreso desde el backend al iniciar la app

Ejemplo de datos para enviar:

```json
{
  "userId": "123456",
  "insignias": [
    {
      "insigniaId": "primer_analisis",
      "desbloqueada": true,
      "fechaDesbloqueo": "2025-11-19T10:30:00Z",
      "progreso": 1
    }
  ],
  "estadisticas": {
    "totalAnalisis": 10,
    "contadorAltoRiesgo": 3,
    "contadorZonasLimpias": 5
  }
}
```

## Notas Importantes

- Las insignias cargadas desde API deben validarse en el backend
- No confiar en el cliente para determinar insignias desbloqueadas
- Usar autenticacion para proteger los endpoints
- Validar que el progreso reportado por el cliente es consistente
- El archivo assets/insignias.json es la fuente de verdad para desarrollo local
- Mantener sincronizado con la API de produccion
- Usar versionado en el JSON para manejar cambios de esquema
