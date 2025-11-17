# README - Microservicio de Cálculo Ambiental

Este microservicio permite calcular el impacto ambiental de materiales reciclables mediante modelos de regresión lineal. Recibe json con elemento y cantidad y retorna peso estimado, CO2 evitado, energía ahorrada y puntos ecológicos.

# Ejecución
python main.py http://localhost:8000/docs

# Verificación del servicio
GET /health -> http://localhost:8000/health
Devuelve "ok" para confirmar que el servicio está activo.

# Ver Materiales soportados
GET /materiales -> http://localhost:8000/materiales
Devuelve los tipos de materiales aceptados y sus factores ambientales.

# Cálculo múltiple - (es un calculo simple en un for)
POST /calcular-impacto -> http://localhost:8000/calcular-impacto
Ejemplo de entrada:
{
  "detecciones": [
    {"material": "botella_plastico", "cantidad": 5},
    {"material": "lata_aluminio", "cantidad": 2}
  ]
}

# Cálculo simple
POST /calcular-simple?material=botella_plastico&cantidad=3 -> http://localhost:8000/calcular-simple?material=lata_aluminio&cantidad=4
# Ejemplo de respuesta
{
  "peso_total_gramos": 185,
  "co2_total_evitado_kg": 0.42,
  "puntos_ecologicos_totales": 19
}

# Fin del README
