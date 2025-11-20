"""
EcoDetect - Aplicación Web Integrada
Flujo completo: Carga imagen → Roboflow → Cálculo IA → Resultados
"""
from flask import Flask, render_template, request, jsonify
import os
from werkzeug.utils import secure_filename
import requests
from inference_sdk import InferenceHTTPClient
import json
from pathlib import Path

app = Flask(__name__)

# Configuración
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max

# Crear carpeta de uploads si no existe
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Configuración Roboflow
ROBOFLOW_API_KEY = "2b7LoZjjvB3oRq9ZGGCx"
ROBOFLOW_WORKSPACE = "arturo-oao7c"
ROBOFLOW_WORKFLOW_ID = "detect-count-and-visualize-3"

# Configuración FastAPI
FASTAPI_URL = "http://localhost:8000/calcular-impacto"
RECOMPENSAS_API_URL = "http://localhost:8001"

# Filtros de detección
CONFIDENCE_MIN = 0.85
AREA_MIN = 5000

def allowed_file(filename):
    """Verifica si el archivo es una imagen válida"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def conectar_roboflow():
    """Conecta con Roboflow"""
    client = InferenceHTTPClient(
        api_url="https://serverless.roboflow.com",
        api_key=ROBOFLOW_API_KEY
    )
    return client

def detectar_objetos(imagen_path):
    """Detecta objetos usando Roboflow Workflow"""
    try:
        client = conectar_roboflow()
        
        result = client.run_workflow(
            workspace_name=ROBOFLOW_WORKSPACE,
            workflow_id=ROBOFLOW_WORKFLOW_ID,
            images={"image": imagen_path},
            use_cache=False
        )
        
        return result
    except Exception as e:
        print(f"Error en detección Roboflow: {e}")
        return None

def extraer_y_filtrar_predicciones(resultado_workflow):
    """Extrae y filtra predicciones de Roboflow"""
    predicciones = []
    
    if not resultado_workflow:
        return predicciones
    
    try:
        if isinstance(resultado_workflow, list) and len(resultado_workflow) > 0:
            primer_resultado = resultado_workflow[0]
            
            if 'predictions' in primer_resultado:
                predicciones = primer_resultado['predictions']
            elif 'detections' in primer_resultado:
                predicciones = primer_resultado['detections']
            
            for key, value in primer_resultado.items():
                if isinstance(value, dict):
                    if 'predictions' in value:
                        predicciones = value['predictions']
                        break
                    elif 'detections' in value:
                        predicciones = value['detections']
                        break
    except Exception as e:
        print(f"Error extrayendo predicciones: {e}")
    
    # Filtrar por confianza y área
    predicciones_filtradas = []
    for pred in predicciones:
        confidence = pred.get('confidence', 0)
        if confidence < CONFIDENCE_MIN:
            continue
        
        width = pred.get('width', 0)
        height = pred.get('height', 0)
        area = width * height
        
        if area < AREA_MIN:
            continue
        
        predicciones_filtradas.append(pred)
    
    return predicciones_filtradas

def contar_por_tipo(predicciones):
    """Cuenta objetos por tipo"""
    conteo = {
        "botella_plastico": 0,
        "botella_vidrio": 0,
        "lata_aluminio": 0
    }
    
    mapeo_clases = {
        'botella_plastico': 'botella_plastico',
        'botella_plastica': 'botella_plastico',
        'plastic': 'botella_plastico',
        'plastico': 'botella_plastico',
        'pet': 'botella_plastico',
        'botella_vidrio': 'botella_vidrio',
        'glass': 'botella_vidrio',
        'vidrio': 'botella_vidrio',
        'lata_aluminio': 'lata_aluminio',
        'lata': 'lata_aluminio',
        'can': 'lata_aluminio',
        'aluminum': 'lata_aluminio',
        'aluminio': 'lata_aluminio'
    }
    
    for pred in predicciones:
        clase = pred.get('class', '').lower().replace(' ', '_')
        
        if clase in mapeo_clases:
            conteo[mapeo_clases[clase]] += 1
        else:
            for clave, categoria in mapeo_clases.items():
                if clave in clase or clase in clave:
                    conteo[categoria] += 1
                    break
    
    return conteo

def calcular_impacto_ambiental(conteo):
    """Envía conteo a FastAPI para calcular impacto"""
    try:
        # Preparar datos para FastAPI
        detecciones = []
        for material, cantidad in conteo.items():
            if cantidad > 0:
                detecciones.append({
                    "material": material,
                    "cantidad": cantidad
                })
        
        if not detecciones:
            return None
        
        # Hacer petición a FastAPI
        response = requests.post(
            FASTAPI_URL,
            json={"detecciones": detecciones},
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Error en FastAPI: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"Error calculando impacto: {e}")
        return None

@app.route('/')
def index():
    """Página principal"""
    return render_template('index.html')

@app.route('/analizar', methods=['POST'])
def analizar_imagen():
    """Endpoint principal: analiza imagen completa"""
    
    # Verificar que se envió una imagen
    if 'imagen' not in request.files:
        return jsonify({'error': 'No se envió ninguna imagen'}), 400
    
    file = request.files['imagen']
    
    if file.filename == '':
        return jsonify({'error': 'No se seleccionó ningún archivo'}), 400
    
    if not allowed_file(file.filename):
        return jsonify({'error': 'Formato de archivo no permitido. Use PNG, JPG o JPEG'}), 400
    
    try:
        # Guardar imagen
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        # PASO 1: Detectar objetos con Roboflow
        print(f"🔍 Detectando objetos en: {filename}")
        resultado_roboflow = detectar_objetos(filepath)
        
        if not resultado_roboflow:
            return jsonify({'error': 'Error en la detección de objetos'}), 500
        
        # PASO 2: Extraer y filtrar predicciones
        predicciones = extraer_y_filtrar_predicciones(resultado_roboflow)
        
        if not predicciones:
            return jsonify({
                'detecciones': [],
                'conteo': {'botella_plastico': 0, 'botella_vidrio': 0, 'lata_aluminio': 0},
                'impacto': None,
                'mensaje': 'No se detectaron objetos reciclables'
            }), 200
        
        # PASO 3: Contar por tipo
        conteo = contar_por_tipo(predicciones)
        
        # PASO 4: Calcular impacto ambiental con FastAPI
        print(f"📊 Calculando impacto ambiental...")
        resultado_impacto = calcular_impacto_ambiental(conteo)
        
        # Preparar respuesta
        respuesta = {
            'exito': True,
            'imagen': filename,
            'total_detectado': len(predicciones),
            'detecciones': predicciones,
            'conteo': conteo,
            'impacto': resultado_impacto
        }
        
        return jsonify(respuesta), 200
        
    except Exception as e:
        print(f"Error procesando imagen: {e}")
        return jsonify({'error': f'Error procesando imagen: {str(e)}'}), 500

@app.route('/estado')
def estado_servicios():
    """Verifica el estado de los servicios"""
    estado = {
        'roboflow': 'desconocido',
        'fastapi': 'desconocido',
        'recompensas_api': 'desconocido'
    }
    
    # Verificar Roboflow
    try:
        client = conectar_roboflow()
        estado['roboflow'] = '✅ Conectado'
    except:
        estado['roboflow'] = '❌ Error'
    
    # Verificar FastAPI
    try:
        response = requests.get('http://localhost:8000/health', timeout=3)
        if response.status_code == 200:
            estado['fastapi'] = '✅ Activo'
        else:
            estado['fastapi'] = '⚠️ Respondiendo con errores'
    except:
        estado['fastapi'] = '❌ No disponible (¿está corriendo?)'
    
    # Verificar API de Recompensas
    try:
        response = requests.get(f'{RECOMPENSAS_API_URL}/', timeout=3)
        if response.status_code == 200:
            estado['recompensas_api'] = '✅ Activo'
        else:
            estado['recompensas_api'] = '⚠️ Respondiendo con errores'
    except:
        estado['recompensas_api'] = '❌ No disponible (¿está corriendo?)'
    
    return jsonify(estado)

@app.route('/recompensas')
def obtener_recompensas():
    """Obtiene todas las recompensas desde la API"""
    try:
        response = requests.get(f'{RECOMPENSAS_API_URL}/recompensas', timeout=5)
        if response.status_code == 200:
            return jsonify({
                'exito': True,
                'recompensas': response.json()
            }), 200
        else:
            return jsonify({
                'exito': False,
                'error': 'Error al obtener recompensas'
            }), response.status_code
    except Exception as e:
        return jsonify({
            'exito': False,
            'error': f'No se pudo conectar con la API de recompensas: {str(e)}'
        }), 503

@app.route('/test-interoperabilidad')
def test_interoperabilidad():
    """Endpoint para pruebas de interoperabilidad - verifica todos los servicios"""
    resultados = {
        'roboflow': False,
        'fastapi': False,
        'recompensas': False,
        'timestamp': None
    }
    
    from datetime import datetime
    resultados['timestamp'] = datetime.now().isoformat()
    
    # Probar Roboflow
    try:
        client = conectar_roboflow()
        resultados['roboflow'] = True
    except:
        pass
    
    # Probar FastAPI
    try:
        response = requests.get('http://localhost:8000/health', timeout=2)
        if response.status_code == 200:
            resultados['fastapi'] = True
    except:
        pass
    
    # Probar API Recompensas
    try:
        response = requests.get(f'{RECOMPENSAS_API_URL}/', timeout=2)
        if response.status_code == 200:
            resultados['recompensas'] = True
    except:
        pass
    
    # Calcular servicios activos
    servicios_activos = sum([resultados['roboflow'], resultados['fastapi'], resultados['recompensas']])
    resultados['servicios_activos'] = servicios_activos
    resultados['total_servicios'] = 3
    resultados['porcentaje_disponibilidad'] = (servicios_activos / 3) * 100
    
    return jsonify(resultados), 200

if __name__ == '__main__':
    print("\n" + "="*70)
    print("🌍 ECODETECT - Sistema Integrado de Detección y Análisis")
    print("="*70)
    print("🔗 Interfaz web: http://localhost:5000")
    print("📊 FastAPI (Impacto): http://localhost:8000")
    print("🎁 API Recompensas: http://localhost:8001")
    print("🤖 Roboflow configurado")
    print("="*70)
    print("\n📋 Endpoints disponibles:")
    print("  POST /analizar - Analiza imagen")
    print("  GET  /recompensas - Obtiene catálogo de recompensas")
    print("  GET  /estado - Estado de servicios")
    print("="*70 + "\n")
    
    app.run(debug=True, port=5000)
