import streamlit as st
from pymongo import MongoClient
from dotenv import load_dotenv
import os
import re

load_dotenv()

# Conexión a MongoDB
MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["EcoDetectDB"]
recompensas = db["recompensas"]

# Configuración de página
st.set_page_config(page_title="EcoDetect Recompensas", page_icon="🌱", layout="wide")

# Estilos personalizados
st.markdown("""
<style>
    .stImage {
        border-radius: 10px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
    .reward-card {
        background-color: #f0f2f6;
        padding: 20px;
        border-radius: 10px;
        margin-bottom: 20px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }
</style>
""", unsafe_allow_html=True)

st.title("🌱 Sistema Web de Recompensas - EcoDetect")

# Función para validar y corregir URLs de Imgur
def validar_url_imgur(url):
    """Valida y corrige URLs de Imgur para asegurar que sean directas"""
    if not url or url.strip() == "":
        return None
    
    # Si es una URL de imgur sin extensión, agregar .jpg
    if "imgur.com" in url and not any(ext in url for ext in ['.jpg', '.png', '.gif', '.jpeg']):
        # Extraer el ID de la imagen
        match = re.search(r'imgur\.com/([a-zA-Z0-9]+)', url)
        if match:
            img_id = match.group(1)
            return f"https://i.imgur.com/{img_id}.jpg"
    
    # Si ya tiene i.imgur.com, está bien
    if "i.imgur.com" in url:
        return url
    
    # Si es imgur.com/gallery o imgur.com/a, convertir a directa
    if "imgur.com/gallery/" in url or "imgur.com/a/" in url:
        match = re.search(r'[/](gallery|a)/([a-zA-Z0-9]+)', url)
        if match:
            img_id = match.group(2)
            return f"https://i.imgur.com/{img_id}.jpg"
    
    return url

menu = ["Crear recompensa", "Ver recompensas", "Editar recompensa", "Eliminar recompensa"]
choice = st.sidebar.selectbox("Menú", menu)

# --- Crear recompensa ---
if choice == "Crear recompensa":
    st.header("Crear nueva recompensa")

    # Mostrar mensaje de éxito si existe
    if st.session_state.get("mostrar_exito", False):
        st.success("✅ Recompensa creada exitosamente")
        st.session_state["mostrar_exito"] = False
    
    # Botón para limpiar campos
    if st.button("🆕 Nuevo producto"):
        st.session_state["last_nombre"] = ""
        st.session_state["last_descripcion"] = ""
        st.session_state["last_puntos"] = 0
        st.session_state["last_imagen_url"] = ""
        st.rerun()
    
    # Valores por defecto
    nombre_default = st.session_state.get("last_nombre", "")
    descripcion_default = st.session_state.get("last_descripcion", "")
    puntos_default = st.session_state.get("last_puntos", 0)
    imagen_url_default = st.session_state.get("last_imagen_url", "")

    nombre = st.text_input("Nombre de la recompensa", value=nombre_default)
    descripcion = st.text_area("Descripción", value=descripcion_default)
    puntos = st.number_input("Puntos necesarios", min_value=0, value=puntos_default)
    imagen_url = st.text_input("URL de imagen de Imgur (ejemplo: https://i.imgur.com/ABC123.jpg)", value=imagen_url_default)
    
    # Mostrar preview de la imagen si se ingresa URL
    if imagen_url:
        st.write("**Vista previa:**")
        url_corregida = validar_url_imgur(imagen_url)
        if url_corregida:
            st.info(f"URL corregida: {url_corregida}")
            try:
                st.image(url_corregida, width=200)
            except:
                st.warning("⚠️ No se pudo cargar la imagen. Verifica la URL.")

    if st.button("💾 Guardar"):
        if not nombre or not descripcion:
            st.error("❌ Por favor completa el nombre y la descripción")
        else:
            url_final = validar_url_imgur(imagen_url) if imagen_url else ""
            nueva = {
                "nombre": nombre,
                "descripcion": descripcion,
                "puntos": puntos,
                "imagen_url": url_final
            }
            recompensas.insert_one(nueva)
            
            # Limpiar campos y mostrar mensaje de éxito
            st.session_state["last_nombre"] = ""
            st.session_state["last_descripcion"] = ""
            st.session_state["last_puntos"] = 0
            st.session_state["last_imagen_url"] = ""
            st.session_state["mostrar_exito"] = True
            st.rerun()
    
    # Guardar valores actuales para persistencia (solo si el usuario está escribiendo)
    if nombre != nombre_default:
        st.session_state["last_nombre"] = nombre
    if descripcion != descripcion_default:
        st.session_state["last_descripcion"] = descripcion
    if puntos != puntos_default:
        st.session_state["last_puntos"] = puntos
    if imagen_url != imagen_url_default:
        st.session_state["last_imagen_url"] = imagen_url

# --- Ver recompensas ---
elif choice == "Ver recompensas":
    st.header("📦 Catálogo de Recompensas")

    lista = list(recompensas.find())
    
    if not lista:
        st.info("No hay recompensas registradas aún. ¡Crea la primera!")
    else:
        # Mostrar en columnas para mejor diseño
        cols = st.columns(3)
        
        for idx, r in enumerate(lista):
            with cols[idx % 3]:
                st.markdown(f"""
                <div class="reward-card">
                    <h3 style="color: #1f77b4;">{r['nombre']}</h3>
                </div>
                """, unsafe_allow_html=True)
                
                # Validar y mostrar imagen
                url_imagen = r.get("imagen_url", "")
                if url_imagen:
                    url_corregida = validar_url_imgur(url_imagen)
                    try:
                        st.image(url_corregida, width='stretch')
                    except:
                        st.image("https://via.placeholder.com/300x200?text=Imagen+no+disponible", width='stretch')
                        st.caption("⚠️ Imagen no disponible")
                else:
                    st.image("https://via.placeholder.com/300x200?text=Sin+imagen", width='stretch')
                
                st.write(f"**Descripción:** {r.get('descripcion', 'Sin descripción')}")
                st.write(f"**Puntos necesarios:** 🌟 {r.get('puntos', 0)}")
                st.write("---")

# --- Editar recompensa ---
elif choice == "Editar recompensa":
    st.header("✏️ Editar recompensa")

    from bson.objectid import ObjectId
    
    lista = list(recompensas.find())
    
    if not lista:
        st.warning("No hay recompensas para editar")
    else:
        nombres = [f"{r['_id']} - {r['nombre']}" for r in lista]

        opcion = st.selectbox("Selecciona una recompensa", nombres)

        id_seleccionado = opcion.split(" - ")[0]
        doc = recompensas.find_one({"_id": ObjectId(id_seleccionado)})

        col1, col2 = st.columns([2, 1])
        
        with col1:
            nombre = st.text_input("Nombre", doc["nombre"])
            descripcion = st.text_area("Descripción", doc["descripcion"])
            puntos = st.number_input("Puntos necesarios", value=int(doc["puntos"]))
            imagen_url = st.text_input("URL de imagen de Imgur", doc.get("imagen_url", ""))
        
        with col2:
            st.write("**Vista previa actual:**")
            url_actual = doc.get("imagen_url", "")
            if url_actual:
                url_corregida = validar_url_imgur(url_actual)
                try:
                    st.image(url_corregida, width=200)
                except:
                    st.warning("Imagen no disponible")
            else:
                st.info("Sin imagen")

        if st.button("💾 Actualizar"):
            url_final = validar_url_imgur(imagen_url) if imagen_url else ""
            recompensas.update_one(
                {"_id": ObjectId(id_seleccionado)},
                {"$set": {
                    "nombre": nombre,
                    "descripcion": descripcion,
                    "puntos": puntos,
                    "imagen_url": url_final
                }}
            )
            st.success("✅ Recompensa actualizada correctamente")
            st.rerun()

# --- Eliminar recompensa ---
elif choice == "Eliminar recompensa":
    st.header("🗑️ Eliminar recompensa")

    from bson.objectid import ObjectId

    lista = list(recompensas.find())
    
    if not lista:
        st.warning("No hay recompensas para eliminar")
    else:
        nombres = [f"{r['_id']} - {r['nombre']}" for r in lista]

        opcion = st.selectbox("Selecciona una recompensa", nombres)
        id_seleccionado = opcion.split(" - ")[0]
        
        # Mostrar preview antes de eliminar
        doc = recompensas.find_one({"_id": ObjectId(id_seleccionado)})
        
        st.warning(f"⚠️ Estás a punto de eliminar: **{doc['nombre']}**")
        
        col1, col2 = st.columns(2)
        with col1:
            st.write(f"**Descripción:** {doc.get('descripcion', 'N/A')}")
            st.write(f"**Puntos:** {doc.get('puntos', 0)}")
        
        with col2:
            url = doc.get("imagen_url", "")
            if url:
                try:
                    url_corregida = validar_url_imgur(url)
                    st.image(url_corregida, width=150)
                except:
                    st.write("Sin imagen")

        if st.button("❌ Confirmar eliminación", type="primary"):
            recompensas.delete_one({"_id": ObjectId(id_seleccionado)})
            st.success("✅ Recompensa eliminada")
            st.rerun()