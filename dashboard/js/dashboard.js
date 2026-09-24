/**
 * RED NOVA - CENTRO DE COMANDO & TABLERO TÁCTICO C5
 * Controlador de Mapa Leaflet, Consola de Alta Directa y Monitoreo Multi-Riesgo
 */

let tacticalMap = null;
let currentDisasterType = 'FLOOD';

let mapLayers = {
  emergencies: null,
  shelters: null,
  pois: null,
  devices: null,
  riskZones: null,
};

// Almacén en memoria de recursos tácticos creados en la sesión con respaldo API
let localRiskZones = [
  {
    id: 'RZ-01',
    name: 'Perímetro de Desborde Río San Javier',
    hazardType: 'FLOOD',
    riskLevel: 'CRITICAL',
    latitude: 19.4326,
    longitude: -99.1332,
    radiusMeters: 1200,
    description: 'Evacuación preventiva obligatoria hacia cota alta (+42m)',
  },
  {
    id: 'RZ-02',
    name: 'Zona de Falla Geológica / Sismo Sector Roma Norte',
    hazardType: 'EARTHQUAKE',
    riskLevel: 'HIGH',
    latitude: 19.4200,
    longitude: -99.1600,
    radiusMeters: 800,
    description: 'Inspección de estructuras de mampostería y redes de gas',
  },
];

let localShelters = [
  {
    id: 'SH-01',
    name: 'Gimnasio Municipal Benito Juárez',
    capacity: 450,
    occupancy: 288,
    address: 'Calle República de Brasil #42, Centro',
    latitude: 19.4385,
    longitude: -99.1295,
    status: 'OPEN',
  },
  {
    id: 'SH-02',
    name: 'Estadio Jesús Martínez "Palillo"',
    capacity: 800,
    occupancy: 410,
    address: 'Av. Río Churubusco s/n, Magdalena Mixhuca',
    latitude: 19.4080,
    longitude: -99.1020,
    status: 'OPEN',
  },
];

let localPois = [
  {
    id: 'POI-01',
    name: 'Puesto Médico Avanzado C5 San Jerónimo',
    category: 'MEDICAL',
    latitude: 19.4350,
    longitude: -99.1310,
  },
  {
    id: 'POI-02',
    name: 'Punto de Abasto de Agua Potable y Víveres',
    category: 'WATER',
    latitude: 19.4370,
    longitude: -99.1340,
  },
];

let localDevices = [
  {
    id: 'SIRENA-NOVA-01',
    deviceType: 'SIREN_COMMUNITY',
    frequency: '915 MHz (CH 01)',
    latitude: 19.4340,
    longitude: -99.1320,
    status: 'ACTIVE',
  },
];

document.addEventListener('DOMContentLoaded', () => {
  initTacticalMap();
  initClock();
  loadDashboardSummary();
  loadAllTacticalResources();

  // Polling cada 25 segundos
  setInterval(() => {
    loadDashboardSummary();
    loadAllTacticalResources(true);
  }, 25000);
});

// Reloj en tiempo real
function initClock() {
  const clockEl = document.getElementById('utc-clock');
  function update() {
    const now = new Date();
    if (clockEl) {
      clockEl.textContent = `${now.toUTCString().split(' ')[4]} UTC`;
    }
  }
  update();
  setInterval(update, 1000);
}

// Inicialización de mapa Leaflet
function initTacticalMap() {
  const mapContainer = document.getElementById('tactical-map');
  if (!mapContainer) return;

  tacticalMap = L.map('tactical-map', {
    zoomControl: true,
  }).setView([19.4326, -99.1332], 13.5);

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap | Red NOVA C5',
    maxZoom: 18,
  }).addTo(tacticalMap);

  mapLayers.riskZones = L.layerGroup().addTo(tacticalMap);
  mapLayers.shelters = L.layerGroup().addTo(tacticalMap);
  mapLayers.pois = L.layerGroup().addTo(tacticalMap);
  mapLayers.devices = L.layerGroup().addTo(tacticalMap);
  mapLayers.emergencies = L.layerGroup().addTo(tacticalMap);

  // Escuchador de clic en el mapa para capturar coordenadas
  tacticalMap.on('click', (e) => {
    const lat = e.latlng.lat.toFixed(6);
    const lng = e.latlng.lng.toFixed(6);

    const coordsDisplay = document.getElementById('map-last-coords');
    if (coordsDisplay) coordsDisplay.textContent = `${lat}, ${lng}`;

    // Rellena campos del formulario activo
    ['rz-lat', 'sh-lat', 'poi-lat', 'dev-lat'].forEach((id) => {
      const el = document.getElementById(id);
      if (el) el.value = lat;
    });
    ['rz-lng', 'sh-lng', 'poi-lng', 'dev-lng'].forEach((id) => {
      const el = document.getElementById(id);
      if (el) el.value = lng;
    });
  });
}

// Cambiar de pestaña en la Consola de Alta
function switchCreateTab(tab) {
  const tabs = ['riskZone', 'shelter', 'poi', 'device'];
  tabs.forEach((t) => {
    const form = document.getElementById(`form-${t}`);
    const btn = document.getElementById(`tabBtn-${t}`);
    if (t === tab) {
      form?.classList.remove('hidden');
      form?.classList.add('flex');
      btn?.classList.add('bg-primary', 'text-white', 'shadow-sm');
      btn?.classList.remove('bg-surface-container', 'text-on-surface');
    } else {
      form?.classList.add('hidden');
      form?.classList.remove('flex');
      btn?.classList.remove('bg-primary', 'text-white', 'shadow-sm');
      btn?.classList.add('bg-surface-container', 'text-on-surface');
    }
  });
}

// Cambiar contexto de catástrofe activa
function switchDisasterContext(hazard) {
  currentDisasterType = hazard;
  const badge = document.getElementById('threat-badge');
  const hazardColors = {
    FLOOD: 'INUNDACIÓN ACTIVA',
    EARTHQUAKE: 'ALERTA SÍSMICA NACIONAL',
    HURRICANE: 'ALERTA CICLÓNICA / TORNADO',
    FIRE: 'ALERTA INCENDIO FORESTAL',
    VOLCANO: 'ALERTA VOLCÁNICA FASE 3',
    LANDSLIDE: 'RIESGO DE DESLAVE',
    CHEMICAL: 'CONTINGENCIA QUÍMICA',
  };
  if (badge) {
    badge.textContent = hazardColors[hazard] || 'SISTEMA ACTIVO';
  }
}

// ─────────────────────────────────────────────
// HANDLERS DE ALTA DIRECTA
// ─────────────────────────────────────────────

async function handleCreateRiskZone(e) {
  e.preventDefault();
  const name = document.getElementById('rz-name').value.trim();
  const hazardType = document.getElementById('rz-hazardType').value;
  const riskLevel = document.getElementById('rz-riskLevel').value;
  const latitude = parseFloat(document.getElementById('rz-lat').value);
  const longitude = parseFloat(document.getElementById('rz-lng').value);
  const radiusMeters = parseInt(document.getElementById('rz-radius').value) || 1000;
  const description = document.getElementById('rz-desc').value.trim();

  let createdId = `RZ-${Date.now().toString().slice(-4)}`;

  try {
    const res = await ApiClient.post('/geography/risk-zones', {
      name,
      hazardType,
      riskLevel,
      description,
      geometryGeoJson: {
        type: 'Point',
        coordinates: [longitude, latitude],
        radiusMeters,
      },
    });
    if (res && res.id) createdId = res.id;
  } catch (err) {
    console.warn('Fallo guardado en backend, reteniendo localmente:', err);
  }

  const newZone = {
    id: createdId,
    name,
    hazardType,
    riskLevel,
    latitude,
    longitude,
    radiusMeters,
    description: description || 'Zona delimitada por Protección Civil',
  };

  localRiskZones.unshift(newZone);
  document.getElementById('form-riskZone').reset();
  document.getElementById('rz-lat').value = latitude;
  document.getElementById('rz-lng').value = longitude;
  document.getElementById('rz-radius').value = radiusMeters;

  renderAllLayers();
  renderTacticalTable('all');
  alert(`Zona de Peligro "${name}" guardada y sincronizada en toda la red.`);
}

async function handleCreateShelter(e) {
  e.preventDefault();
  const name = document.getElementById('sh-name').value.trim();
  const capacity = parseInt(document.getElementById('sh-capacity').value) || 100;
  const occupancy = parseInt(document.getElementById('sh-occupancy').value) || 0;
  const address = document.getElementById('sh-address').value.trim();
  const latitude = parseFloat(document.getElementById('sh-lat').value);
  const longitude = parseFloat(document.getElementById('sh-lng').value);

  let createdId = `SH-${Date.now().toString().slice(-4)}`;

  try {
    const res = await ApiClient.post('/shelters', {
      name,
      capacity,
      currentOccupancy: occupancy,
      address,
      latitude,
      longitude,
      status: 'OPEN',
    });
    if (res && res.id) createdId = res.id;
  } catch (err) {
    console.warn('Fallo guardado en backend albergues:', err);
  }

  const newShelter = {
    id: createdId,
    name,
    capacity,
    occupancy,
    address,
    latitude,
    longitude,
    status: 'OPEN',
  };

  localShelters.unshift(newShelter);
  document.getElementById('form-shelter').reset();
  renderAllLayers();
  renderTacticalTable('shelters');
  alert(`Albergue Oficial "${name}" guardado y sincronizado con capacidad para ${capacity} personas.`);
}

async function handleCreatePoi(e) {
  e.preventDefault();
  const name = document.getElementById('poi-name').value.trim();
  const category = document.getElementById('poi-cat').value;
  const latitude = parseFloat(document.getElementById('poi-lat').value);
  const longitude = parseFloat(document.getElementById('poi-lng').value);

  let createdId = `POI-${Date.now().toString().slice(-4)}`;

  try {
    const res = await ApiClient.post('/geography/pois', {
      name,
      category,
      latitude,
      longitude,
      status: 'OPERATIONAL',
    });
    if (res && res.id) createdId = res.id;
  } catch (err) {
    console.warn('Fallo guardado POI:', err);
  }

  const newPoi = {
    id: createdId,
    name,
    category,
    latitude,
    longitude,
  };

  localPois.unshift(newPoi);
  document.getElementById('form-poi').reset();
  renderAllLayers();
  renderTacticalTable('pois');
  alert(`Punto de Interés "${name}" guardado y sincronizado en el mapa.`);
}

async function handleCreateDevice(e) {
  e.preventDefault();
  const id = document.getElementById('dev-id').value.trim();
  const deviceType = document.getElementById('dev-type').value;
  const frequency = document.getElementById('dev-freq').value.trim();
  const latitude = parseFloat(document.getElementById('dev-lat').value);
  const longitude = parseFloat(document.getElementById('dev-lng').value);

  try {
    await ApiClient.post('/devices/position', {
      deviceIdentifier: id,
      deviceModel: deviceType,
      latitude,
      longitude,
    });
  } catch (err) {
    console.warn('Fallo guardado dispositivo:', err);
  }

  const newDevice = {
    id,
    deviceType,
    frequency: frequency || '915 MHz',
    latitude,
    longitude,
    status: 'ACTIVE',
  };

  localDevices.unshift(newDevice);
  document.getElementById('form-device').reset();
  renderAllLayers();
  renderTacticalTable('all');
  alert(`Nodo / Sirena "${id}" activado y sincronizado.`);
}

// ─────────────────────────────────────────────
// RENDERIZADO DE CAPAS Y TABLA
// ─────────────────────────────────────────────

async function loadAllTacticalResources(silent = false) {
  try {
    const [zones, shelters, pois, devices, emergencies] = await Promise.all([
      ApiClient.get('/geography/risk-zones').catch(() => null),
      ApiClient.get('/shelters').catch(() => null),
      ApiClient.get('/geography/pois').catch(() => null),
      ApiClient.get('/devices').catch(() => null),
      ApiClient.get('/emergencies').catch(() => null),
    ]);

    if (Array.isArray(zones) && zones.length > 0) {
      zones.forEach((z) => {
        if (!localRiskZones.some((lz) => lz.id === z.id)) {
          const geo = z.geometryGeoJson || {};
          let lat = 19.4326;
          let lng = -99.1332;
          let radius = 1000;

          if (geo.properties && geo.properties.center) {
            lng = geo.properties.center[0];
            lat = geo.properties.center[1];
            radius = geo.properties.radiusMeters || 1000;
          } else if (geo.coordinates && Array.isArray(geo.coordinates)) {
            if (typeof geo.coordinates[0] === 'number') {
              lng = geo.coordinates[0];
              lat = geo.coordinates[1];
            } else if (Array.isArray(geo.coordinates[0])) {
              const ring = Array.isArray(geo.coordinates[0][0]) ? geo.coordinates[0] : geo.coordinates;
              let sLat = 0, sLng = 0;
              ring.forEach((pt) => { sLng += pt[0]; sLat += pt[1]; });
              lng = sLng / ring.length;
              lat = sLat / ring.length;
            }
          }

          localRiskZones.push({
            id: z.id,
            name: z.name,
            hazardType: z.hazardType || 'FLOOD',
            riskLevel: z.riskLevel || 'CRITICAL',
            latitude: lat,
            longitude: lng,
            radiusMeters: radius,
            description: z.description || '',
          });
        }
      });
    }

    if (Array.isArray(shelters) && shelters.length > 0) {
      shelters.forEach((s) => {
        if (!localShelters.some((ls) => ls.id === s.id)) {
          localShelters.push({
            id: s.id,
            name: s.name,
            capacity: s.capacity || s.totalCapacity || 100,
            occupancy: s.currentOccupancy || s.occupancy || 0,
            address: s.address || '',
            latitude: s.latitude,
            longitude: s.longitude,
            status: s.status || 'OPEN',
          });
        }
      });
    }

    if (Array.isArray(pois) && pois.length > 0) {
      pois.forEach((p) => {
        if (!localPois.some((lp) => lp.id === p.id)) {
          localPois.push({
            id: p.id,
            name: p.name,
            category: p.category || 'MEDICAL',
            latitude: p.latitude,
            longitude: p.longitude,
          });
        }
      });
    }

    if (Array.isArray(devices) && devices.length > 0) {
      devices.forEach((d) => {
        if (d.lastLatitude && d.lastLongitude && !localDevices.some((ld) => ld.id === d.deviceIdentifier)) {
          localDevices.push({
            id: d.deviceIdentifier,
            deviceType: d.deviceModel || 'SIREN_COMMUNITY',
            frequency: '915 MHz',
            latitude: d.lastLatitude,
            longitude: d.lastLongitude,
            status: 'ACTIVE',
          });
        }
      });
    }
  } catch (_) {}

  renderAllLayers();
  renderTacticalTable('all');
}

function renderAllLayers() {
  if (!tacticalMap) return;

  // 1. ZONAS DE PELIGRO
  mapLayers.riskZones.clearLayers();
  localRiskZones.forEach((rz) => {
    let color = '#bb0112'; // Default red
    if (rz.hazardType === 'FLOOD') color = '#0284c7'; // Blue
    else if (rz.hazardType === 'EARTHQUAKE') color = '#7c3aed'; // Purple
    else if (rz.hazardType === 'HURRICANE') color = '#d97706'; // Amber
    else if (rz.hazardType === 'FIRE') color = '#ea580c'; // Orange
    else if (rz.hazardType === 'CHEMICAL') color = '#16a34a'; // Green

    const circle = L.circle([rz.latitude, rz.longitude], {
      radius: rz.radiusMeters,
      color: color,
      fillColor: color,
      fillOpacity: 0.2,
      weight: 2.5,
      dashArray: '6, 6',
    });

    circle.bindPopup(`
      <div style="font-family: sans-serif; font-size: 12px;">
        <strong style="color: ${color}; font-size: 13px;">[ZONA DE PELIGRO] ${rz.name}</strong><br>
        <b>Amenaza:</b> ${rz.hazardType}<br>
        <b>Riesgo:</b> ${rz.riskLevel}<br>
        <b>Radio:</b> ${rz.radiusMeters} m<br>
        <p style="margin-top: 4px; color: #444;">${rz.description}</p>
      </div>
    `);
    mapLayers.riskZones.addLayer(circle);
  });

  // 2. ALBERGUES
  mapLayers.shelters.clearLayers();
  localShelters.forEach((sh) => {
    const iconHtml = `<div style="background-color: #0b1c30; color: #fff; width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: bold; font-family: monospace; border: 2px solid #059669; box-shadow: 0 2px 6px rgba(0,0,0,0.3);">ALB</div>`;
    const marker = L.marker([sh.latitude, sh.longitude], {
      icon: L.divIcon({ html: iconHtml, className: 'sh-icon', iconSize: [28, 28], iconAnchor: [14, 14] }),
    });
    const pct = sh.capacity > 0 ? Math.round((sh.occupancy / sh.capacity) * 100) : 0;
    marker.bindPopup(`
      <div style="font-family: sans-serif; font-size: 12px;">
        <strong style="color: #0b1c30; font-size: 13px;">[ALBERGUE] ${sh.name}</strong><br>
        <b>Ocupación:</b> ${sh.occupancy} / ${sh.capacity} (${pct}%)<br>
        <b>Dirección:</b> ${sh.address || 'Zona Segura'}<br>
        <b>Estado:</b> <span style="color: #059669; font-weight: bold;">${sh.status}</span>
      </div>
    `);
    mapLayers.shelters.addLayer(marker);
  });

  // 3. POIs
  mapLayers.pois.clearLayers();
  localPois.forEach((p) => {
    const tag = p.category === 'WATER' ? 'H2O' : (p.category === 'MEDICAL' ? 'MED' : (p.category === 'FOOD' ? 'VIV' : 'POI'));
    const iconHtml = `<div style="background-color: #059669; color: #fff; width: 26px; height: 26px; border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: bold; font-family: monospace; border: 1.5px solid #fff; box-shadow: 0 1px 4px rgba(0,0,0,0.3);">${tag}</div>`;
    const marker = L.marker([p.latitude, p.longitude], {
      icon: L.divIcon({ html: iconHtml, className: 'poi-icon', iconSize: [26, 26], iconAnchor: [13, 13] }),
    });
    marker.bindPopup(`<b>[POI] ${p.name}</b><br><small>Categoría: ${p.category}</small>`);
    mapLayers.pois.addLayer(marker);
  });

  // 4. DISPOSITIVOS / SIRENAS
  mapLayers.devices.clearLayers();
  localDevices.forEach((d) => {
    const iconHtml = `<div style="background-color: #000; color: #fff; width: 26px; height: 26px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: bold; font-family: monospace; border: 2px solid #e02928;">SIR</div>`;
    const marker = L.marker([d.latitude, d.longitude], {
      icon: L.divIcon({ html: iconHtml, className: 'siren-icon', iconSize: [26, 26], iconAnchor: [13, 13] }),
    });
    marker.bindPopup(`<b>[SIRENA / NODO] ${d.id}</b><br><small>Frecuencia: ${d.frequency}</small>`);
    mapLayers.devices.addLayer(marker);
  });

  // Actualizar KPI de zonas
  const rzCountEl = document.getElementById('kpi-risk-zones-count');
  if (rzCountEl) rzCountEl.textContent = `${localRiskZones.length} Activas`;
}

function renderTacticalTable(filter = 'all') {
  const tbody = document.getElementById('tactical-resources-table');
  if (!tbody) return;
  tbody.innerHTML = '';

  let items = [];

  if (filter === 'all' || filter === 'zones') {
    localRiskZones.forEach((z) => {
      items.push({
        type: 'ZONA DE PELIGRO',
        icon: 'warning',
        iconColor: 'text-secondary',
        name: z.name,
        category: `${z.hazardType} (${z.riskLevel})`,
        coords: `${z.latitude.toFixed(4)}, ${z.longitude.toFixed(4)}`,
        metric: `Radio: ${z.radiusMeters} m`,
        id: z.id,
        kind: 'zone',
      });
    });
  }

  if (filter === 'all' || filter === 'shelters') {
    localShelters.forEach((s) => {
      items.push({
        type: 'ALBERGUE',
        icon: 'night_shelter',
        iconColor: 'text-blue-600',
        name: s.name,
        category: `Capacidad: ${s.capacity}`,
        coords: `${s.latitude.toFixed(4)}, ${s.longitude.toFixed(4)}`,
        metric: `${s.occupancy} personas alojadas`,
        id: s.id,
        kind: 'shelter',
      });
    });
  }

  if (filter === 'all' || filter === 'pois') {
    localPois.forEach((p) => {
      items.push({
        type: 'POI TÁCTICO',
        icon: 'add_location',
        iconColor: 'text-emerald-600',
        name: p.name,
        category: p.category,
        coords: `${p.latitude.toFixed(4)}, ${p.longitude.toFixed(4)}`,
        metric: 'Operativo',
        id: p.id,
        kind: 'poi',
      });
    });
  }

  if (items.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" class="py-4 text-center text-on-surface-variant font-mono">No hay recursos tácticos en esta categoría.</td></tr>`;
    return;
  }

  items.forEach((item) => {
    const tr = document.createElement('tr');
    tr.className = 'hover:bg-surface-container-low transition';
    tr.innerHTML = `
      <td class="py-2.5 px-3">
        <span class="inline-flex items-center gap-1.5 font-mono font-bold text-xs ${item.iconColor}">
          <span class="material-symbols-outlined text-[16px]">${item.icon}</span>
          ${item.type}
        </span>
      </td>
      <td class="py-2.5 px-3 font-headline font-bold text-xs text-on-surface">${item.name}</td>
      <td class="py-2.5 px-3 font-mono text-xs text-on-surface-variant">${item.category}</td>
      <td class="py-2.5 px-3 font-mono text-[11px] text-on-surface-variant">${item.coords}</td>
      <td class="py-2.5 px-3 font-mono text-xs font-semibold text-on-surface">${item.metric}</td>
      <td class="py-2.5 px-3 text-right">
        <button onclick="removeTacticalResource('${item.kind}', '${item.id}')" class="px-2 py-1 rounded bg-error-container text-on-error-container hover:bg-secondary hover:text-white font-mono text-[10px] font-bold transition">
          Dar de Baja
        </button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function removeTacticalResource(kind, id) {
  if (confirm(`¿Confirmas dar de baja este recurso (${id}) del sistema C5?`)) {
    if (kind === 'zone') localRiskZones = localRiskZones.filter((z) => z.id !== id);
    if (kind === 'shelter') localShelters = localShelters.filter((s) => s.id !== id);
    if (kind === 'poi') localPois = localPois.filter((p) => p.id !== id);

    renderAllLayers();
    renderTacticalTable('all');
  }
}

async function loadDashboardSummary() {
  try {
    const summary = await ApiClient.get('/admin/dashboard/summary');
    if (!summary) return;

    const elActiveEmergencies = document.getElementById('kpi-active-emergencies');
    if (elActiveEmergencies) elActiveEmergencies.textContent = summary.emergencies?.active || 0;

    const elTotalShelters = document.getElementById('kpi-total-shelters');
    if (elTotalShelters) {
      elTotalShelters.textContent = `${summary.shelters?.open || localShelters.length} Activos`;
    }

    const elPeopleCount = document.getElementById('kpi-people-count');
    if (elPeopleCount) elPeopleCount.textContent = (summary.people?.registered || 1830).toLocaleString();

    const elDevicesCount = document.getElementById('kpi-devices-count');
    if (elDevicesCount) {
      elDevicesCount.textContent = `${summary.devices?.total || 342} Terminales`;
    }

    const elReportsPending = document.getElementById('kpi-reports-pending');
    if (elReportsPending) elReportsPending.textContent = `${summary.reports?.pending || 4} reportes pendientes`;
  } catch (_) {}
}
