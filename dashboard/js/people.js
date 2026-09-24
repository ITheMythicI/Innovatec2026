/**
 * RESGUARDO C5 - CONTROL DE RED FAMILIAR, CENSO Y PERSONAS REGISTRADAS
 * Integración de API /people, filtrado en tiempo real y fichas de bienestar
 */

let peopleData = [];
let selectedPerson = null;

document.addEventListener('DOMContentLoaded', () => {
  initPeoplePage();
  setupFilters();

  setInterval(() => {
    loadPeopleData(false);
  }, 20000);
});

async function initPeoplePage() {
  await loadPeopleData(true);
}

async function loadPeopleData(initial = false) {
  try {
    const data = await ApiClient.get('/people');
    peopleData = Array.isArray(data) ? data : [];

    updateKpiMetrics();
    renderPeopleList();

    if (initial && peopleData.length > 0) {
      selectPerson(peopleData[0].id);
    }
  } catch (err) {
    console.warn('Error al cargar personas y censo:', err.message);
  }
}

function updateKpiMetrics() {
  const totalPeople = peopleData.length;
  const minors = peopleData.filter(p => p.isMinor || (p.age && p.age < 18)).length;
  const elderly = peopleData.filter(p => p.age && p.age >= 60).length;
  const adults = totalPeople - minors - elderly;

  const kpiTotalEl = document.querySelector('.grid.grid-cols-1.sm\\:grid-cols-2.lg\\:grid-cols-5 > div:nth-child(2) .font-headline-lg');
  if (kpiTotalEl) {
    kpiTotalEl.textContent = totalPeople > 0 ? totalPeople.toLocaleString() : '12,840';
  }

  const kpiSubEl = document.querySelector('.grid.grid-cols-1.sm\\:grid-cols-2.lg\\:grid-cols-5 > div:nth-child(2) p');
  if (kpiSubEl && totalPeople > 0) {
    kpiSubEl.innerHTML = `Adultos <span class="font-bold text-on-surface">${adults}</span> · Menores <span class="font-bold text-on-surface">${minors}</span> · Mayores <span class="font-bold text-on-surface">${elderly}</span>`;
  }
}

function renderPeopleList(filterQuery = '') {
  const container = document.querySelector('.xl\\:col-span-4 .flex.flex-col.gap-space-sm');
  if (!container) return;

  const query = filterQuery.toLowerCase().trim();
  const filtered = peopleData.filter(p => {
    if (!query) return true;
    const name = `${p.firstName || ''} ${p.lastName || ''}`.toLowerCase();
    const curp = (p.curp || '').toLowerCase();
    const phone = (p.phone || '').toLowerCase();
    return name.includes(query) || curp.includes(query) || phone.includes(query);
  });

  const countEl = document.querySelector('.xl\\:col-span-4 .font-label-sm.text-label-sm.font-semibold');
  if (countEl) countEl.textContent = `${filtered.length} Personas`;

  if (filtered.length === 0 && peopleData.length > 0) {
    container.innerHTML = `
      <div class="p-6 text-center bg-surface-container-lowest rounded-xl border border-outline-variant/30 text-on-surface-variant">
        <span class="material-symbols-outlined text-[32px] text-outline mb-1">person_search</span>
        <p class="font-title-md font-bold text-on-surface">Sin coincidencias</p>
        <p class="text-xs">No se encontraron personas con ese criterio de búsqueda.</p>
      </div>
    `;
    return;
  }

  // If there are people from the backend, render them
  if (filtered.length > 0) {
    container.innerHTML = filtered.map(p => {
      const isSelected = selectedPerson && selectedPerson.id === p.id;
      const fullName = `${p.firstName} ${p.lastName}`.trim();
      const isMinor = p.isMinor || (p.age && p.age < 18);
      const bloodType = p.bloodType || 'O+';
      const folio = p.id.substring(0, 8).toUpperCase();

      return `
        <div 
          onclick="selectPerson('${p.id}')"
          class="p-space-md rounded-xl bg-surface-container-lowest shadow-sm hover:bg-surface-container-low transition-all cursor-pointer ${
            isSelected ? 'ring-2 ring-primary bg-surface-container-low' : 'border border-outline-variant/30'
          }"
        >
          <div class="flex items-start justify-between gap-2 pb-1.5">
            <div>
              <div class="flex items-center gap-1.5">
                <span class="font-label-sm text-label-sm text-on-surface-variant font-bold">#CEN-${folio}</span>
                <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-surface-container text-on-tertiary-fixed-variant font-label-sm text-label-sm font-bold">
                  <span class="w-1.5 h-1.5 rounded-full bg-tertiary-fixed-dim"></span>
                  REGISTRADO
                </span>
              </div>
              <h3 class="font-title-md text-title-md font-bold text-on-surface mt-1">${escapeHtml(fullName)}</h3>
            </div>
            <span class="px-2 py-0.5 rounded bg-primary text-on-primary font-label-sm text-label-sm font-bold">${bloodType}</span>
          </div>
          <p class="font-body-sm text-body-sm text-on-surface-variant flex items-center gap-1 mb-2">
            <span class="material-symbols-outlined text-[16px] text-on-surface">badge</span>
            CURP: ${escapeHtml(p.curp || 'No registrada')} · ${p.age ? `${p.age} años` : 'Edad N/D'}
          </p>
          <p class="font-label-sm text-label-sm text-on-surface-variant">
            ${isMinor ? '[PROTEGIDO] <strong>Menor de edad</strong> · ' : ''}Contacto: ${escapeHtml(p.phone || 'Sin teléfono')}
          </p>
          <div class="flex items-center justify-between pt-2.5 mt-2 text-on-surface-variant font-label-sm text-label-sm border-t border-outline-variant/20">
            <span>Fecha de Censo: ${new Date(p.createdAt).toLocaleDateString()}</span>
            <span class="text-primary font-semibold flex items-center gap-0.5">
              Ver Ficha <span class="material-symbols-outlined text-[14px]">arrow_forward</span>
            </span>
          </div>
        </div>
      `;
    }).join('');
  }
}

async function selectPerson(personId) {
  try {
    const p = await ApiClient.get(`/people/${personId}`);
    if (!p) return;

    selectedPerson = p;
    renderPeopleList();

    const detailHeader = document.querySelector('.xl\\:col-span-8 .font-headline-md');
    if (detailHeader) {
      detailHeader.textContent = `Expediente: ${p.firstName} ${p.lastName}`;
    }
  } catch (err) {
    console.warn('Error al obtener detalle de persona:', err);
  }
}

function setupFilters() {
  const searchInput = document.querySelector('input[placeholder*="Buscar por Apellidos"]');
  if (searchInput) {
    searchInput.value = '';
    searchInput.addEventListener('input', (e) => {
      renderPeopleList(e.target.value);
    });
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
