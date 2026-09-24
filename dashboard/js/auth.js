/**
 * Control de Autenticación Táctica - Pantalla de Acceso Oficial
 */

function quickLogin(email) {
  const operatorInput = document.getElementById('operator_id');
  const passwordInput = document.getElementById('operator_password');
  const form = document.getElementById('auth-form');

  if (operatorInput && passwordInput && form) {
    operatorInput.value = email;
    passwordInput.value = 'Password123!';
    form.dispatchEvent(new Event('submit', { cancelable: true, bubbles: true }));
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('auth-form');
  const operatorInput = document.getElementById('operator_id');
  const passwordInput = document.getElementById('operator_password');
  const submitButton = form?.querySelector('button[type="submit"]');

  if (!form) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const email = operatorInput?.value?.trim();
    const password = passwordInput?.value;

    if (!email || !password) {
      alert('Por favor ingrese su usuario o correo oficial y contraseña.');
      return;
    }

    const originalBtnText = submitButton.innerHTML;
    submitButton.disabled = true;
    submitButton.innerHTML = `<span class="animate-spin inline-block w-4 h-4 border-2 border-current border-t-transparent text-white rounded-full mr-2"></span> VALIDANDO CREDENCIALES TÁCTICAS...`;

    try {
      const result = await ApiClient.post('/auth/login', {
        email,
        password,
      });

      if (!result || !result.accessToken) {
        throw new Error('Respuesta inválida del servidor');
      }

      const user = result.user;

      // Validación de canal de acceso (solo roles tácticos/admin en dashboard)
      if (user.appRole === 'USER') {
        alert('Acceso Denegado: Su cuenta tiene rol CIUDADANO (USER). Debe utilizar la aplicación móvil.');
        ApiClient.clearSession();
        return;
      }

      ApiClient.setSession(result.accessToken, user);

      // Redirección inmediata al panel
      window.location.href = '/dashboard/panel.html';
    } catch (err) {
      alert(`Fallo de Autenticación: ${err.message || 'Verifique sus credenciales'}`);
    } finally {
      submitButton.disabled = false;
      submitButton.innerHTML = originalBtnText;
    }
  });
});
