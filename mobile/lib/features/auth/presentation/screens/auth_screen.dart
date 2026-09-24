import 'package:flutter/material.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';
import 'package:innovatec_mobile/core/network/gps_location_service.dart';
import 'package:innovatec_mobile/core/utils/qr_code_widget.dart';
import 'package:innovatec_mobile/features/auth/domain/models/auth_user.dart';
import 'package:innovatec_mobile/features/auth/domain/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onAuthSuccess;

  const AuthScreen({super.key, this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;

  // --- Controllers Login ---
  final _loginEmailController = TextEditingController(text: 'ciudadano.lopez@resguardo.gob.mx');
  final _loginPasswordController = TextEditingController(text: 'ClaveSegura2026!');
  bool _obscureLoginPassword = true;

  // --- Step Tracking Registration ---
  int _currentStep = 0; // 0: Perfil, 1: Red SOS, 2: Permisos

  // --- Controllers Paso 1: Perfil ---
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regAddressController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.citizen;
  bool _obscureRegPassword = true;

  // --- Paso 2: Red SOS ---
  bool _includeFamily = true;
  final List<Map<String, String>> _familyMembers = [];
  final _famNameController = TextEditingController();
  final _famRelationController = TextEditingController();
  final _famPhoneController = TextEditingController();
  String _famType = 'Niñez / Amber'; // Niñez / Amber, Geriátrica, Adulto
  final _famNotesController = TextEditingController();

  // --- Paso 3: Permisos ---
  bool _permGps = true;
  bool _permAudio = true;
  bool _permMesh = true;
  bool _acceptedTerms = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regAddressController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    _famNameController.dispose();
    _famRelationController.dispose();
    _famPhoneController.dispose();
    _famNotesController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().loginWithCredentials(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ResguardoTheme.safeEmerald,
            content: Text('Sesión iniciada como ${AuthService().currentUser?.fullName}'),
          ),
        );
        widget.onAuthSuccess?.call();
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar sesión: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().guestEmergencyLogin();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: ResguardoTheme.warningAmber,
            content: Text('Entrando en Modo Invitado / SOS Inmediato'),
          ),
        );
        widget.onAuthSuccess?.call();
        Navigator.of(context).maybePop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCompleteRegistration() async {
    if (!_acceptedTerms) {
      setState(() => _errorMessage = 'Debes aceptar los términos de protección civil.');
      return;
    }

    if (_regPasswordController.text != _regConfirmPasswordController.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().registerUser(
        email: _regEmailController.text.trim(),
        password: _regPasswordController.text,
        fullName: _regNameController.text.trim(),
        phone: _regPhoneController.text.trim(),
        role: _selectedRole,
      );

      if (mounted) {
        await _showRegistrationSuccessModal(context, user);
        widget.onAuthSuccess?.call();
        if (mounted) Navigator.of(context).maybePop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error en registro: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showRegistrationSuccessModal(BuildContext context, AuthUser user) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ResguardoTheme.primary, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.verified, color: ResguardoTheme.safeEmerald, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'CREDENCIAL DIGITAL REGISTRADA',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: ResguardoTheme.primary,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ResguardoTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ResguardoTheme.outline),
                ),
                child: Text(
                  'CÓDIGO ÚNICO: ${user.uniqueCitizenCode}',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: ResguardoTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TacticalQrWidget(
                data: 'RED-NOVA:${user.uniqueCitizenCode}|${user.fullName}|${user.role.code}',
                size: 170,
              ),
              const SizedBox(height: 12),
              const Text(
                'Este código QR único se ha guardado en tus credenciales. Será utilizado por brigadistas en albergues para reconocimiento inmediato y censo de personas a salvo sin conexión a internet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: ResguardoTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ResguardoTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CONTINUAR AL CENTRO DE OPERACIONES',
              style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _addFamilyMember() {
    if (_famNameController.text.trim().isEmpty) return;
    setState(() {
      _familyMembers.add({
        'name': _famNameController.text.trim(),
        'relation': _famRelationController.text.trim(),
        'type': _famType,
        'phone': _famPhoneController.text.trim(),
        'notes': _famNotesController.text.trim(),
      });
      _famNameController.clear();
      _famRelationController.clear();
      _famPhoneController.clear();
      _famNotesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResguardoTheme.surface,
      appBar: AppBar(
        backgroundColor: ResguardoTheme.primary,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESGUARDO // ACCESO',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'PROTECCIÓN CIVIL Y SALVAGUARDA',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ResguardoTheme.safeEmerald.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ResguardoTheme.safeEmerald),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi_tethering, color: ResguardoTheme.safeEmerald, size: 12),
                SizedBox(width: 4),
                Text(
                  'MALLA VIVA',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: ResguardoTheme.safeEmerald,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.lock_open, size: 18), text: 'INICIAR SESIÓN'),
            Tab(icon: Icon(Icons.person_add, size: 18), text: 'CREAR CUENTA'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: ResguardoTheme.emergencyCrimson.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: ResguardoTheme.emergencyCrimson, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: ResguardoTheme.emergencyCrimson,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoginTab(),
                  _buildRegistrationTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: INICIAR SESIÓN
  // ==========================================
  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Ingreso a Plataforma Táctica',
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: ResguardoTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ingresa con tu correo institucional, clave civil o teléfono registrado.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: ResguardoTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Campo Email
          _buildTextField(
            controller: _loginEmailController,
            label: 'CORREO ELECTRÓNICO O FOLIO CIVIL',
            prefixIcon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Campo Contraseña
          _buildTextField(
            controller: _loginPasswordController,
            label: 'CONTRASEÑA',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureLoginPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                color: ResguardoTheme.textMuted,
              ),
              onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
            ),
          ),
          const SizedBox(height: 20),

          // Botón Entrar
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ResguardoTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ENTRAR A RESGUARDO',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
          ),

          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'ACCESO DE EMERGENCIA',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: ResguardoTheme.outline,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          // Botón Modo Invitado SOS Directo
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: ResguardoTheme.emergencyCrimson,
              side: const BorderSide(color: ResguardoTheme.emergencyCrimson, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: _isLoading ? null : _handleGuestLogin,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, color: ResguardoTheme.emergencyCrimson, size: 20),
                SizedBox(width: 8),
                Text(
                  'MODO INVITADO / SOS DIRECTO',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: ResguardoTheme.emergencyCrimson,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'No requiere contraseña previa. Permite emitir auxilio inmediato.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: ResguardoTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: CREAR CUENTA (REGISTRO MULTI-PASO)
  // ==========================================
  Widget _buildRegistrationTab() {
    return Column(
      children: [
        // Stepper Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: ResguardoTheme.surfaceContainerHigh,
          child: Row(
            children: [
              _buildStepIndicator(0, '1. Perfil', Icons.person),
              _buildStepConnector(0),
              _buildStepIndicator(1, '2. Red SOS', Icons.group),
              _buildStepConnector(1),
              _buildStepIndicator(2, '3. Permisos', Icons.tune),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildCurrentStepContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title, IconData icon) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    Color color = ResguardoTheme.outline;
    if (isActive) color = ResguardoTheme.primary;
    if (isDone) color = ResguardoTheme.safeEmerald;

    return GestureDetector(
      onTap: () {
        if (stepIndex < _currentStep) {
          setState(() => _currentStep = stepIndex);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDone ? ResguardoTheme.safeEmerald : (isActive ? ResguardoTheme.primary : Colors.white),
              border: Border.all(color: color),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check : icon,
              size: 14,
              color: (isActive || isDone) ? Colors.white : color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int beforeStep) {
    final isDone = _currentStep > beforeStep;
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? ResguardoTheme.safeEmerald : ResguardoTheme.outlineVariant,
        margin: const EdgeInsets.symmetric(horizontal: 6),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Profile();
      case 1:
        return _buildStep2Family();
      case 2:
        return _buildStep3Permissions();
      default:
        return const SizedBox();
    }
  }

  // --- PASO 1: PERFIL ---
  Widget _buildStep1Profile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Datos de Resguardo Civil',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: ResguardoTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tu información se encripta localmente para identificación en brigadas de auxilio.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: ResguardoTheme.textMuted),
        ),
        const SizedBox(height: 20),

        _buildTextField(
          controller: _regNameController,
          label: 'NOMBRE COMPLETO *',
          hintText: 'Ej. Roberto Ramírez Sandoval',
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _regEmailController,
          label: 'CORREO ELECTRÓNICO *',
          hintText: 'usuario@correo.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _regPhoneController,
          label: 'TELÉFONO CELULAR *',
          hintText: '+52 55 1234 5678',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _regAddressController,
                label: 'UBICACIÓN / COLONIA',
                hintText: 'Col. San Jerónimo, Sector Norte',
                prefixIcon: Icons.home_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: IconButton(
                tooltip: 'Detectar por GPS',
                style: IconButton.styleFrom(
                  backgroundColor: ResguardoTheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                icon: const Icon(Icons.my_location, color: ResguardoTheme.primary, size: 20),
                onPressed: () async {
                  final loc = await GpsLocationService().refreshHardwareLocation();
                  if (mounted) {
                    _regAddressController.text = loc.formattedCoords;
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Selector de Rol
        const Text(
          'PERFIL DE ACCESO Y RESPONSABILIDAD',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: ResguardoTheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: ResguardoTheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UserRole>(
              value: _selectedRole,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: UserRole.citizen,
                  child: Text('Ciudadano (Acceso Estándar de Resguardo)'),
                ),
                DropdownMenuItem(
                  value: UserRole.volunteer,
                  child: Text('Brigadista Voluntario Acreditado'),
                ),
                DropdownMenuItem(
                  value: UserRole.shelterAdmin,
                  child: Text('Administrador de Refugio / Albergue'),
                ),
                DropdownMenuItem(
                  value: UserRole.authority,
                  child: Text('Operativo Oficial / Protección Civil'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Contraseña
        _buildTextField(
          controller: _regPasswordController,
          label: 'CONTRASEÑA (MÍNIMO 8 CARACTERES) *',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureRegPassword,
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _regConfirmPasswordController,
          label: 'CONFIRMAR CONTRASEÑA *',
          prefixIcon: Icons.lock_clock_outlined,
          obscureText: _obscureRegPassword,
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ResguardoTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onPressed: () {
            if (_regNameController.text.trim().isEmpty || _regEmailController.text.trim().isEmpty) {
              setState(() => _errorMessage = 'Por favor completa tu nombre y correo.');
              return;
            }
            if (_regPasswordController.text.length < 8) {
              setState(() => _errorMessage = 'La contraseña debe tener al menos 8 caracteres.');
              return;
            }
            setState(() {
              _errorMessage = null;
              _currentStep = 1;
            });
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SIGUIENTE: RED FAMILIAR SOS',
                style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  // --- PASO 2: RED FAMILIAR SOS ---
  Widget _buildStep2Family() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Red de Salvo y Notificación Inmediata',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: ResguardoTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Registra familiares a tu cargo para emitir censos automáticos de bienestar o fichas de auxilio en refugio.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: ResguardoTheme.textMuted),
        ),
        const SizedBox(height: 16),

        SwitchListTile(
          title: const Text(
            '¿Deseas registrar familiares ahora?',
            style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 13),
          ),
          subtitle: const Text(
            'Puedes omitir este paso y agregarlos después desde Mi Familia.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11),
          ),
          value: _includeFamily,
          activeThumbColor: ResguardoTheme.primary,
          contentPadding: EdgeInsets.zero,
          onChanged: (val) => setState(() => _includeFamily = val),
        ),

        if (_includeFamily) ...[
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'AGREGAR INTEGRANTE A LA RED',
            style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _buildTextField(controller: _famNameController, label: 'Nombre Completo', hintText: 'Ej. Carmen Domínguez'),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildTextField(controller: _famRelationController, label: 'Parentesco', hintText: 'Mamá, Hijo, Abuelo'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(controller: _famPhoneController, label: 'Teléfono (Opcional)', hintText: '+52 55...'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tipo de ficha condicional (Niñez/Amber, Geriátrica, Adulto)
          const Text('CATEGORÍA DE ATENCIÓN:', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _famType,
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
            items: const [
              DropdownMenuItem(value: 'Niñez / Amber', child: Text('Niñez / Protocolo Amber')),
              DropdownMenuItem(value: 'Geriátrica', child: Text('Geriátrica / Movilidad reducida')),
              DropdownMenuItem(value: 'Adulto', child: Text('Adulto operativo')),
            ],
            onChanged: (val) => setState(() => _famType = val ?? 'Adulto'),
          ),
          const SizedBox(height: 8),

          _buildTextField(
            controller: _famNotesController,
            label: 'Condición médica o particularidad',
            hintText: 'Ej. Hipertensa, requiere insulina o silla de ruedas',
          ),
          const SizedBox(height: 10),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: ResguardoTheme.primary,
              side: const BorderSide(color: ResguardoTheme.primary),
            ),
            onPressed: _addFamilyMember,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Agregar a la Red', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold)),
          ),

          if (_familyMembers.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'INTEGRANTES REGISTRADOS:',
              style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _familyMembers.length,
              itemBuilder: (ctx, i) {
                final m = _familyMembers[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  color: ResguardoTheme.surfaceContainerLow,
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      m['type'] == 'Niñez / Amber'
                          ? Icons.child_care
                          : (m['type'] == 'Geriátrica' ? Icons.elderly : Icons.person),
                      color: ResguardoTheme.primary,
                    ),
                    title: Text(m['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${m['relation']} • ${m['type']}\n${m['notes']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: ResguardoTheme.emergencyCrimson),
                      onPressed: () => setState(() => _familyMembers.removeAt(i)),
                    ),
                  ),
                );
              },
            ),
          ],
        ],

        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('VOLVER'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ResguardoTheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => setState(() => _currentStep = 2),
                child: const Text('SIGUIENTE: PERMISOS'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- PASO 3: PERMISOS Y CONSENTIMIENTO ---
  Widget _buildStep3Permissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Autorizaciones de Protección Civil',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: ResguardoTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Configura los accesos tácticos de tu dispositivo para operar en modo contingencia.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: ResguardoTheme.textMuted),
        ),
        const SizedBox(height: 20),

        // Permiso GPS
        _buildPermissionTile(
          icon: Icons.gps_fixed,
          title: 'GPS Táctico para Brigadas',
          subtitle: 'Transmite tus coordenadas al C5 / Sedena únicamente al pulsar SOS o entrar a zona de riesgo.',
          value: _permGps,
          onChanged: (v) => setState(() => _permGps = v),
        ),
        const SizedBox(height: 12),

        // Permiso Audio
        _buildPermissionTile(
          icon: Icons.volume_up,
          title: 'Alertas Sonoras en Modo Silencio',
          subtitle: 'Permite sonar la sirena de evacuación o aviso de dique aún con el teléfono en vibración.',
          value: _permAudio,
          onChanged: (v) => setState(() => _permAudio = v),
        ),
        const SizedBox(height: 12),

        // Permiso Mesh
        _buildPermissionTile(
          icon: Icons.hub,
          title: 'Enlace Offline por Malla Mesh',
          subtitle: 'Usa Bluetooth y WiFi Direct para enlazar mensajes de auxilio entre vecinos si colapsa la red 4G.',
          value: _permMesh,
          onChanged: (v) => setState(() => _permMesh = v),
        ),
        const SizedBox(height: 20),

        // Términos y consentimiento
        CheckboxListTile(
          value: _acceptedTerms,
          activeColor: ResguardoTheme.primary,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Acepto los términos de salvaguarda civil y el uso de mis datos exclusivamente para operaciones de rescate y censo.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12),
          ),
          onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: const Text('VOLVER'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ResguardoTheme.safeEmerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLoading ? null : _handleCompleteRegistration,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'FINALIZAR REGISTRO',
                            style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.check, size: 16),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ResguardoTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ResguardoTheme.outlineVariant),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ResguardoTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: ResguardoTheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: ResguardoTheme.textMuted),
        ),
        value: value,
        activeThumbColor: ResguardoTheme.primary,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: ResguardoTheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: ResguardoTheme.textMuted, fontSize: 12),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: ResguardoTheme.primary) : null,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: ResguardoTheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: ResguardoTheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: ResguardoTheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
