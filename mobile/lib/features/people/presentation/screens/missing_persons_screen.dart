import 'package:flutter/material.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';
import 'package:innovatec_mobile/features/auth/domain/services/auth_service.dart';
import 'package:innovatec_mobile/features/people/domain/models/person_report.dart';
import 'package:innovatec_mobile/features/people/domain/services/people_service.dart';

class MissingPersonsScreen extends StatefulWidget {
  const MissingPersonsScreen({super.key});

  @override
  State<MissingPersonsScreen> createState() => _MissingPersonsScreenState();
}

class _MissingPersonsScreenState extends State<MissingPersonsScreen> {
  final _searchController = TextEditingController();
  PersonReportType? _selectedTypeFilter;
  bool _minorsOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = AuthService().currentUser;
    final currentRole = authUser?.role ?? UserRole.citizen;
    final canViewSensitive = RbacService.hasPermission(currentRole, AppPermission.viewSensitiveMinorDetails);
    final canVerify = RbacService.hasPermission(currentRole, AppPermission.verifyMissingPersonReport);

    return Scaffold(
      backgroundColor: ResguardoTheme.background,
      appBar: AppBar(
        backgroundColor: ResguardoTheme.surface,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personas & Rescate',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                color: ResguardoTheme.primary,
                fontSize: 18,
              ),
            ),
            Text(
              'BÚSQUEDA, CENSO Y REUNIFICACIÓN OFICIAL',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: ResguardoTheme.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Crear Reporte de Persona',
            icon: const Icon(Icons.person_add_alt_1, color: ResguardoTheme.primary),
            onPressed: () => _showCreateReportDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de Protocolo de Menores / RBAC Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: canViewSensitive
                  ? ResguardoTheme.safeEmerald.withValues(alpha: 0.12)
                  : ResguardoTheme.warningAmberContainer,
              border: Border(
                bottom: BorderSide(
                  color: canViewSensitive
                      ? ResguardoTheme.safeEmerald.withValues(alpha: 0.3)
                      : ResguardoTheme.warningAmber.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  canViewSensitive ? Icons.verified_user : Icons.shield_outlined,
                  color: canViewSensitive ? ResguardoTheme.safeEmerald : ResguardoTheme.warningAmber,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    canViewSensitive
                        ? 'Modo Oficial Activo (${currentRole.displayName}): Acceso a datos protegidos y validación habilitada.'
                        : 'Protocolo de Menores Activo: Datos sensibles y contacto de menores protegidos bajo cifrado.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: canViewSensitive ? const Color(0xFF065F46) : const Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barra de Búsqueda y Filtros
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: ResguardoTheme.primary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, seña, albergue o zona...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      color: ResguardoTheme.textMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.search, color: ResguardoTheme.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: ResguardoTheme.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: ResguardoTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: ResguardoTheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: ResguardoTheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: ResguardoTheme.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Todos',
                        isSelected: _selectedTypeFilter == null,
                        onSelected: () => setState(() => _selectedTypeFilter = null),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Desaparecidos',
                        isSelected: _selectedTypeFilter == PersonReportType.missing,
                        onSelected: () => setState(() => _selectedTypeFilter = PersonReportType.missing),
                        accentColor: ResguardoTheme.emergencyCrimson,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'En Albergue / Encontrados',
                        isSelected: _selectedTypeFilter == PersonReportType.foundSheltered,
                        onSelected: () => setState(() => _selectedTypeFilter = PersonReportType.foundSheltered),
                        accentColor: ResguardoTheme.safeEmerald,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Solo Menores',
                        isSelected: _minorsOnly,
                        onSelected: () => setState(() => _minorsOnly = !_minorsOnly),
                        accentColor: ResguardoTheme.warningAmber,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Listado de Reportes
          Expanded(
            child: StreamBuilder<List<PersonReport>>(
              stream: PeopleService().reportsStream,
              builder: (context, snapshot) {
                final reports = PeopleService().searchReports(
                  query: _searchController.text,
                  typeFilter: _selectedTypeFilter,
                  minorsOnly: _minorsOnly,
                  currentRole: currentRole,
                );

                if (reports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search_outlined, size: 56, color: ResguardoTheme.textMuted),
                        const SizedBox(height: 12),
                        const Text(
                          'No se encontraron registros',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.bold,
                            color: ResguardoTheme.primary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'La base de datos local funciona 100% offline y encriptada.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: ResguardoTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _buildReportCard(context, report, currentRole, canVerify);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? accentColor,
  }) {
    final activeColor = accentColor ?? ResguardoTheme.primary;
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : ResguardoTheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? activeColor : ResguardoTheme.outline,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : ResguardoTheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, PersonReport report, UserRole currentRole, bool canVerify) {
    final isMissing = report.type == PersonReportType.missing;
    final accentColor = isMissing ? ResguardoTheme.emergencyCrimson : ResguardoTheme.safeEmerald;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ResguardoTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: report.isMinor
              ? ResguardoTheme.warningAmber
              : (isMissing ? ResguardoTheme.emergencyCrimson.withValues(alpha: 0.5) : ResguardoTheme.outline),
          width: report.isMinor ? 1.5 : 1,
        ),
        boxShadow: const [ResguardoTheme.shadowLevel2],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showReportDetails(context, report, currentRole),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera del reporte
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMissing ? Icons.warning_amber_rounded : Icons.home_work_outlined,
                          size: 14,
                          color: accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isMissing ? 'DESAPARECIDO' : 'EN ALBERGUE',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            color: accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (report.isMinor)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ResguardoTheme.warningAmberContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.child_care, size: 14, color: ResguardoTheme.warningAmber),
                          SizedBox(width: 4),
                          Text(
                            'MENOR DE EDAD',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: ResguardoTheme.warningAmber,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildStatusBadge(report.status),
                ],
              ),
              const SizedBox(height: 10),

              // Nombre y edad
              Text(
                report.fullName,
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  color: ResguardoTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${report.age} años • Género: ${report.gender}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: ResguardoTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),

              // Ubicación / Albergue
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: ResguardoTheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      isMissing
                          ? 'Último avistamiento: ${report.lastKnownLocation}'
                          : 'Ubicación actual: ${report.currentShelterName ?? report.lastKnownLocation}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: ResguardoTheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Descripción física
              Text(
                report.physicalDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: ResguardoTheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),

              const Divider(color: ResguardoTheme.outlineVariant, height: 20),

              // Footer con botón de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${report.id}',
                    style: const TextStyle(
                      color: ResguardoTheme.textMuted,
                      fontSize: 10,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 14, color: ResguardoTheme.primary),
                    label: const Text(
                      'Ver Ficha',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        color: ResguardoTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _showReportDetails(context, report, currentRole),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(VerificationStatus status) {
    Color bg;
    Color text;
    switch (status) {
      case VerificationStatus.unverified:
        bg = ResguardoTheme.surfaceContainerHigh;
        text = ResguardoTheme.textMuted;
        break;
      case VerificationStatus.underReview:
        bg = ResguardoTheme.warningAmberContainer;
        text = ResguardoTheme.warningAmber;
        break;
      case VerificationStatus.verifiedByAuthority:
        bg = ResguardoTheme.safeEmerald.withValues(alpha: 0.15);
        text = ResguardoTheme.safeEmerald;
        break;
      case VerificationStatus.reunited:
        bg = const Color(0xFFEDE9FE);
        text = const Color(0xFF7C3AED);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          color: text,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showReportDetails(BuildContext context, PersonReport report, UserRole currentRole) {
    final canVerify = RbacService.hasPermission(currentRole, AppPermission.verifyMissingPersonReport);
    final isOfficial = currentRole == UserRole.authority || currentRole == UserRole.shelterAdmin;

    if (report.isMinor && isOfficial) {
      PeopleService().logSensitiveMinorAccess(
        reportId: report.id,
        officialUserId: AuthService().currentUser?.id ?? 'OFFICIAL-UNKNOWN',
        officialRole: currentRole.code,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ResguardoTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ResguardoTheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        report.fullName,
                        style: const TextStyle(
                          fontFamily: 'Space Grotesk',
                          color: ResguardoTheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusBadge(report.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ID de Reporte: ${report.id}',
                  style: const TextStyle(
                    color: ResguardoTheme.textMuted,
                    fontSize: 11,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
                const Divider(color: ResguardoTheme.outlineVariant, height: 24),

                if (report.isMinor)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ResguardoTheme.warningAmberContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ResguardoTheme.warningAmber.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield, color: ResguardoTheme.warningAmber),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'PROTOCOLO DE MENOR: La entrega de este menor requiere validación obligatoria con credenciales oficiales.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF92400E),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildDetailRow('Edad', '${report.age} años'),
                _buildDetailRow('Género', report.gender),
                _buildDetailRow('Tipo de Caso', report.type == PersonReportType.missing ? 'Desaparición' : 'Localizado en Albergue'),
                _buildDetailRow('Última Ubicación', report.lastKnownLocation),
                if (report.currentShelterName != null)
                  _buildDetailRow('Albergue Actual', report.currentShelterName!),
                _buildDetailRow('Descripción Física', report.physicalDescription),
                _buildDetailRow('Señas Particulares', report.privateDistinctiveMarks ?? 'Ninguna registrada'),
                _buildDetailRow('Contacto Registrado', report.contactPhone),
                _buildDetailRow('Reportado Por', '${report.reporterName} (${report.reporterRelationship})'),
                if (report.verifiedByOfficialName != null)
                  _buildDetailRow('Oficial Verificador', '${report.verifiedByOfficialName} (Placa: ${report.verifiedByOfficialId ?? "N/A"})'),
                if (report.officialReunificationNotes != null)
                  _buildDetailRow('Notas Oficiales', report.officialReunificationNotes!),

                const SizedBox(height: 20),

                // Botones de acción oficial
                if (canVerify)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Acciones Oficiales de Rescate y Reunificación',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          color: ResguardoTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ResguardoTheme.safeEmerald,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.verified, color: Colors.white),
                        label: const Text(
                          'Validar y Marcar Verificado',
                          style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showOfficialActionDialog(context, report, VerificationStatus.verifiedByAuthority);
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.family_restroom, color: Colors.white),
                        label: const Text(
                          'Registrar Reunificación Oficial / Entrega',
                          style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showOfficialActionDialog(context, report, VerificationStatus.reunited);
                        },
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ResguardoTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ResguardoTheme.outlineVariant),
                    ),
                    child: const Text(
                      'Para solicitar la entrega o validación de esta persona, acuda a la mesa de control del albergue con una identificación oficial.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Inter', color: ResguardoTheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              color: ResguardoTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: ResguardoTheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showOfficialActionDialog(BuildContext context, PersonReport report, VerificationStatus newStatus) {
    final notesController = TextEditingController();
    final authUser = AuthService().currentUser;

    showDialog(
      context: context,
      builder: (dCtx) {
        return AlertDialog(
          backgroundColor: ResguardoTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: ResguardoTheme.primary, width: 1.5),
          ),
          title: Text(
            newStatus == VerificationStatus.reunited ? 'Autorizar Entrega / Reunificación' : 'Verificación Oficial',
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontWeight: FontWeight.bold,
              color: ResguardoTheme.primary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Persona: ${report.fullName}',
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  color: ResguardoTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                style: const TextStyle(fontFamily: 'Inter', color: ResguardoTheme.primary),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Firma / Folio de acta y observaciones',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: ResguardoTheme.textMuted)),
              onPressed: () => Navigator.pop(dCtx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ResguardoTheme.safeEmerald,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Firmar y Registrar',
                style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                if (notesController.text.trim().isEmpty) return;
                Navigator.pop(dCtx);

                await PeopleService().authorizeReunificationOrVerify(
                  reportId: report.id,
                  newStatus: newStatus,
                  officialNotes: notesController.text.trim(),
                  officialId: authUser?.officialBadgeId ?? authUser?.id ?? 'OFICIAL-01',
                  officialName: authUser?.fullName ?? 'Oficial en Turno',
                  officialRole: authUser?.role ?? UserRole.authority,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Operación registrada exitosamente en la cadena de auditoría inmutable.'),
                      backgroundColor: ResguardoTheme.safeEmerald,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreateReportDialog(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final descController = TextEditingController();
    final marksController = TextEditingController();
    final locationController = TextEditingController();
    final shelterController = TextEditingController();
    final phoneController = TextEditingController();
    final reporterController = TextEditingController();
    final relationshipController = TextEditingController();

    PersonReportType reportType = PersonReportType.missing;
    String gender = 'Masculino';
    bool isMinor = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ResguardoTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (mCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: ResguardoTheme.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nuevo Reporte de Persona',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        color: ResguardoTheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tipo de reporte
                    SegmentedButton<PersonReportType>(
                      segments: const [
                        ButtonSegment(
                          value: PersonReportType.missing,
                          label: Text('Desaparecido', style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 12)),
                          icon: Icon(Icons.warning, size: 14),
                        ),
                        ButtonSegment(
                          value: PersonReportType.foundSheltered,
                          label: Text('En Refugio', style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 12)),
                          icon: Icon(Icons.home, size: 14),
                        ),
                      ],
                      selected: {reportType},
                      onSelectionChanged: (set) => setModalState(() => reportType = set.first),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: nameController,
                      style: const TextStyle(fontFamily: 'Inter', color: ResguardoTheme.primary),
                      decoration: const InputDecoration(labelText: 'Nombre Completo'),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontFamily: 'Inter', color: ResguardoTheme.primary),
                            decoration: const InputDecoration(labelText: 'Edad'),
                            onChanged: (v) {
                              final age = int.tryParse(v) ?? 0;
                              setModalState(() => isMinor = age > 0 && age < 18);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: gender,
                            style: const TextStyle(fontFamily: 'Inter', color: ResguardoTheme.primary),
                            items: ['Masculino', 'Femenino', 'Otro']
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) => setModalState(() => gender = v ?? 'Masculino'),
                            decoration: const InputDecoration(labelText: 'Género'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (isMinor)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ResguardoTheme.warningAmberContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.child_care, color: ResguardoTheme.warningAmber, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Detectado como Menor de Edad (Protegido por Cifrado)',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xFF92400E),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: locationController,
                      style: const TextStyle(fontFamily: 'Inter', color: ResguardoTheme.primary),
                      decoration: InputDecoration(
                        labelText: reportType == PersonReportType.missing
                            ? 'Último lugar visto (Colonia/Calle)'
                            : 'Lugar donde se encontró',
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (reportType == PersonReportType.foundSheltered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextField(
                          controller: shelterController,
                          style: const TextStyle(fontFamily: 'Inter', color: ResguardoTheme.primary),
                          decoration: const InputDecoration(labelText: 'Nombre del Albergue o Refugio'),
                        ),
                      ),

                    TextField(
                      controller: descController,
                      style: const TextStyle(fontFamily: 'Inter', color: ResguardoTheme.primary),
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Descripción física y vestimenta'),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: marksController,
                      style: const TextStyle(fontFamily: 'Inter', color: ResguardoTheme.primary),
                      decoration: const InputDecoration(labelText: 'Señas particulares (Cicatrices/Tatuajes)'),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontFamily: 'Inter', color: ResguardoTheme.primary),
                      decoration: const InputDecoration(labelText: 'Teléfono de contacto familiar'),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: reporterController,
                            style: const TextStyle(fontFamily: 'Inter', color: ResguardoTheme.primary),
                            decoration: const InputDecoration(labelText: 'Nombre de quien reporta'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: relationshipController,
                            style: const TextStyle(fontFamily: 'Inter', color: ResguardoTheme.primary),
                            decoration: const InputDecoration(labelText: 'Parentesco'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ResguardoTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text(
                        'Registrar Reporte (Offline-First)',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty || locationController.text.trim().isEmpty) return;

                        final auth = AuthService().currentUser;
                        final age = int.tryParse(ageController.text) ?? 18;
                        final messenger = ScaffoldMessenger.of(context);

                        await PeopleService().createReport(
                          type: reportType,
                          fullName: nameController.text.trim(),
                          age: age,
                          isMinor: isMinor,
                          gender: gender,
                          physicalDescription: descController.text.trim(),
                          privateDistinctiveMarks: marksController.text.trim().isEmpty ? null : marksController.text.trim(),
                          lastKnownLocation: locationController.text.trim(),
                          currentShelterName: shelterController.text.trim().isEmpty ? null : shelterController.text.trim(),
                          contactPhone: phoneController.text.trim().isEmpty ? '+52 55 0000 0000' : phoneController.text.trim(),
                          reporterName: reporterController.text.trim().isEmpty ? (auth?.fullName ?? 'Ciudadano') : reporterController.text.trim(),
                          reporterRelationship: relationshipController.text.trim().isEmpty ? 'Familiar' : relationshipController.text.trim(),
                          actorUserId: auth?.id ?? 'USR-ANON',
                          actorRole: auth?.role ?? UserRole.citizen,
                        );

                        if (mCtx.mounted) Navigator.pop(mCtx);
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Reporte guardado localmente y firmado criptográficamente.'),
                              backgroundColor: ResguardoTheme.safeEmerald,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
