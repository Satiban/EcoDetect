# ###########################################################################
#datos por defecto prorcionados por Roboflow para probar
# 1. Import the library
from inference_sdk import InferenceHTTPClient

# 2. Connect to your workflow
client = InferenceHTTPClient(
    api_url="https://serverless.roboflow.com",
    api_key="2b7LoZjjvB3oRq9ZGGCx"
)

# 3. Run your workflow on an image
result = client.run_workflow(
    workspace_name="arturo-oao7c",
    workflow_id="detect-count-and-visualize-2",
    images={
        "image": "YOUR_IMAGE.jpg" # Path to your image file
    },
    use_cache=True # Speeds up repeated requests
)

# 4. Get your results
print(result)
# ############################################################################

# 🤖 Sistema de Detección de Reciclables con Roboflow

Sistema de detección inteligente para clasificar y contar **botellas de plástico**, **botellas de vidrio** y **latas de aluminio** usando la API de Roboflow.

## 📋 Requisitos

- Python 3.8+
- Cuenta en Roboflow con un modelo entrenado
- API Key de Roboflow

## 🚀 Instalación

```bash
pip install inference-sdk
```

## ⚙️ Configuración

El script `deteccion_workflow.py` ya está configurado con:

- **API Key**: `2b7LoZjjvB3oRq9ZGGCx`
- **Workspace**: `arturo-oao7c`
- **Workflow ID**: `detect-count-and-visualize-2`

Si necesitas cambiar estos valores, edita las primeras líneas del script:

```python
API_KEY = "TU_API_KEY"
WORKSPACE = "TU_WORKSPACE"
WORKFLOW_ID = "TU_WORKFLOW_ID"
```

## 📸 Uso

### Ejecutar detección

```bash
python deteccion_workflow.py
```

El script te preguntará qué imagen analizar. Presiona **Enter** para usar `bottle2.jpeg` o escribe la ruta de otra imagen.

### Ejemplo con imagen personalizada

```bash
python deteccion_workflow.py
# Cuando te pregunte, escribe: mi_imagen.jpg
```

## 📊 Resultados Generados

El sistema genera **3 archivos JSON** y **1 imagen visualizada** por cada imagen analizada:

### 1. `workflow_completo_[imagen].json`
Respuesta completa del workflow de Roboflow (sin procesar).

### 2. `predicciones_[imagen].json`
Detecciones procesadas con todas las coordenadas y metadatos:

```json
{
  "imagen_analizada": "bottle2.jpeg",
  "total_objetos_detectados": 168,
  "predicciones": [
    {
      "x": 382.21875,
      "y": 409.5,
      "width": 170.015625,
      "height": 498.375,
      "confidence": 0.955,
      "class": "botella_plastico",
      "detection_id": "b4c617e3-f971-453f-bc79-588f7b553841"
    }
  ]
}
```

### 3. `conteo_[imagen].json` ⭐
**Resumen por tipo de objeto** - El más útil para análisis rápido:

```json
{
  "imagen_analizada": "bottle2.jpeg",
  "fecha_analisis": "2025-11-18",
  "conteo_por_tipo": {
    "botellas_plastico": 120,
    "botellas_vidrio": 14,
    "latas_aluminio": 34
  },
  "total_objetos": 168,
  "desglose_porcentual": {
    "botellas_plastico": "71.4%",
    "botellas_vidrio": "8.3%",
    "latas_aluminio": "20.2%"
  }
}
```

### 4. `resultados_imagenes/detectado_[imagen].jpg` 📷
**Imagen con detecciones visualizadas** - Guardada en carpeta separada:

Características de la visualización:
- 🔵 **Botellas de plástico**: Bounding box azul
- 🟢 **Botellas de vidrio**: Bounding box verde
- 🔴 **Latas de aluminio**: Bounding box rojo
- Cada objeto tiene:
  - Número de identificación (#1, #2, etc.)
  - Nombre del tipo de objeto
  - Porcentaje de confianza

## 📈 Resultados de Prueba

### bottle2.jpeg (Con filtros aplicados)
- 🔵 Botellas de plástico: **6** (66.7%)
- 🟢 Botellas de vidrio: **1** (11.1%)
- 🔴 Latas de aluminio: **2** (22.2%)
- **Total: 9 objetos** ✅

### bottle1.jpeg (Con filtros aplicados)
- 🔵 Botellas de plástico: **5** (83.3%)
- 🟢 Botellas de vidrio: **0** (0.0%)
- 🔴 Latas de aluminio: **1** (16.7%)
- **Total: 6 objetos** ✅

> **Nota**: Los filtros eliminan falsos positivos. Sin filtros, el API detectaba 167-174 objetos.

## 🔧 Configuración Avanzada

### Ajustar filtros para reducir falsos positivos ⭐

Edita estas variables en `deteccion_workflow.py` (líneas 14-16):

```python
CONFIDENCE_MIN = 0.85  # Solo detecciones con 85% o más de confianza
AREA_MIN = 5000        # Área mínima en píxeles cuadrados (ancho × alto)
```

**Guía rápida de ajuste:**
- **Si detecta demasiados objetos**: Aumenta `CONFIDENCE_MIN` (ej: 0.90)
- **Si no detecta objetos obvios**: Disminuye `CONFIDENCE_MIN` (ej: 0.80)
- **Si detecta fragmentos pequeños**: Aumenta `AREA_MIN` (ej: 8000)
- **Si no detecta objetos pequeños**: Disminuye `AREA_MIN` (ej: 3000)

📖 **Ver guía completa**: `CONFIGURACION_FILTROS.md`

### Mapeo de clases

Si tu modelo usa nombres diferentes, actualiza el diccionario `mapeo_clases` en la función `contar_por_tipo()`:

```python
mapeo_clases = {
    'botella_plastico': 'botellas_plastico',
    'plastic': 'botellas_plastico',
    'glass': 'botellas_vidrio',
    'can': 'latas_aluminio',
    # Añade tus propias clases aquí
}
```

## 🐛 Solución de Problemas

### Error: "HTTPCallErrorError 403 Forbidden"

**Causa**: El modelo no está desplegado o la API key no tiene permisos.

**Solución**: Usa el Workflow API (ya implementado en `deteccion_workflow.py`) en lugar de la API de inferencia directa.

### Error: "No se detectaron objetos"

**Posibles causas**:
1. La imagen no contiene objetos del tipo entrenado
2. El umbral de confianza es demasiado alto
3. La calidad de la imagen es baja

**Solución**: Reduce `CONFIDENCE_THRESHOLD` o mejora la calidad de la imagen.

### Error: "inference_sdk not found"

```bash
pip install inference-sdk
```

## 📁 Estructura de Archivos

```
deteccion_model/
├── deteccion_workflow.py          # ⭐ Script principal (USAR ESTE)
├── detection_model.py             # Script alternativo (API directa)
├── modelo_reconocimiento          # Script original básico
├── bottle1.jpeg                   # Imagen de prueba 1
├── bottle2.jpeg                   # Imagen de prueba 2
├── conteo_*.json                  # ⭐ Resultados de conteo
├── predicciones_*.json            # Detecciones completas
├── workflow_completo_*.json       # Respuesta raw del workflow
├── resultados_imagenes/           # 📷 Carpeta con imágenes procesadas
│   ├── detectado_bottle1.jpg      # Imagen con detecciones visualizadas
│   └── detectado_bottle2.jpg      # Imagen con detecciones visualizadas
├── GUIA_USO.md                    # Este archivo
└── CONFIGURACION_FILTROS.md       # Guía de ajuste de filtros
```

## 🎯 Casos de Uso

1. **Sistemas de reciclaje**: Conteo automático de materiales
2. **Análisis de residuos**: Estadísticas de tipos de basura
3. **Control de inventario**: Clasificación de envases
4. **Investigación ambiental**: Estudios de contaminación

## 📝 Notas Importantes

- ✅ **Filtros aplicados**: Confianza ≥ 85% y Área ≥ 5000px²
- 🎯 Los filtros reducen drásticamente los falsos positivos (de ~170 a 6-9 objetos)
- 💡 Ajusta `CONFIDENCE_MIN` y `AREA_MIN` según tus necesidades
- 📸 Para mejores resultados, usa imágenes con buena iluminación
- 🔍 El script muestra estadísticas del filtrado en cada ejecución

## 🤝 Contribuciones

Para mejorar el sistema:
1. Ajusta los umbrales de confianza según tus necesidades
2. Añade nuevas categorías al mapeo de clases
3. Entrena el modelo con más imágenes en Roboflow

## 📧 Soporte

Si encuentras problemas:
1. Verifica que el workflow esté activo en Roboflow
2. Revisa los archivos JSON generados para debugging
3. Consulta la documentación de Roboflow: https://docs.roboflow.com

---

✅ **Sistema funcionando correctamente** - Probado con `bottle1.jpeg` y `bottle2.jpeg`
