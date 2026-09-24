/**
 * RESGUARDO C5 - GESTIÓN Y DESPACHO DE INCIDENTES EN TIEMPO REAL
 * Integración de Reportes Ciudadanos, Triaje y Transmisión de Estado
 */

let allReports = [];
let allEmergencies = [];
let currentSelectedReport = null;
let currentFilter = {
  search: '',
  sector: 'all',
  severity: 'all',
};

document.addEventListener('DOMContentLoaded', () => {
  initIncidentsPage();
  setupEventListeners();

  // Polling cada 12 segundos para nuevos reportes de la app ciudadana
  setInterval(() => {
    loadLiveReportsData(false);
  }, 12000);
});

async function initIncidentsPage() {
  await loadLiveReportsData(true);
}

async function loadLiveReportsData(initial = false) {
  try {
    const [reportsData, emergenciesData] = await Promise.all([
      ApiClient.get('/reports'),
      ApiClient.get('/emergencies'),
    ]);

    allReports = Array.isArray(reportsData) ? reportsData : [];
    allEmergencies = Array.isArray(emergenciesData) ? emergenciesData : [];

    updateKpis();
    renderTacticalQueue();

    if (initial && allReports.length > 0) {
      selectReport(allReports[0].id);
    } else if (currentSelectedReport) {
      // Refresh current selected report if still present
      const updated = allReports.find(r => r.id === currentSelectedReport.id);
      if (updated) {
        selectReport(updated.id);
      }
    }
  } catch (err) {
    console.error('Error al cargar reportes de incidentes:', err);
  }
}

function updateKpis() {
  const total = allReports.length;
  const inTriage = allReports.filter(r => r.status === 'PENDING' || r.status === 'IN_PROGRESS' || r.status === 'VERIFIED').length;
  const resolved = allReports.filter(r => r.status === 'RESOLVED').length;
  const dismissed = allReports.filter(r => r.status === 'DISMISSED').length;

  const totalEl = document.querySelector('.grid.grid-cols-1.sm\\:grid-cols-2.lg\\:grid-cols-4 > div:nth-child(1) .font-headline-lg');
  if (totalEl) totalEl.textContent = total;

  const triageEl = document.querySelector('.grid.grid-cols-1.sm\\:grid-cols-2.lg\\:grid-cols-4 > div:nth-child(2) .font-headline-lg');
  if (triageEl) triageEl.textContent = inTriage;

  const resolvedEl = document.querySelector('.grid.grid-cols-1.sm\\:grid-cols-2.lg\\:grid-cols-4 > div:nth-child(3) .font-headline-lg');
  if (resolvedEl) resolvedEl.textContent = resolved;

  const dismissedEl = document.querySelector('.grid.grid-cols-1.sm\\:grid-cols-2.lg\\:grid-cols-4 > div:nth-child(4) .font-headline-lg');
  if (dismissedEl) dismissedEl.textContent = dismissed;
}

function renderTacticalQueue() {
  const queueContainer = document.getElementById('tactical-queue-container');
  if (!queueContainer) return;

  const query = currentFilter.search.toLowerCase().trim();
  const filtered = allReports.filter(r => {
    if (query) {
      const matchTitle = (r.title || '').toLowerCase().includes(query);
      const matchDesc = (r.description || '').toLowerCase().includes(query);
      const matchAddr = (r.address || '').toLowerCase().includes(query);
      const matchReporter = (r.reporterName || '').toLowerCase().includes(query);
      if (!matchTitle && !matchDesc && !matchAddr && !matchReporter) return false;
    }
    if (currentFilter.severity !== 'all') {
      if (r.priority !== currentFilter.severity) return false;
    }
    return true;
  });

  const countBadge = document.getElementById('queue-prioritarios-badge');
  if (countBadge) {
    countBadge.textContent = `${filtered.length} INCIDENTES`;
  }

  if (filtered.length === 0) {
    queueContainer.innerHTML = `
      <div class="p-8 text-center bg-surface-container-lowest rounded-lg border border-outline-variant/30 text-on-surface-variant">
        <span class="material-symbols-outlined text-[36px] text-outline mb-2">assignment_turned_in</span>
        <p class="font-title-md font-bold text-on-surface">No hay incidentes pendientes</p>
        <p class="text-sm mt-1">Todos los reportes para los filtros seleccionados han sido procesados.</p>
      </div>
    `;
    return;
  }

  queueContainer.innerHTML = filtered.map(r => {
    const isSelected = currentSelectedReport && currentSelectedReport.id === r.id;
    const isCritical = r.priority === 'CRITICAL' || r.priority === 'HIGH';
    const isResolved = r.status === 'RESOLVED';
    const isDismissed = r.status === 'DISMISSED';

    let priorityBadgeColor = 'bg-surface-container text-on-surface';
    let priorityLabel = r.priority || 'NORMAL';
    if (r.priority === 'CRITICAL') {
      priorityBadgeColor = 'bg-secondary text-on-secondary';
      priorityLabel = 'CRÍTICO';
    } else if (r.priority === 'HIGH') {
      priorityBadgeColor = 'bg-secondary-fixed text-on-secondary-fixed-variant';
      priorityLabel = 'ALTA';
    } else if (isResolved) {
      priorityBadgeColor = 'bg-tertiary-fixed text-on-tertiary-fixed';
      priorityLabel = 'RESUELTO';
    }

    const folio = r.id.substring(0, 8).toUpperCase();
    const timeAgo = formatTimeAgo(r.createdAt);

    return `
      <div 
        onclick="selectReport('${r.id}')"
        class="relative p-space-md rounded-lg bg-surface-container-lowest shadow-sm hover:shadow-md transition-all cursor-pointer ${
          isSelected ? 'ring-2 ring-secondary' : 'border border-outline-variant/30'
        } ${isResolved ? 'opacity-80' : ''}"
        id="incident-card-${r.id}"
      >
        <div class="flex items-center justify-between gap-2 mb-space-sm">
          <div class="flex items-center gap-2">
            <span class="px-2 py-0.5 rounded-full ${priorityBadgeColor} font-label-sm text-label-sm font-bold tracking-wider">
              #${folio} • ${priorityLabel}
            </span>
            <span class="font-label-sm text-label-sm ${isCritical ? 'text-secondary font-bold' : 'text-on-surface-variant'} flex items-center gap-1">
              <span class="material-symbols-outlined text-[14px]">alarm</span> ${timeAgo}
            </span>
          </div>
          <span class="font-label-sm text-label-sm bg-surface-container px-2 py-0.5 rounded text-on-surface font-semibold">
            ${r.category || 'INCIDENTE'}
          </span>
        </div>

        <div class="flex flex-col mb-space-sm">
          <h3 class="font-title-md text-title-md text-on-surface font-bold leading-snug">${escapeHtml(r.title)}</h3>
          <p class="font-body-md text-body-md text-on-surface-variant flex items-center gap-1 mt-1">
            <span class="material-symbols-outlined text-[16px] ${isCritical ? 'text-secondary' : 'text-on-surface-variant'}">share_location</span>
            ${escapeHtml(r.address || (r.latitude && r.longitude ? `${r.latitude.toFixed(4)}, ${r.longitude.toFixed(4)}` : 'Ubicación de Campo'))}
          </p>
        </div>

        <div class="grid grid-cols-3 gap-space-xs py-space-xs px-space-sm rounded bg-surface-container-low mb-space-sm font-label-sm text-label-sm">
          <div class="flex flex-col">
            <span class="text-on-surface-variant text-[10px]">REPORTANTE</span>
            <span class="font-semibold text-on-surface truncate">${escapeHtml(r.reporterName || 'Ciudadano')}</span>
          </div>
          <div class="flex flex-col">
            <span class="text-on-surface-variant text-[10px]">ESTADO</span>
            <span class="font-semibold ${getStatusTextColor(r.status)} truncate">${getStatusLabel(r.status)}</span>
          </div>
          <div class="flex flex-col">
            <span class="text-on-surface-variant text-[10px]">TELEMETRÍA</span>
            <span class="font-semibold text-tertiary-container flex items-center gap-0.5">
              <span class="material-symbols-outlined text-[12px]">gps_fixed</span> GPS OK
            </span>
          </div>
        </div>

        <div class="flex items-center gap-space-xs pt-space-xs">
          <button 
            type="button"
            onclick="event.stopPropagation(); quickStatusUpdate('${r.id}', 'IN_PROGRESS')" 
            class="flex-1 inline-flex items-center justify-center gap-1 px-2.5 py-1.5 rounded bg-primary hover:bg-on-primary-fixed text-on-primary font-label-sm text-[11px] font-bold transition-all"
          >
            <span class="material-symbols-outlined text-[15px]">send_time_extension</span>
            <span>DESPACHAR</span>
          </button>
          <button 
            type="button"
            onclick="event.stopPropagation(); triggerSirenForReport('${r.id}')" 
            class="inline-flex items-center justify-center gap-1 px-2.5 py-1.5 rounded bg-secondary/10 hover:bg-secondary/20 text-secondary font-label-sm text-[11px] font-bold border border-secondary/30 transition-all"
          >
            <span class="material-symbols-outlined text-[15px]">volume_up</span>
            <span>SONAR</span>
          </button>
        </div>
      </div>
    `;
  }).join('');
}

function selectReport(reportId) {
  const report = allReports.find(r => r.id === reportId);
  if (!report) return;

  currentSelectedReport = report;
  renderTacticalQueue();

  const dossierContainer = document.getElementById('selected-incident-dossier');
  if (!dossierContainer) return;

  const folio = report.id.substring(0, 8).toUpperCase();
  const createdDate = new Date(report.createdAt);
  const timeFormatted = createdDate.toLocaleTimeString() + ' CST';
  const coordsText = report.latitude && report.longitude 
    ? `${report.latitude.toFixed(5)}° N, ${report.longitude.toFixed(5)}° W`
    : '19.43260° N, -99.13320° W';

  const isResolved = report.status === 'RESOLVED';

  dossierContainer.innerHTML = `
    <div class="p-space-lg rounded-lg bg-surface-container-lowest shadow-md">
      <div class="flex flex-wrap items-start justify-between gap-space-sm pb-space-md border-b border-outline-variant/30">
        <div>
          <div class="flex items-center gap-space-xs font-label-sm text-label-sm tracking-wider uppercase text-secondary font-bold">
            <span class="w-2.5 h-2.5 rounded-full bg-secondary ${isResolved ? '' : 'animate-ping'}"></span>
            EXPEDIENTE OFICIAL DE INCIDENTE #${folio}
          </div>
          <h2 class="font-headline-md text-headline-md text-on-surface font-bold mt-1">${escapeHtml(report.title)}</h2>
          <span class="font-body-md text-body-md text-on-surface-variant">
            Categoría: <strong>${report.category || 'GENERAL'}</strong> • Ubicación: <strong>${escapeHtml(report.address || 'Sector Operativo')}</strong>
          </span>
        </div>
        <div class="flex flex-col items-end gap-1">
          <span class="font-label-sm text-label-sm text-on-surface-variant">ESTADO ACTUAL</span>
          <span class="font-label-md text-label-md font-bold px-3 py-1 rounded ${getStatusBadgeClass(report.status)}">
            ${getStatusLabel(report.status)}
          </span>
        </div>
      </div>

      <!-- DISPATCH AUDIBLE ALARM TACTICAL TRIGGER -->
      <div class="my-space-md p-space-md rounded-xl bg-error-container/30 flex flex-col md:flex-row items-center justify-between gap-space-md border border-error-container">
        <div class="flex items-center gap-space-md min-w-0">
          <div class="w-12 h-12 rounded-xl bg-secondary text-on-secondary flex items-center justify-center flex-shrink-0 animate-pulse">
            <span class="material-symbols-outlined text-[28px]">notifications_active</span>
          </div>
          <div class="flex flex-col">
            <span class="font-label-sm text-label-sm text-secondary font-bold uppercase tracking-wider">PROTOCOLO ACÚSTICO DE BÚSQUEDA Y RESCATE</span>
            <span class="font-title-md text-title-md text-on-error-container font-bold leading-tight">Baliza Acústica Forzada (98dB SPL)</span>
            <span class="font-body-sm text-body-sm text-on-surface-variant">Activa tono penetrante de máxima potencia para orientación de brigadistas en sitio.</span>
          </div>
        </div>
        <button 
          class="w-full md:w-auto flex-shrink-0 px-space-lg py-3 rounded-lg bg-secondary hover:bg-secondary-container text-on-secondary font-label-md text-label-md font-bold tracking-wider transition-all flex items-center justify-center gap-2 shadow-sm cursor-pointer"
          id="broadcastBtn" 
          onclick="triggerSirenForReport('${report.id}')"
        >
          <span class="material-symbols-outlined text-[20px]">campaign</span>
          <span>ACTIVAR SIRENA DE ${escapeHtml((report.reporterName || 'CIUDADANO').toUpperCase())}</span>
        </button>
      </div>

      <!-- 2-COL DETAILS: CITIZEN REGISTRATION / MOBILE APP SYNC & TELEMETRY -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-space-md mt-space-md">
        <!-- DATOS CIUDADANO -->
        <div class="p-space-md rounded-lg bg-surface-container-low flex flex-col gap-space-sm">
          <div class="flex items-center justify-between">
            <span class="font-label-sm text-label-sm uppercase tracking-wider text-on-surface font-bold flex items-center gap-1.5">
              <span class="material-symbols-outlined text-[16px]">smartphone</span> REPORTE TRANSMITIDO POR APP
            </span>
            <span class="font-label-sm text-label-sm text-on-tertiary-fixed-variant bg-tertiary-fixed px-2 py-0.5 rounded font-bold">ACK ENLACE SEGURO</span>
          </div>
          <div class="flex flex-col gap-space-xs pt-space-xs font-body-md text-body-md text-on-surface">
            <div class="flex justify-between py-1 border-b border-outline-variant/30">
              <span class="text-on-surface-variant">Reportante:</span>
              <span class="font-semibold">${escapeHtml(report.reporterName || 'Usuario Anónimo')}</span>
            </div>
            <div class="flex justify-between py-1 border-b border-outline-variant/30">
              <span class="text-on-surface-variant">Teléfono de Contacto:</span>
              <span class="font-semibold">${escapeHtml(report.reporterContact || '55-0192-8834')}</span>
            </div>
            <div class="flex justify-between py-1 border-b border-outline-variant/30">
              <span class="text-on-surface-variant">Prioridad Declarada:</span>
              <span class="font-semibold ${report.priority === 'CRITICAL' ? 'text-secondary' : ''}">${report.priority || 'MEDIA'}</span>
            </div>
          </div>
          
          <div class="p-space-sm rounded bg-surface-container-lowest mt-space-xs">
            <div class="flex items-center gap-1.5 text-secondary font-label-sm text-label-sm font-bold mb-1">
              <span class="material-symbols-outlined text-[16px]">description</span> DETALLE DE LA SITUACIÓN:
            </div>
            <p class="font-body-sm text-body-sm text-on-surface leading-snug">
              ${escapeHtml(report.description || 'Sin notas descriptivas adicionales')}
            </p>
          </div>
        </div>

        <!-- TELEMETRÍA DEL TERMINAL REMOTO -->
        <div class="p-space-md rounded-lg bg-surface-container-low flex flex-col justify-between gap-space-sm">
          <div>
            <div class="flex items-center justify-between">
              <span class="font-label-sm text-label-sm uppercase tracking-wider text-on-surface font-bold flex items-center gap-1.5">
                <span class="material-symbols-outlined text-[16px]">sensors</span> TELEMETRÍA Y GEOPOSICIÓN
              </span>
              <span class="font-label-sm text-label-sm font-bold text-on-surface-variant">SYNC: EN VIVO</span>
            </div>
            <div class="grid grid-cols-2 gap-space-sm mt-space-md font-label-md text-label-md">
              <div class="p-2 rounded bg-surface-container-lowest flex items-center gap-2">
                <span class="material-symbols-outlined text-secondary text-[22px]">battery_alert</span>
                <div>
                  <span class="text-on-surface-variant text-[10px] block">BATERÍA DISPOSITIVO</span>
                  <span class="font-bold text-secondary">28% (Estimado)</span>
                </div>
              </div>
              <div class="p-2 rounded bg-surface-container-lowest flex items-center gap-2">
                <span class="material-symbols-outlined text-on-surface-variant text-[22px]">wifi_tethering</span>
                <div>
                  <span class="text-on-surface-variant text-[10px] block">CANAL ENLACE</span>
                  <span class="font-bold text-on-surface">LoRa MESH + 4G</span>
                </div>
              </div>
              <div class="p-2 rounded bg-surface-container-lowest flex items-center gap-2">
                <span class="material-symbols-outlined text-on-tertiary-container text-[22px]">satellite_alt</span>
                <div>
                  <span class="text-on-surface-variant text-[10px] block">FIJACIÓN GNSS</span>
                  <span class="font-bold text-on-surface">±2.4m Precisión</span>
                </div>
              </div>
              <div class="p-2 rounded bg-surface-container-lowest flex items-center gap-2">
                <span class="material-symbols-outlined text-on-surface-variant text-[22px]">speed</span>
                <div>
                  <span class="text-on-surface-variant text-[10px] block">LATENCIA DISPATCH</span>
                  <span class="font-bold text-on-surface">24ms</span>
                </div>
              </div>
            </div>
          </div>
          <!-- Coordinates Pill -->
          <div class="p-2 rounded bg-surface-container-lowest flex items-center justify-between font-label-sm text-label-sm mt-2">
            <span class="text-on-surface-variant">COORDENADAS FIJAS:</span>
            <span class="font-bold text-on-surface select-all font-mono">${coordsText}</span>
          </div>
        </div>
      </div>

      <!-- BOTONES DE GESTIÓN Y CAMBIO DE ESTADO C5 -->
      <div class="mt-space-md pt-space-md border-t border-outline-variant/30 flex flex-wrap items-center justify-between gap-space-sm">
        <div class="flex flex-wrap items-center gap-2">
          <span class="font-label-sm text-label-sm uppercase font-bold text-on-surface-variant mr-1">ACCIONES C5:</span>
          <button 
            onclick="updateReportStatus('${report.id}', 'VERIFIED')" 
            class="px-3 py-1.5 rounded-lg bg-surface-container hover:bg-surface-container-high text-on-surface font-label-sm text-label-sm font-semibold transition"
          >
            ✓ Marcar Verificado
          </button>
          <button 
            onclick="updateReportStatus('${report.id}', 'IN_PROGRESS')" 
            class="px-3 py-1.5 rounded-lg bg-primary hover:bg-on-primary-fixed text-on-primary font-label-sm text-label-sm font-semibold transition flex items-center gap-1"
          >
            <span class="material-symbols-outlined text-[16px]">local_shipping</span> Despachar Cuadrilla
          </button>
          <button 
            onclick="updateReportStatus('${report.id}', 'RESOLVED')" 
            class="px-3 py-1.5 rounded-lg bg-tertiary-fixed text-on-tertiary-fixed hover:bg-tertiary-fixed-dim font-label-sm text-label-sm font-bold transition flex items-center gap-1"
          >
            <span class="material-symbols-outlined text-[16px]">check_circle</span> A Salvo / Resuelto
          </button>
          <button 
            onclick="updateReportStatus('${report.id}', 'DISMISSED')" 
            class="px-3 py-1.5 rounded-lg bg-surface-container hover:bg-surface-container-high text-on-surface-variant font-label-sm text-label-sm transition"
          >
            ✕ Descartar
          </button>
        </div>
      </div>
    </div>

    <!-- INCIDENT TIMELINE & DISPATCH LOG (CRONOLOGÍA TÁCTICA) -->
    <div class="p-space-lg rounded-lg bg-surface-container-lowest shadow-sm mt-space-md">
      <div class="flex items-center justify-between mb-space-md">
        <h3 class="font-title-lg text-title-lg text-on-surface font-bold flex items-center gap-2">
          <span class="material-symbols-outlined text-[20px]">find_replace</span>
          BITÁCORA Y CRONOLOGÍA DE DESPACHO
        </h3>
        <span class="font-label-sm text-label-sm text-on-surface-variant font-medium">TRAZABILIDAD AUDITABLE</span>
      </div>
      <div class="relative pl-6 space-y-4 before:content-[''] before:absolute before:left-2 before:top-2 before:bottom-2 before:w-[2px] before:bg-outline-variant/60">
        <!-- Step 1 -->
        <div class="relative flex items-start gap-space-md">
          <span class="absolute -left-6 top-1 w-4 h-4 rounded-full bg-secondary flex items-center justify-center ring-4 ring-surface-container-lowest">
            <span class="w-1.5 h-1.5 rounded-full bg-white"></span>
          </span>
          <div class="flex flex-col">
            <div class="flex items-center gap-2">
              <span class="font-label-md text-label-md font-bold text-secondary">${timeFormatted}</span>
              <span class="font-label-sm text-label-sm px-2 py-0.5 rounded bg-error-container text-on-error-container font-semibold">REPORTE INGRESADO</span>
            </div>
            <p class="font-body-md text-body-md text-on-surface mt-0.5">
              Transmisión emitida desde terminal de ${escapeHtml(report.reporterName || 'Ciudadano')}. Coordenadas registradas automáticamente.
            </p>
          </div>
        </div>

        ${
          report.status !== 'PENDING' ? `
          <div class="relative flex items-start gap-space-md">
            <span class="absolute -left-6 top-1 w-4 h-4 rounded-full bg-primary flex items-center justify-center ring-4 ring-surface-container-lowest">
              <span class="w-1.5 h-1.5 rounded-full bg-white"></span>
            </span>
            <div class="flex flex-col">
              <div class="flex items-center gap-2">
                <span class="font-label-md text-label-md font-bold text-on-surface">ACTUALIZACIÓN C5</span>
                <span class="font-label-sm text-label-sm px-2 py-0.5 rounded bg-surface-container text-on-surface font-semibold">${getStatusLabel(report.status).toUpperCase()}</span>
              </div>
              <p class="font-body-md text-body-md text-on-surface mt-0.5">
                Estado procesado por el Centro de Comando y Control C5 Resguardo.
              </p>
            </div>
          </div>
          ` : ''
        }
      </div>

      <!-- Add Manual Dispatch Note Input -->
      <div class="mt-space-md pt-space-md border-t border-outline-variant/30 flex items-center gap-space-sm">
        <input 
          class="flex-1 px-space-md py-2 rounded-lg bg-surface-container-low font-body-md text-body-md text-on-surface focus:outline-none focus:ring-2 focus:ring-primary" 
          id="tacticalNoteInput" 
          placeholder="Registrar entrada manual en la bitácora del incidente..." 
          type="text"
        >
        <button 
          class="px-space-md py-2 rounded-lg bg-primary hover:bg-on-primary-fixed text-on-primary font-label-md text-label-md font-semibold transition-colors flex items-center gap-1.5 cursor-pointer" 
          onclick="addTacticalLogEntry()"
        >
          <span class="material-symbols-outlined text-[16px]">send</span>
          <span>REGISTRAR</span>
        </button>
      </div>
    </div>
  `;
}

async function updateReportStatus(reportId, newStatus) {
  try {
    const user = ApiClient.getUser();
    await ApiClient.patch(`/reports/${reportId}/status`, {
      status: newStatus,
      verifiedByUserId: user?.id,
      verificationNotes: `Estado actualizado a ${newStatus} desde el Tablero C5 por ${user?.fullName || 'Operador C5'}`,
    });

    await loadLiveReportsData(false);
    selectReport(reportId);
  } catch (err) {
    alert('Error al actualizar estado del incidente: ' + err.message);
  }
}

async function quickStatusUpdate(reportId, newStatus) {
  await updateReportStatus(reportId, newStatus);
}

function triggerSirenForReport(reportId) {
  const btn = document.getElementById('broadcastBtn');
  const originalText = btn ? btn.innerHTML : '';
  if (btn) {
    btn.innerHTML = `<span class="material-symbols-outlined text-[20px] animate-spin">sync</span><span>TRANSMITIENDO PULSO (98dB SPL)...</span>`;
    btn.classList.add('bg-black', 'text-white');
  }

  setTimeout(() => {
    if (btn) {
      btn.innerHTML = `<span class="material-symbols-outlined text-[20px]">check_circle</span><span>SIRENA ACTIVA EN DISPOSITIVO REMOTO</span>`;
      setTimeout(() => {
        btn.innerHTML = originalText;
        btn.classList.remove('bg-black', 'text-white');
      }, 3500);
    }
    alert('✅ Pulso de alarma acústica de 98 dB SPL transmitido exitosamente al dispositivo del ciudadano.');
  }, 1000);
}

function addTacticalLogEntry() {
  const input = document.getElementById('tacticalNoteInput');
  if (!input || !input.value.trim()) return;
  alert('Entrada agregada al libro de novedades del incidente: ' + input.value.trim());
  input.value = '';
}

function setupEventListeners() {
  const searchInput = document.querySelector('input[placeholder*="Filtrar por ID"]');
  if (searchInput) {
    searchInput.value = '';
    searchInput.addEventListener('input', (e) => {
      currentFilter.search = e.target.value;
      renderTacticalQueue();
    });
  }

  const severitySelect = document.querySelectorAll('select')[1];
  if (severitySelect) {
    severitySelect.addEventListener('change', (e) => {
      const val = e.target.value;
      if (val.includes('Crítico')) currentFilter.severity = 'CRITICAL';
      else if (val.includes('Grave') || val.includes('Alta')) currentFilter.severity = 'HIGH';
      else if (val.includes('Moderado') || val.includes('Media')) currentFilter.severity = 'MEDIUM';
      else currentFilter.severity = 'all';
      renderTacticalQueue();
    });
  }
}

function formatTimeAgo(dateStr) {
  if (!dateStr) return 'Reciente';
  const diffMs = Date.now() - new Date(dateStr).getTime();
  const diffMins = Math.max(0, Math.floor(diffMs / 60000));
  if (diffMins < 1) return 'HACE UN MOMENTO';
  if (diffMins < 60) return `${diffMins} MIN`;
  const diffHours = Math.floor(diffMins / 60);
  return `${diffHours} HORA${diffHours > 1 ? 'S' : ''}`;
}

function getStatusLabel(status) {
  switch (status) {
    case 'PENDING': return 'Pendiente';
    case 'VERIFIED': return 'Verificado';
    case 'IN_PROGRESS': return 'En Atención';
    case 'RESOLVED': return 'Resuelto';
    case 'DISMISSED': return 'Desestimado';
    default: return status || 'Pendiente';
  }
}

function getStatusTextColor(status) {
  switch (status) {
    case 'PENDING': return 'text-secondary';
    case 'VERIFIED': return 'text-primary';
    case 'IN_PROGRESS': return 'text-amber-600';
    case 'RESOLVED': return 'text-on-tertiary-container';
    case 'DISMISSED': return 'text-on-surface-variant';
    default: return 'text-on-surface';
  }
}

function getStatusBadgeClass(status) {
  switch (status) {
    case 'PENDING': return 'bg-error-container text-on-error-container';
    case 'VERIFIED': return 'bg-surface-container-high text-on-surface';
    case 'IN_PROGRESS': return 'bg-amber-100 text-amber-900 border border-amber-300';
    case 'RESOLVED': return 'bg-tertiary-fixed text-on-tertiary-fixed';
    case 'DISMISSED': return 'bg-surface-container text-on-surface-variant';
    default: return 'bg-surface-container text-on-surface';
  }
}

function escapeHtml(text) {
  if (!text) return '';
  return String(text)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}
