"""
modelos.py
Define la estructura de los JSON que va a recibir y enviar
"""

from pydantic import BaseModel, Field, validator
from typing import List, Literal

# Tipos de materiales permitidos
TipoMaterial = Literal["botella_plastico", "botella_vidrio", "lata_aluminio"]

class DeteccionMaterial(BaseModel):
    """Modelo para una detección individual de material"""
    material: TipoMaterial = Field(
        ...,
        description="Tipo de material detectado",
        examples=["botella_plastico"]
    )
    cantidad: int = Field(
        ...,
        gt=0,
        description="Cantidad de elementos detectados (debe ser mayor a 0)",
        examples=[5]
    )
    
    @validator('cantidad')
    def validar_cantidad_positiva(cls, v):
        if v <= 0:
            raise ValueError('La cantidad debe ser mayor a 0')
        return v


class SolicitudCalculo(BaseModel):
    """Modelo para la solicitud de cálculo ambiental"""
    detecciones: List[DeteccionMaterial] = Field(
        ...,
        min_items=1,
        description="Lista de materiales detectados con sus cantidades",
        examples=[[
            {"material": "botella_plastico", "cantidad": 3},
            {"material": "lata_aluminio", "cantidad": 2}
        ]]
    )
    
    @validator('detecciones')
    def validar_detecciones_no_vacias(cls, v):
        if not v:
            raise ValueError('Debe proporcionar al menos una detección')
        return v


class ResultadoMaterial(BaseModel):
    """Resultado del cálculo para un material específico"""
    material: str = Field(..., description="Tipo de material")
    cantidad: int = Field(..., description="Cantidad de elementos")
    peso_estimado_gramos: float = Field(..., description="Peso estimado en gramos")
    co2_evitado_kg: float = Field(..., description="CO2 evitado en kilogramos")
    energia_ahorrada_kwh: float = Field(..., description="Energía ahorrada en kWh")
    puntos_ecologicos: int = Field(..., description="Puntos ecológicos ganados")


class ResumenTotal(BaseModel):
    """Resumen consolidado de todas las detecciones"""
    peso_total_gramos: float = Field(..., description="Peso total en gramos")
    co2_total_evitado_kg: float = Field(..., description="CO2 total evitado en kg")
    energia_total_ahorrada_kwh: float = Field(..., description="Energía total ahorrada en kWh")
    puntos_ecologicos_totales: int = Field(..., description="Puntos ecológicos totales")


class RespuestaCalculo(BaseModel):
    """Respuesta completa del cálculo ambiental"""
    exito: bool = Field(default=True, description="Indica si el cálculo fue exitoso")
    mensaje: str = Field(default="Cálculo realizado exitosamente", description="Mensaje informativo")
    resumen_total: ResumenTotal = Field(..., description="Resumen consolidado de métricas")
    desglose_por_material: List[ResultadoMaterial] = Field(..., description="Detalle por cada material")


class ErrorRespuesta(BaseModel):
    """Modelo para respuestas de error"""
    exito: bool = Field(default=False)
    mensaje: str = Field(..., description="Descripción del error")
    detalle: str = Field(default="", description="Detalle adicional del error")