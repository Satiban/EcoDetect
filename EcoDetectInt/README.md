# 🌍 EcoDetect - Sistema Integrado

Interfaz web que integra **Roboflow** (detección de objetos) con **FastAPI** (cálculos de IA) en un flujo completo.

## 🔄 Flujo Completo

```
1. Usuario carga imagen
       ↓
2. Roboflow detecta objetos (botellas, latas)
       ↓
3. FastAPI calcula impacto ambiental (CO₂, energía, puntos)
       ↓
4. Interfaz muestra resultados visuales
```

## 📋 Requisitos Previos

Antes de usar esta aplicación, debes tener:

1. **FastAPI corriendo** en el puerto 8000
2. Python instalado con las dependencias

## 🚀 Instalación

```bash
cd EcoDetectInt
pip install -r requirements.txt
```

## 🎮 Uso

### Paso 1: Iniciar FastAPI (Terminal 1)
```bash
cd ../FastAPI_IA
python main.py
```
Debe mostrar: `✅ Modelos de regresión lineal entrenados correctamente`

### Paso 2: Iniciar la interfaz web (Terminal 2)
```bash
cd ../EcoDetectInt
python app.py
```

### Paso 3: Abrir navegador
Visita: **http://localhost:5000**

## 🎯 Características

- ✅ Carga de imágenes por drag & drop o selección
- ✅ Vista previa de imagen
- ✅ Detección automática con Roboflow
- ✅ Cálculo de impacto ambiental con IA
- ✅ Visualización de resultados:
  - Total de objetos detectados
  - Peso estimado
  - CO₂ evitado
  - Energía ahorrada
  - Puntos ecológicos ganados
- ✅ Desglose por tipo de material
- ✅ Verificación de estado de servicios

## 🏗️ Estructura

```
EcoDetectInt/
├── app.py              # Backend Flask
├── requirements.txt    # Dependencias
├── README.md          # Esta documentación
├── templates/
│   └── index.html     # Interfaz web
└── uploads/           # Imágenes subidas (se crea automáticamente)
```

## ⚙️ Configuración

Si necesitas cambiar configuraciones, edita estas variables en `app.py`:

```python
# Roboflow
ROBOFLOW_API_KEY = "tu_api_key"
ROBOFLOW_WORKSPACE = "tu_workspace"
ROBOFLOW_WORKFLOW_ID = "tu_workflow"

# FastAPI
FASTAPI_URL = "http://localhost:8000/calcular-impacto"

# Filtros de detección
CONFIDENCE_MIN = 0.85  # Confianza mínima (85%)
AREA_MIN = 5000        # Área mínima en píxeles
```

## 🐛 Solución de Problemas

### Error: "FastAPI no disponible"
- Asegúrate de que FastAPI esté corriendo en http://localhost:8000
- Verifica con: `curl http://localhost:8000/health`

### Error: "Error en detección de objetos"
- Verifica tu API key de Roboflow
- Comprueba tu conexión a internet

### No se detectan objetos
- Usa imágenes claras de botellas o latas
- Los objetos deben tener un tamaño mínimo
- Ajusta `CONFIDENCE_MIN` y `AREA_MIN` si es necesario

## 📊 Ejemplo de Respuesta

```json
{
  "exito": true,
  "total_detectado": 5,
  "conteo": {
    "botella_plastico": 3,
    "lata_aluminio": 2,
    "botella_vidrio": 0
  },
  "impacto": {
    "resumen_total": {
      "peso_total_gramos": 150.0,
      "co2_total_evitado_kg": 1.238,
      "energia_total_ahorrada_kwh": 2.512,
      "puntos_ecologicos_totales": 76
    }
  }
}
```

## 📝 Notas

- La carpeta `uploads/` se crea automáticamente
- Las imágenes se guardan temporalmente para el análisis
- Máximo tamaño de imagen: 16MB
- Formatos permitidos: PNG, JPG, JPEG
