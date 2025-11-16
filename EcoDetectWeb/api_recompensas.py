from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pymongo import MongoClient
from dotenv import load_dotenv
import os

load_dotenv()

# Verificar si la variable MONGO_URI está configurada
if not os.getenv("MONGO_URI"):
    raise RuntimeError("La variable de entorno 'MONGO_URI' no está configurada. Asegúrate de crear un archivo .env y solicita el URI de MongoDB al equipo de desarrollo")

app = FastAPI(
    title="EcoDetect API",
    description="API de solo lectura para recompensas - Consumo desde Flutter",
    version="1.0.0"
)

# CORS: Permite que Flutter consuma la API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET"],
    allow_headers=["*"],
)

# Conexión MongoDB
client = MongoClient(os.getenv("MONGO_URI"))
db = client["EcoDetectDB"]
recompensas = db["recompensas"]

# Endpoints de solo lectura (GET)
@app.get("/")
def root():
    return {
        "message": "API EcoDetect - Recompensas (Solo lectura)",
        "version": "1.0.0",
        "endpoint": "/recompensas - GET todas las recompensas"
    }

@app.get("/recompensas")
def obtener_recompensas():
    """
    Obtiene todas las recompensas para mostrar en Flutter.
    Retorna JSON con: id, nombre, descripcion, puntos, imagen_url
    """
    try:
        lista = list(recompensas.find())
        resultado = []
        for r in lista:
            resultado.append({
                "id": str(r["_id"]),
                "nombre": r.get("nombre", ""),
                "descripcion": r.get("descripcion", ""),
                "puntos": r.get("puntos", 0),
                "imagen_url": r.get("imagen_url", "")
            })
        return resultado
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener recompensas: {str(e)}")
