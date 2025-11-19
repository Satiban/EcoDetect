"""
Script de detección usando Workflow API de Roboflow
"""
#Librerías necesarias: pip install roboflow inference-sdk pillow
import json
from inference_sdk import InferenceHTTPClient
from pathlib import Path
import os
from PIL import Image, ImageDraw, ImageFont

# datos de API de Roboflow
API_KEY = "2b7LoZjjvB3oRq9ZGGCx"
WORKSPACE = "arturo-oao7c"

#*detección de cantidad de objetos con falsos positivos pero mejor clasificación
#WORKFLOW_ID = "detect-count-and-visualize-2" 

#*mejor detección de cantidad de objetos pero menos preciso en clasificación (no requiere parametros de configuración)
WORKFLOW_ID = "detect-count-and-visualize-3" 

# mejor modelo de detección y precisión, no requiere para metros de configuración (estan configurados en la API)
#WORKFLOW_ID = "detect-count-and-visualize",

# Configuración de filtros para reducir falsos positivos en la detección
#poner los valores que mejor funcionen según el modelo y las imágenes analizadas (poner en 0 para desactivar)
#probar con 0 ya que los modelos tiene configurada la precisión en la API, ajustar parametros si no determina corretcamente.
CONFIDENCE_MIN = 0.85  # Solo detecciones con 85% o más de confianza
AREA_MIN = 5000       # Área mínima del objeto en píxeles cuadrados (ancho × alto)


def conectar_cliente():
    """Conecta con el servidor de inferencia de Roboflow"""
    client = InferenceHTTPClient(
        api_url="https://serverless.roboflow.com",
        api_key=API_KEY
    )
    print(f"✓ Conectado a Roboflow Workflow")
    print(f"  Workspace: {WORKSPACE}")
    print(f"  Workflow: {WORKFLOW_ID}")
    print(f"  Confianza mínima: {CONFIDENCE_MIN*100:.0f}%")
    print(f"  Área mínima: {AREA_MIN} px²\n")
    return client

def detectar_objetos_workflow(client, imagen_path):
    """
    Detecta objetos usando el workflow de Roboflow
    
    Args:
        client: Cliente de inferencia
        imagen_path: Ruta a la imagen
    
    Returns:
        dict: Resultados del workflow
    """
    if not os.path.exists(imagen_path):
        print(f"✗ Error: La imagen '{imagen_path}' no existe")
        return None
    
    print(f"📸 Analizando: {imagen_path}")
    
    try:
        # Ejecutar workflow
        result = client.run_workflow(
            workspace_name=WORKSPACE,
            workflow_id=WORKFLOW_ID,
            images={
                "image": imagen_path
            },
            use_cache=False  # Desactivar cache para ver resultados actualizados
        )
        
        print(f"✓ Análisis completado\n")
        return result
        
    except Exception as e:
        print(f"✗ Error en la detección: {e}")
        import traceback
        traceback.print_exc()
        return None

def extraer_predicciones(resultado_workflow):
    """
    Extrae y filtra las predicciones del resultado del workflow
    Aplica filtros de confianza y área para reducir falsos positivos
    """
    predicciones = []
    
    if not resultado_workflow:
        return predicciones
    
    # Intentar extraer de diferentes estructuras posibles
    try:
        # Estructura típica de workflow
        if isinstance(resultado_workflow, list) and len(resultado_workflow) > 0:
            primer_resultado = resultado_workflow[0]
            
            # Buscar en diferentes ubicaciones posibles
            if 'predictions' in primer_resultado:
                predicciones = primer_resultado['predictions']
            elif 'detections' in primer_resultado:
                predicciones = primer_resultado['detections']
            
            # Buscar en outputs del workflow
            for key, value in primer_resultado.items():
                if isinstance(value, dict):
                    if 'predictions' in value:
                        predicciones = value['predictions']
                        break
                    elif 'detections' in value:
                        predicciones = value['detections']
                        break
    except Exception as e:
        print(f"⚠️  Advertencia al extraer predicciones: {e}")
    
    # Aplicar filtros para reducir falsos positivos
    predicciones_filtradas = []
    total_antes = len(predicciones)
    
    for pred in predicciones:
        # Filtro 1: Confianza mínima
        confidence = pred.get('confidence', 0)
        if confidence < CONFIDENCE_MIN:
            continue
        
        # Filtro 2: Área mínima (evitar detecciones muy pequeñas)
        width = pred.get('width', 0)
        height = pred.get('height', 0)
        area = width * height
        
        if area < AREA_MIN:
            continue
        
        # Si pasa todos los filtros, incluir
        predicciones_filtradas.append(pred)
    
    total_despues = len(predicciones_filtradas)
    
    if total_antes > 0:
        print(f"🔍 Filtrado de detecciones:")
        print(f"   • Total inicial: {total_antes}")
        print(f"   • Filtradas por baja confianza: {sum(1 for p in predicciones if p.get('confidence', 0) < CONFIDENCE_MIN)}")
        print(f"   • Filtradas por área pequeña: {sum(1 for p in predicciones if (p.get('width', 0) * p.get('height', 0)) < AREA_MIN and p.get('confidence', 0) >= CONFIDENCE_MIN)}")
        print(f"   • Detecciones válidas: {total_despues}\n")
    
    return predicciones_filtradas

def contar_por_tipo(predicciones):
    """
    Cuenta objetos por tipo específico
    
    Args:
        predicciones: Lista de predicciones
    
    Returns:
        dict: Conteo por tipo
    """
    conteo = {
        "botellas_plastico": 0,
        "botellas_vidrio": 0,
        "latas_aluminio": 0
    }
    
    if not predicciones:
        return conteo
    
    # Mapeo de clases posibles a categorías
    mapeo_clases = {
        'botella_plastico': 'botellas_plastico',
        'botella_plastica': 'botellas_plastico',
        'plastic': 'botellas_plastico',
        'plastico': 'botellas_plastico',
        'pet': 'botellas_plastico',
        'botella_vidrio': 'botellas_vidrio',
        'glass': 'botellas_vidrio',
        'vidrio': 'botellas_vidrio',
        'lata_aluminio': 'latas_aluminio',
        'lata': 'latas_aluminio',
        'can': 'latas_aluminio',
        'aluminum': 'latas_aluminio',
        'aluminio': 'latas_aluminio'
    }
    
    for pred in predicciones:
        clase = pred.get('class', '').lower().replace(' ', '_')
        
        # Buscar coincidencia exacta primero
        if clase in mapeo_clases:
            conteo[mapeo_clases[clase]] += 1
        else:
            # Buscar coincidencia parcial
            for clave, categoria in mapeo_clases.items():
                if clave in clase or clase in clave:
                    conteo[categoria] += 1
                    break
    
    return conteo

def mostrar_resultados(predicciones):
    """Muestra las predicciones en consola con formato"""
    if not predicciones or len(predicciones) == 0:
        print("⚠️  No se detectaron objetos\n")
        return
    
    print("="*70)
    print("OBJETOS DETECTADOS")
    print("="*70)
    
    for i, pred in enumerate(predicciones, 1):
        print(f"\n🔍 Objeto {i}:")
        print(f"   Tipo: {pred.get('class', 'N/A')}")
        
        # Manejar confidence que puede estar en diferentes formatos
        confidence = pred.get('confidence', pred.get('conf', 0))
        if isinstance(confidence, float):
            print(f"   Confianza: {confidence*100:.1f}%")
        else:
            print(f"   Confianza: {confidence}")
        
        # Coordenadas pueden variar según el formato
        if 'x' in pred and 'y' in pred:
            print(f"   Posición: (x={pred['x']:.1f}, y={pred['y']:.1f})")
        elif 'bbox' in pred:
            bbox = pred['bbox']
            print(f"   BBox: {bbox}")
        
        if 'width' in pred and 'height' in pred:
            print(f"   Dimensiones: {pred['width']:.1f} × {pred['height']:.1f} px")
        
        if 'detection_id' in pred:
            print(f"   ID: {pred['detection_id']}")
    
    print("\n" + "="*70 + "\n")

def guardar_json_completo(resultado_workflow, nombre_imagen):
    """Guarda el resultado completo del workflow"""
    nombre_base = Path(nombre_imagen).stem
    archivo_salida = f"workflow_completo_{nombre_base}.json"
    
    with open(archivo_salida, 'w', encoding='utf-8') as f:
        json.dump(resultado_workflow, f, indent=2, ensure_ascii=False)
    
    print(f"💾 Resultado completo del workflow guardado en: {archivo_salida}")

def guardar_json_predicciones(predicciones, nombre_imagen):
    """Guarda solo las predicciones extraídas"""
    nombre_base = Path(nombre_imagen).stem
    archivo_salida = f"predicciones_{nombre_base}.json"
    
    datos_salida = {
        "imagen_analizada": nombre_imagen,
        "total_objetos_detectados": len(predicciones),
        "predicciones": predicciones
    }
    
    with open(archivo_salida, 'w', encoding='utf-8') as f:
        json.dump(datos_salida, f, indent=2, ensure_ascii=False)
    
    print(f"💾 Predicciones guardadas en: {archivo_salida}")

def guardar_json_conteo(conteo, nombre_imagen):
    """Guarda el conteo por tipo"""
    nombre_base = Path(nombre_imagen).stem
    archivo_salida = f"conteo_{nombre_base}.json"
    
    datos_conteo = {
        "imagen_analizada": nombre_imagen,
        "fecha_analisis": "2025-11-18",
        "conteo_por_tipo": conteo,
        "total_objetos": sum(conteo.values()),
        "desglose_porcentual": {
            tipo: f"{(cantidad / sum(conteo.values()) * 100):.1f}%" if sum(conteo.values()) > 0 else "0%"
            for tipo, cantidad in conteo.items()
        }
    }
    
    with open(archivo_salida, 'w', encoding='utf-8') as f:
        json.dump(datos_conteo, f, indent=2, ensure_ascii=False)
    
    print(f"💾 Conteo por tipo guardado en: {archivo_salida}")
    
    # Mostrar resumen
    print("\n" + "="*70)
    print("RESUMEN POR TIPO DE OBJETO")
    print("="*70)
    print(f"🔵 Botellas de plástico: {conteo['botellas_plastico']}")
    print(f"🟢 Botellas de vidrio: {conteo['botellas_vidrio']}")
    print(f"🔴 Latas de aluminio: {conteo['latas_aluminio']}")
    print(f"───────────────────────")
    print(f"📊 Total: {datos_conteo['total_objetos']} objetos")
    print("="*70 + "\n")

def guardar_imagen_con_detecciones(predicciones, nombre_imagen):
    """
    Guarda la imagen con las detecciones dibujadas (bounding boxes y etiquetas)
    en una carpeta 'resultados_imagenes'
    """
    if not os.path.exists(nombre_imagen):
        print(f"⚠️  No se pudo encontrar la imagen: {nombre_imagen}")
        return
    
    if not predicciones or len(predicciones) == 0:
        print(f"⚠️  No hay predicciones para visualizar")
        return
    
    try:
        # Crear carpeta de resultados si no existe
        carpeta_salida = "resultados_imagenes"
        os.makedirs(carpeta_salida, exist_ok=True)
        
        # Cargar imagen
        img = Image.open(nombre_imagen)
        draw = ImageDraw.Draw(img)
        
        # Intentar cargar una fuente, si falla usar la predeterminada
        try:
            # Tamaño de fuente proporcional al tamaño de la imagen
            font_size = max(12, int(min(img.width, img.height) * 0.02))
            font = ImageFont.truetype("arial.ttf", font_size)
            font_small = ImageFont.truetype("arial.ttf", font_size - 2)
        except:
            font = ImageFont.load_default()
            font_small = ImageFont.load_default()
        
        # Colores para cada tipo de objeto
        colores = {
            'botella_plastico': ('#2196F3', 'Botella Plástico'),  # Azul
            'botella_vidrio': ('#4CAF50', 'Botella Vidrio'),      # Verde
            'lata_aluminio': ('#F44336', 'Lata Aluminio'),        # Rojo
        }
        
        # Colores por defecto para clases no mapeadas
        color_default = ('#FF9800', 'Objeto')  # Naranja
        
        # Dibujar cada detección
        for i, pred in enumerate(predicciones, 1):
            # Extraer coordenadas
            x = pred.get('x', 0)
            y = pred.get('y', 0)
            width = pred.get('width', 0)
            height = pred.get('height', 0)
            
            # Calcular esquinas del bounding box
            left = x - width / 2
            top = y - height / 2
            right = x + width / 2
            bottom = y + height / 2
            
            # Obtener clase y confianza
            clase = pred.get('class', 'desconocido').lower()
            confidence = pred.get('confidence', 0)
            
            # Determinar color según la clase
            color_info = color_default
            for clave, info in colores.items():
                if clave in clase:
                    color_info = info
                    break
            
            color = color_info[0]
            nombre_clase = color_info[1]
            
            # Dibujar rectángulo (grosor proporcional)
            line_width = max(2, int(min(img.width, img.height) * 0.003))
            draw.rectangle([left, top, right, bottom], outline=color, width=line_width)
            
            # Preparar etiqueta
            etiqueta = f"#{i} {nombre_clase}"
            confianza_texto = f"{confidence*100:.1f}%"
            
            # Calcular tamaño del texto para el fondo
            bbox_text = draw.textbbox((0, 0), etiqueta, font=font)
            bbox_conf = draw.textbbox((0, 0), confianza_texto, font=font_small)
            text_width = max(bbox_text[2] - bbox_text[0], bbox_conf[2] - bbox_conf[0]) + 8
            text_height = (bbox_text[3] - bbox_text[1]) + (bbox_conf[3] - bbox_conf[1]) + 8
            
            # Posición de la etiqueta (arriba del bbox, o abajo si está en el borde superior)
            label_top = max(5, top - text_height - 5)
            label_bottom = label_top + text_height
            label_left = left
            label_right = label_left + text_width
            
            # Dibujar fondo de la etiqueta
            draw.rectangle([label_left, label_top, label_right, label_bottom], 
                          fill=color, outline=color)
            
            # Dibujar texto de la etiqueta
            text_y = label_top + 4
            draw.text((label_left + 4, text_y), etiqueta, fill='white', font=font)
            draw.text((label_left + 4, text_y + (bbox_text[3] - bbox_text[1])), 
                     confianza_texto, fill='white', font=font_small)
        
        # Guardar imagen
        nombre_base = Path(nombre_imagen).stem
        archivo_salida = os.path.join(carpeta_salida, f"detectado_{nombre_base}.jpg")
        img.save(archivo_salida, quality=95)
        
        print(f"📷 Imagen con detecciones guardada en: {archivo_salida}")
        
    except Exception as e:
        print(f"✗ Error al guardar imagen con detecciones: {e}")
        import traceback
        traceback.print_exc()

def main():
    """Función principal"""
    print("\n" + "="*70)
    print("🤖 SISTEMA DE DETECCIÓN DE RECICLABLES - ROBOFLOW WORKFLOW")
    print("="*70 + "\n")
    
    # Conectar con Roboflow
    client = conectar_cliente()
    
    # Imagen a analizar
    imagen = "bottle2.jpeg"
    
    # Permitir entrada del usuario
    usar_otra = input(f"¿Analizar '{imagen}'? (Enter para continuar, o escribe otra ruta): ").strip()
    if usar_otra:
        imagen = usar_otra.strip('"')
    
    print()
    
    # Realizar detección con workflow
    resultado = detectar_objetos_workflow(client, imagen)
    
    if resultado:
        # Guardar resultado completo
        guardar_json_completo(resultado, imagen)
        
        # Extraer predicciones
        predicciones = extraer_predicciones(resultado)
        
        if predicciones:
            # Mostrar en consola
            mostrar_resultados(predicciones)
            
            # Guardar predicciones
            guardar_json_predicciones(predicciones, imagen)
            
            # Contar por tipo
            conteo = contar_por_tipo(predicciones)
            guardar_json_conteo(conteo, imagen)
            
            # Guardar imagen con detecciones visualizadas
            guardar_imagen_con_detecciones(predicciones, imagen)
        else:
            print("⚠️  No se pudieron extraer predicciones del workflow")
            print("📄 Revisa el archivo workflow_completo_*.json para ver la estructura\n")
        
        print("✅ Proceso completado exitosamente\n")
    else:
        print("❌ No se pudo completar el análisis\n")

if __name__ == "__main__":
    main()


