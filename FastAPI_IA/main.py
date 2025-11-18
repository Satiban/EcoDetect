"""
main.py
Servidor FastAPI que expone el endpoint
"""
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging

from modelos import (
    SolicitudCalculo,
    RespuestaCalculo,
    ErrorRespuesta,
    ResumenTotal,
    ResultadoMaterial
)
from calculos import CalculadorAmbiental

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Crear instancia de FastAPI
app = FastAPI(
    title="Microservicio de Cálculo Ambiental",
    description="API para calcular métricas ambientales de materiales reciclables usando IA (Regresión Lineal)",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configurar CORS para permitir llamadas desde Flutter y otros clientes
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especifica los dominios permitidos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inicializar el calculador ambiental (se entrena al iniciar)
calculador = CalculadorAmbiental()
logger.info("✅ Modelos de regresión lineal entrenados correctamente")


@app.get("/", tags=["Root"])
async def root():
    """Endpoint raíz con información del servicio"""
    return {
        "servicio": "Microservicio de Cálculo Ambiental",
        "version": "1.0.0",
        "estado": "activo",
        "descripcion": "API para calcular impacto ambiental de materiales reciclables",
        "materiales_soportados": [
            "botella_plastico",
            "botella_vidrio",
            "lata_aluminio"
        ],
        "documentacion": "/docs"
    }


@app.get("/health", tags=["Health"])
async def health_check():
    """Verificar el estado del servicio"""
    return {
        "status": "healthy",
        "modelo_ia": "regresion_lineal",
        "materiales_entrenados": list(calculador.modelos_peso.keys())
    }


@app.post(
    "/calcular-impacto",
    response_model=RespuestaCalculo,
    status_code=status.HTTP_200_OK,
    tags=["Cálculos Ambientales"],
    summary="Calcular impacto ambiental de materiales reciclables",
    description="""
    Recibe un JSON con materiales detectados y sus cantidades, 
    y retorna las métricas ambientales calculadas usando regresión lineal:
    
    - **Peso estimado** (en gramos)
    - **CO₂ evitado** (en kilogramos)
    - **Energía ahorrada** (en kWh)
    - **Puntos ecológicos** (recompensas para el usuario)
    
    Los cálculos se realizan usando modelos de regresión lineal entrenados
    para predecir el peso según la cantidad de elementos detectados.
    """
)
async def calcular_impacto_ambiental(solicitud: SolicitudCalculo):
    """
    Endpoint principal para calcular el impacto ambiental.
    
    Args:
        solicitud: JSON con lista de detecciones (material y cantidad)
    
    Returns:
        JSON con resumen total y desglose por material
    
    Raises:
        HTTPException: Si hay un error en el procesamiento
    """
    try:
        logger.info(f"📊 Procesando {len(solicitud.detecciones)} detección(es)")
        
        # Convertir detecciones a formato dict para el calculador
        detecciones_dict = [
            {
                "material": det.material,
                "cantidad": det.cantidad
            }
            for det in solicitud.detecciones
        ]
        
        # Procesar con el calculador ambiental
        resultado = calculador.procesar_multiples_detecciones(detecciones_dict)
        
        # Construir respuesta estructurada
        respuesta = RespuestaCalculo(
            exito=True,
            mensaje="Cálculo realizado exitosamente",
            resumen_total=ResumenTotal(**resultado["resumen_total"]),
            desglose_por_material=[
                ResultadoMaterial(**item) 
                for item in resultado["desglose_por_material"]
            ]
        )
        
        logger.info(f"✅ Cálculo completado: {respuesta.resumen_total.puntos_ecologicos_totales} puntos totales")
        
        return respuesta
        
    except ValueError as ve:
        logger.error(f"❌ Error de validación: {str(ve)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "exito": False,
                "mensaje": "Material desconocido o datos inválidos",
                "detalle": str(ve)
            }
        )
    
    except Exception as e:
        logger.error(f"❌ Error inesperado: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "exito": False,
                "mensaje": "Error interno del servidor",
                "detalle": str(e)
            }
        )


@app.post(
    "/calcular-simple",
    tags=["Cálculos Ambientales"],
    summary="Cálculo simple para un solo tipo de material",
    description="Endpoint simplificado para calcular métricas de un único material"
)
async def calcular_simple(material: str, cantidad: int):
    """
    Endpoint simplificado para un solo material.
    
    Ejemplo: /calcular-simple?material=botella_plastico&cantidad=5
    """
    try:
        # Validar material
        materiales_validos = ["botella_plastico", "botella_vidrio", "lata_aluminio"]
        if material not in materiales_validos:
            raise HTTPException(
                status_code=400,
                detail=f"Material inválido. Opciones: {materiales_validos}"
            )
        
        if cantidad <= 0:
            raise HTTPException(
                status_code=400,
                detail="La cantidad debe ser mayor a 0"
            )
        
        # Procesar detección
        resultado = calculador.procesar_deteccion(material, cantidad)
        
        return {
            "exito": True,
            "resultado": resultado
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail={"exito": False, "mensaje": str(e)}
        )


@app.get("/materiales", tags=["Información"])
async def obtener_materiales_soportados():
    """Obtener información de los materiales soportados y sus factores"""
    from calculos import PESOS_PROMEDIO, FACTOR_CO2, FACTOR_ENERGIA, PUNTOS_BASE
    
    materiales_info = []
    for material in PESOS_PROMEDIO.keys():
        materiales_info.append({
            "nombre": material,
            "peso_promedio_gr": PESOS_PROMEDIO[material],
            "co2_evitado_kg_por_kg": FACTOR_CO2[material],
            "energia_ahorrada_kwh_por_kg": FACTOR_ENERGIA[material],
            "puntos_base_por_unidad": PUNTOS_BASE[material]
        })
    
    return {
        "materiales_soportados": materiales_info,
        "total_materiales": len(materiales_info)
    }


# Manejo de errores global
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Manejador global de excepciones"""
    logger.error(f"Error no manejado: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={
            "exito": False,
            "mensaje": "Error interno del servidor",
            "detalle": str(exc)
        }
    )


if __name__ == "__main__":
    import uvicorn
    
    # Ejecutar el servidor
    logger.info("🚀 Iniciando servidor FastAPI...")
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,  # Recarga automática en desarrollo
        log_level="info"
    )