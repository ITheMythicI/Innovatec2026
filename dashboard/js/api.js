/**
 * RESGUARDO TACTICAL API CLIENT
 * Capa centralizada de comunicación HTTP para el Centro de Mando Táctico.
 */

const API_BASE_URL = window.location.origin.includes(':3001')
  ? `${window.location.origin}/api`
  : 'http://localhost:3001/api';

class ApiClient {
  static getToken() {
    return sessionStorage.getItem('resguardo_token');
  }

  static getUser() {
    const raw = sessionStorage.getItem('resguardo_user');
    return raw ? JSON.parse(raw) : null;
  }

  static setSession(token, user) {
    sessionStorage.setItem('resguardo_token', token);
    sessionStorage.setItem('resguardo_user', JSON.stringify(user));
  }

  static clearSession() {
    sessionStorage.removeItem('resguardo_token');
    sessionStorage.removeItem('resguardo_user');
  }

  static async request(endpoint, options = {}) {
    const url = `${API_BASE_URL}${endpoint}`;
    const token = this.getToken();

    const headers = {
      'Content-Type': 'application/json',
      Accept: 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options.headers,
    };

    try {
      const response = await fetch(url, {
        ...options,
        headers,
      });

      if (response.status === 401) {
        this.clearSession();
        if (!window.location.pathname.endsWith('login.html')) {
          alert('Sesión expirada o no autorizada. Redirigiendo al acceso táctico.');
          window.location.href = '/dashboard/login.html';
        }
        throw new Error('No autorizado');
      }

      const data = await response.json().catch(() => null);

      if (!response.ok) {
        const errorMsg = data?.message || `Error HTTP ${response.status}`;
        throw new Error(Array.isArray(errorMsg) ? errorMsg.join(', ') : errorMsg);
      }

      return data;
    } catch (err) {
      console.error(`[API Error] ${endpoint}:`, err);
      throw err;
    }
  }

  static get(endpoint) {
    return this.request(endpoint, { method: 'GET' });
  }

  static post(endpoint, body) {
    return this.request(endpoint, {
      method: 'POST',
      body: JSON.stringify(body),
    });
  }

  static patch(endpoint, body) {
    return this.request(endpoint, {
      method: 'PATCH',
      body: JSON.stringify(body),
    });
  }

  static delete(endpoint) {
    return this.request(endpoint, { method: 'DELETE' });
  }
}

// Comprobación de autenticación para páginas del panel (excepto login)
function checkAuth() {
  const isLoginPage = window.location.pathname.endsWith('login.html');
  const token = ApiClient.getToken();
  const user = ApiClient.getUser();

  if (!isLoginPage) {
    if (!token || !user) {
      window.location.replace('/dashboard/login.html');
      return;
    }

    if (user.appRole === 'USER') {
      alert('Acceso Restringido: El rol CIUDADANO (USER) no tiene autorización para acceder al Centro de Mando Táctico.');
      ApiClient.clearSession();
      window.location.replace('/dashboard/login.html');
      return;
    }

    // Actualizar nombre y rol del operador en la barra superior usando IDs específicos
    const operatorNameEl = document.getElementById('header-operator-name');
    const operatorRoleEl = document.getElementById('header-operator-role');
    if (operatorNameEl && user.fullName) {
      operatorNameEl.textContent = user.fullName;
    }
    if (operatorRoleEl && user.appRole) {
      operatorRoleEl.textContent = `${user.appRole} ${user.tacticalId ? `[${user.tacticalId}]` : ''}`;
    }
  } else if (token && user && user.appRole !== 'USER') {
    window.location.replace('/dashboard/panel.html');
  }
}

// Configurar enlaces de navegación lateral entre las páginas del dashboard
document.addEventListener('DOMContentLoaded', () => {
  checkAuth();

  const linksMap = {
    'tablero-general': '/dashboard/panel.html',
    'dispositivos-activacion': '/dashboard/devices.html',
    'incidentes-sos': '/dashboard/incidents.html',
    'red-familiar': '/dashboard/people.html',
    'metricas-analitica': '/dashboard/analytics.html',
    'noticias-alertas-app': '/dashboard/broadcasts.html',
    'noticias-comunicados-app': '/dashboard/broadcasts.html',
  };

  document.querySelectorAll('aside nav a, header a[data-path], aside nav a[data-path]').forEach((link) => {
    const path = link.getAttribute('data-path');
    if (path && linksMap[path]) {
      link.setAttribute('href', linksMap[path]);
      link.onclick = null; // Remueve interceptores anteriores
    }
  });
});
