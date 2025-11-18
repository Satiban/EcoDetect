"""
calculos.py
Contiene toda la lógica de cálculo ambiental y la regresión lineal
"""

import numpy as np
from sklearn.linear_model import LinearRegression

# Pesos promedio en gramos por unidad
PESOS_PROMEDIO = {
    "botella_plastico": 25,  # gramos
    "botella_vidrio": 250,   # gramos
    "lata_aluminio": 15      # gramos
}

# Factores ambientales (valores basados en estudios de reciclaje)
# CO2 evitado en kg por kg de material reciclado
FACTOR_CO2 = {
    "botella_plastico": 2.5,   # 2.5 kg CO2 por kg de plástico
    "botella_vidrio": 0.3,     # 0.3 kg CO2 por kg de vidrio
    "lata_aluminio": 9.0       # 9 kg CO2 por kg de aluminio
}

# Energía ahorrada en kWh por kg de material reciclado
FACTOR_ENERGIA = {
    "botella_plastico": 5.5,   # 5.5 kWh por kg de plástico
    "botella_vidrio": 0.4,     # 0.4 kWh por kg de vidrio
    "lata_aluminio": 14.0      # 14 kWh por kg de aluminio
}

# Puntos ecológicos base por unidad
PUNTOS_BASE = {
    "botella_plastico": 7,
    "botella_vidrio": 9,
    "lata_aluminio": 11
}


class CalculadorAmbiental:
    """Clase para calcular métricas ambientales usando regresión lineal"""
    
    def __init__(self):
        # Inicializar modelos de regresión lineal para cada tipo de material
        self.modelos_peso = {}
        self._entrenar_modelos()
    
    def _entrenar_modelos(self):
        """
        Entrena modelos de regresión lineal determinística.
        La regresión lineal permite ajustar el peso según la cantidad de elementos.
        """
        for material, peso_unitario in PESOS_PROMEDIO.items():
            # Crear datos de entrenamiento: cantidad de elementos vs peso total
            # Simulamos datos lineales: 1 elemento = peso_unitario, 2 elementos = 2*peso_unitario, etc.
            X_train = np.array([[1], [2], [5], [10], [20], [50], [100]])
            y_train = X_train.flatten() * peso_unitario
            
            # Entrenar modelo de regresión lineal
            modelo = LinearRegression()
            modelo.fit(X_train, y_train)
            
            self.modelos_peso[material] = modelo
    
    def calcular_peso_estimado(self, material: str, cantidad: int) -> float:
        """
        Calcula el peso estimado usando regresión lineal.
        
        Args:
            material: Tipo de material detectado
            cantidad: Número de elementos detectados
        
        Returns:
            Peso estimado en gramos
        """
        if material not in self.modelos_peso:
            raise ValueError(f"Material desconocido: {material}")
        
        # Predecir peso usando el modelo entrenado
        X_pred = np.array([[cantidad]])
        peso_estimado = self.modelos_peso[material].predict(X_pred)[0]
        
        return round(peso_estimado, 2)
    
    def calcular_co2_evitado(self, material: str, peso_gramos: float) -> float:
        """
        Calcula el CO2 evitado en kg.
        
        Args:
            material: Tipo de material
            peso_gramos: Peso en gramos
        
        Returns:
            CO2 evitado en kilogramos
        """
        peso_kg = peso_gramos / 1000
        co2_evitado = peso_kg * FACTOR_CO2[material]
        return round(co2_evitado, 3)
    
    def calcular_energia_ahorrada(self, material: str, peso_gramos: float) -> float:
        """
        Calcula la energía ahorrada en kWh.
        
        Args:
            material: Tipo de material
            peso_gramos: Peso en gramos
        
        Returns:
            Energía ahorrada en kWh
        """
        peso_kg = peso_gramos / 1000
        energia_ahorrada = peso_kg * FACTOR_ENERGIA[material]
        return round(energia_ahorrada, 3)
    
    def calcular_puntos_ecologicos(self, material: str, cantidad: int, peso_gramos: float) -> int:
        """
        Calcula los puntos ecológicos ganados.
        Los puntos se ajustan según la cantidad y el peso del material.
        
        Args:
            material: Tipo de material
            cantidad: Cantidad de elementos
            peso_gramos: Peso total en gramos
        
        Returns:
            Puntos ecológicos ganados
        """
        # Puntos base por cantidad
        puntos_base = PUNTOS_BASE[material] * cantidad
        
        # Bonus por peso (más peso = más puntos)
        bonus_peso = int(peso_gramos / 100)  # 1 punto extra por cada 100g
        
        puntos_totales = puntos_base + bonus_peso
        return max(puntos_totales, cantidad)  # Mínimo 1 punto por elemento
    
    def procesar_deteccion(self, material: str, cantidad: int) -> dict:
        """
        Procesa una detección completa y retorna todas las métricas.
        
        Args:
            material: Tipo de material detectado
            cantidad: Cantidad de elementos detectados
        
        Returns:
            Diccionario con todas las métricas calculadas
        """
        # Calcular peso usando regresión lineal
        peso_estimado = self.calcular_peso_estimado(material, cantidad)
        
        # Calcular métricas ambientales
        co2_evitado = self.calcular_co2_evitado(material, peso_estimado)
        energia_ahorrada = self.calcular_energia_ahorrada(material, peso_estimado)
        puntos_ecologicos = self.calcular_puntos_ecologicos(material, cantidad, peso_estimado)
        
        return {
            "material": material,
            "cantidad": cantidad,
            "peso_estimado_gramos": peso_estimado,
            "co2_evitado_kg": co2_evitado,
            "energia_ahorrada_kwh": energia_ahorrada,
            "puntos_ecologicos": puntos_ecologicos
        }
    
    def procesar_multiples_detecciones(self, detecciones: list) -> dict:
        """
        Procesa múltiples detecciones y retorna métricas consolidadas.
        
        Args:
            detecciones: Lista de diccionarios con 'material' y 'cantidad'
        
        Returns:
            Diccionario con métricas totales y desglose por material
        """
        resultados_individuales = []
        
        # Totales acumulados
        peso_total = 0
        co2_total = 0
        energia_total = 0
        puntos_totales = 0
        
        # Procesar cada detección
        for deteccion in detecciones:
            material = deteccion["material"]
            cantidad = deteccion["cantidad"]
            
            resultado = self.procesar_deteccion(material, cantidad)
            resultados_individuales.append(resultado)
            
            # Acumular totales
            peso_total += resultado["peso_estimado_gramos"]
            co2_total += resultado["co2_evitado_kg"]
            energia_total += resultado["energia_ahorrada_kwh"]
            puntos_totales += resultado["puntos_ecologicos"]
        
        return {
            "resumen_total": {
                "peso_total_gramos": round(peso_total, 2),
                "co2_total_evitado_kg": round(co2_total, 3),
                "energia_total_ahorrada_kwh": round(energia_total, 3),
                "puntos_ecologicos_totales": puntos_totales
            },
            "desglose_por_material": resultados_individuales
        }