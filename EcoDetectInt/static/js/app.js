// Elementos del DOM
const fileInput = document.getElementById('fileInput');
const imagePreview = document.getElementById('imagePreview');
const btnAnalizar = document.getElementById('btnAnalizar');
const uploadSection = document.getElementById('uploadSection');
const loading = document.getElementById('loading');
const resultados = document.getElementById('resultados');
const errorMsg = document.getElementById('errorMsg');

// Verificar estado de servicios
async function verificarEstado() {
    try {
        const response = await fetch('/estado');
        const estado = await response.json();
        
        document.getElementById('statusRoboflow').textContent = estado.roboflow;
        document.getElementById('statusFastapi').textContent = estado.fastapi;
        document.getElementById('statusRecompensas').textContent = estado.recompensas_api;
    } catch (error) {
        console.error('Error verificando estado:', error);
    }
}

// Medición de Interoperabilidad Efectiva (ISO/IEC 25010)
async function medirInteroperabilidad() {
    const resultadoIE = document.getElementById('resultadoIE');
    resultadoIE.style.display = 'none';

    // Resetear todas las pruebas
    for (let i = 1; i <= 10; i++) {
        const testItem = document.getElementById(`test${i}`);
        testItem.className = 'test-item pending';
        testItem.textContent = `Prueba ${i}`;
    }

    let exitosas = 0;
    let fallidas = 0;

    // Ejecutar 10 pruebas secuencialmente
    for (let i = 1; i <= 10; i++) {
        const testItem = document.getElementById(`test${i}`);
        testItem.className = 'test-item testing';
        testItem.textContent = `Probando ${i}...`;

        await new Promise(resolve => setTimeout(resolve, 300)); // Delay visual

        try {
            // Realizar llamada al endpoint de prueba de interoperabilidad
            const response = await fetch('/test-interoperabilidad', {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });

            if (response.ok) {
                const data = await response.json();
                
                // Verificar que al menos 2 de 3 servicios estén activos para considerar exitosa
                if (data.servicios_activos >= 2) {
                    exitosas++;
                    testItem.className = 'test-item success';
                    testItem.innerHTML = `✅ Prueba ${i}<br><small>${data.servicios_activos}/3 servicios</small>`;
                } else {
                    fallidas++;
                    testItem.className = 'test-item error';
                    testItem.innerHTML = `❌ Prueba ${i}<br><small>${data.servicios_activos}/3 servicios</small>`;
                }
            } else {
                fallidas++;
                testItem.className = 'test-item error';
                testItem.innerHTML = `❌ Prueba ${i}<br><small>Error HTTP</small>`;
            }
        } catch (error) {
            fallidas++;
            testItem.className = 'test-item error';
            testItem.innerHTML = `❌ Prueba ${i}<br><small>Sin respuesta</small>`;
        }

        await new Promise(resolve => setTimeout(resolve, 200)); // Delay entre pruebas
    }

    // Calcular y mostrar resultados
    mostrarResultadosIE(exitosas, fallidas);
}

function mostrarResultadosIE(exitosas, fallidas) {
    const total = 10;
    const porcentaje = (exitosas / total) * 100;

    const resultadoIE = document.getElementById('resultadoIE');
    const porcentajeIE = document.getElementById('porcentajeIE');
    const exitosasIE = document.getElementById('exitosasIE');
    const fallidasIE = document.getElementById('fallidasIE');
    const interpretacionIE = document.getElementById('interpretacionIE');

    porcentajeIE.textContent = `${porcentaje.toFixed(1)}%`;
    exitosasIE.textContent = exitosas;
    fallidasIE.textContent = fallidas;

    // Clasificar y colorear según el porcentaje
    if (porcentaje >= 90) {
        porcentajeIE.className = 'porcentaje-ie excelente';
        interpretacionIE.textContent = 'Excelente - Sistema altamente interoperable';
    } else if (porcentaje >= 70) {
        porcentajeIE.className = 'porcentaje-ie bueno';
        interpretacionIE.textContent = 'Bueno - Interoperabilidad adecuada';
    } else if (porcentaje >= 50) {
        porcentajeIE.className = 'porcentaje-ie regular';
        interpretacionIE.textContent = 'Regular - Requiere atención';
    } else {
        porcentajeIE.className = 'porcentaje-ie malo';
        interpretacionIE.textContent = 'Deficiente - Revisar servicios';
    }

    resultadoIE.style.display = 'block';
}

// Cargar recompensas
async function cargarRecompensas() {
    const loadingRecompensas = document.getElementById('loadingRecompensas');
    const errorRecompensas = document.getElementById('errorRecompensas');
    const recompensasGrid = document.getElementById('recompensasGrid');
    const sinRecompensas = document.getElementById('sinRecompensas');

    // Mostrar loading
    loadingRecompensas.classList.add('active');
    errorRecompensas.classList.remove('active');
    recompensasGrid.innerHTML = '';
    sinRecompensas.style.display = 'none';

    try {
        const response = await fetch('/recompensas');
        const data = await response.json();

        if (data.exito && data.recompensas && data.recompensas.length > 0) {
            mostrarRecompensas(data.recompensas);
        } else {
            sinRecompensas.style.display = 'block';
        }
    } catch (error) {
        console.error('Error cargando recompensas:', error);
        errorRecompensas.textContent = '❌ Error al cargar recompensas. Verifica que la API esté corriendo.';
        errorRecompensas.classList.add('active');
    } finally {
        loadingRecompensas.classList.remove('active');
    }
}

function mostrarRecompensas(recompensas) {
    const grid = document.getElementById('recompensasGrid');
    grid.innerHTML = '';

    // Emojis por defecto si no hay imagen
    const emojisDefault = ['🎁', '🏆', '🌟', '💎', '🎯', '🌿', '♻️', '🌍'];

    recompensas.forEach((recompensa, index) => {
        const card = document.createElement('div');
        card.className = 'recompensa-card';
        
        // Imagen o emoji
        let imagenHTML;
        if (recompensa.imagen_url && recompensa.imagen_url.trim() !== '') {
            imagenHTML = `<img src="${recompensa.imagen_url}" alt="${recompensa.nombre}" class="recompensa-imagen" 
                          onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                          <div class="recompensa-imagen" style="display: none;">${emojisDefault[index % emojisDefault.length]}</div>`;
        } else {
            imagenHTML = `<div class="recompensa-imagen">${emojisDefault[index % emojisDefault.length]}</div>`;
        }

        card.innerHTML = `
            ${imagenHTML}
            <div class="recompensa-nombre">${recompensa.nombre}</div>
            <div class="recompensa-descripcion">${recompensa.descripcion || 'Recompensa disponible'}</div>
            <div class="recompensa-puntos">🏆 ${recompensa.puntos} puntos</div>
            <button class="btn-canjear" onclick="simularCanje(\`${recompensa.nombre.replace(/`/g, '')}\`, ${recompensa.puntos})">
                Canjear
            </button>
        `;
        
        grid.appendChild(card);
    });
}

function simularCanje(nombre, puntos) {
    // Mostrar modal de confirmación
    const modalConfirmacion = document.getElementById('modalConfirmacion');
    const modalConfirmMsg = document.getElementById('modalConfirmMsg');
    const modalConfirmDetail = document.getElementById('modalConfirmDetail');
    const btnConfirmar = document.getElementById('btnConfirmarCanje');

    modalConfirmMsg.textContent = `¿Deseas canjear "${nombre}"?`;
    modalConfirmDetail.innerHTML = `
        <div class="modal-detail-item">
            <span class="modal-detail-label">Recompensa:</span>
            <span class="modal-detail-value">${nombre}</span>
        </div>
        <div class="modal-detail-item">
            <span class="modal-detail-label">Costo:</span>
            <span class="modal-detail-value">${puntos} puntos</span>
        </div>
        <div class="modal-detail-item">
            <span class="modal-detail-label">Saldo después del canje:</span>
            <span class="modal-detail-value" style="color: #11998e;">-- puntos</span>
        </div>
    `;

    modalConfirmacion.classList.add('active');

    // Configurar botón de confirmar
    btnConfirmar.onclick = function() {
        cerrarModal('modalConfirmacion');
        procesarCanje(nombre, puntos);
    };
}

function procesarCanje(nombre, puntos) {
    // Simular procesamiento (delay de 500ms)
    setTimeout(() => {
        mostrarExito(nombre, puntos);
    }, 500);
}

function mostrarExito(nombre, puntos) {
    const modalExito = document.getElementById('modalExito');
    const modalExitoMsg = document.getElementById('modalExitoMsg');
    const modalExitoDetail = document.getElementById('modalExitoDetail');

    const codigoTransaccion = 'ECO' + Math.random().toString(36).substr(2, 9).toUpperCase();
    const fecha = new Date().toLocaleDateString('es-ES', { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });

    modalExitoMsg.textContent = `Has canjeado exitosamente: ${nombre}`;
    modalExitoDetail.innerHTML = `
        <div class="modal-detail-item">
            <span class="modal-detail-label">Recompensa:</span>
            <span class="modal-detail-value">${nombre}</span>
        </div>
        <div class="modal-detail-item">
            <span class="modal-detail-label">Puntos utilizados:</span>
            <span class="modal-detail-value">${puntos} puntos</span>
        </div>
        <div class="modal-detail-item">
            <span class="modal-detail-label">Código de canje:</span>
            <span class="modal-detail-value" style="color: #11998e;">${codigoTransaccion}</span>
        </div>
        <div class="modal-detail-item">
            <span class="modal-detail-label">Fecha:</span>
            <span class="modal-detail-value">${fecha}</span>
        </div>
    `;

    modalExito.classList.add('active');
}

function cerrarModal(modalId) {
    const modal = document.getElementById(modalId);
    modal.classList.remove('active');
}

// Cerrar modal al hacer clic fuera
window.onclick = function(event) {
    if (event.target.classList.contains('modal')) {
        event.target.classList.remove('active');
    }
}

// Drag and drop
uploadSection.addEventListener('dragover', (e) => {
    e.preventDefault();
    uploadSection.classList.add('dragover');
});

uploadSection.addEventListener('dragleave', () => {
    uploadSection.classList.remove('dragover');
});

uploadSection.addEventListener('drop', (e) => {
    e.preventDefault();
    uploadSection.classList.remove('dragover');
    
    const files = e.dataTransfer.files;
    if (files.length > 0) {
        fileInput.files = files;
        previewImage(files[0]);
    }
});

// Preview de imagen
fileInput.addEventListener('change', function() {
    if (this.files && this.files[0]) {
        previewImage(this.files[0]);
    }
});

function previewImage(file) {
    const reader = new FileReader();
    reader.onload = function(e) {
        imagePreview.src = e.target.result;
        imagePreview.style.display = 'block';
        btnAnalizar.disabled = false;
    }
    reader.readAsDataURL(file);
}

// Analizar imagen
btnAnalizar.addEventListener('click', async function() {
    const file = fileInput.files[0];
    if (!file) {
        mostrarError('Por favor selecciona una imagen');
        return;
    }

    // Preparar FormData
    const formData = new FormData();
    formData.append('imagen', file);

    // Mostrar loading
    loading.classList.add('active');
    resultados.classList.remove('active');
    errorMsg.classList.remove('active');
    btnAnalizar.disabled = true;

    try {
        // Enviar al servidor
        const response = await fetch('/analizar', {
            method: 'POST',
            body: formData
        });

        const data = await response.json();

        if (response.ok && data.exito) {
            mostrarResultados(data);
        } else {
            mostrarError(data.error || data.mensaje || 'Error procesando la imagen');
        }
    } catch (error) {
        console.error('Error:', error);
        mostrarError('Error de conexión. Asegúrate de que FastAPI esté corriendo.');
    } finally {
        loading.classList.remove('active');
        btnAnalizar.disabled = false;
    }
});

function mostrarResultados(data) {
    // Si no hay impacto (no se detectó nada)
    if (!data.impacto) {
        mostrarError(data.mensaje || 'No se detectaron objetos reciclables');
        return;
    }

    // Mostrar resumen total
    const resumen = data.impacto.resumen_total;
    document.getElementById('totalDetectado').textContent = data.total_detectado;
    document.getElementById('pesoTotal').textContent = resumen.peso_total_gramos.toFixed(1);
    document.getElementById('co2Total').textContent = resumen.co2_total_evitado_kg.toFixed(3);
    document.getElementById('energiaTotal').textContent = resumen.energia_total_ahorrada_kwh.toFixed(3);
    document.getElementById('puntosTotal').textContent = resumen.puntos_ecologicos_totales;

    // Mostrar desglose por material
    const desglose = document.getElementById('desgloseMateriales');
    desglose.innerHTML = '';

    const iconos = {
        'botella_plastico': '🥤',
        'botella_vidrio': '🍾',
        'lata_aluminio': '🥫'
    };

    const nombres = {
        'botella_plastico': 'Botellas de Plástico',
        'botella_vidrio': 'Botellas de Vidrio',
        'lata_aluminio': 'Latas de Aluminio'
    };

    data.impacto.desglose_por_material.forEach(item => {
        const div = document.createElement('div');
        div.className = 'deteccion-item';
        div.innerHTML = `
            <div class="material-icon">${iconos[item.material]}</div>
            <h3>${nombres[item.material]}</h3>
            <p><strong>Cantidad:</strong> ${item.cantidad} unidades</p>
            <p><strong>Peso:</strong> ${item.peso_estimado_gramos.toFixed(1)} g</p>
            <p><strong>CO₂ evitado:</strong> ${item.co2_evitado_kg.toFixed(3)} kg</p>
            <p><strong>Energía:</strong> ${item.energia_ahorrada_kwh.toFixed(3)} kWh</p>
            <p style="font-size: 1.2em; margin-top: 10px;"><strong>🏆 ${item.puntos_ecologicos} puntos</strong></p>
        `;
        desglose.appendChild(div);
    });

    resultados.classList.add('active');
}

function mostrarError(mensaje) {
    errorMsg.textContent = '❌ ' + mensaje;
    errorMsg.classList.add('active');
    setTimeout(() => {
        errorMsg.classList.remove('active');
    }, 5000);
}

// Verificar estado al cargar
verificarEstado();
setInterval(verificarEstado, 30000); // Cada 30 segundos

// Cargar recompensas al iniciar
cargarRecompensas();
