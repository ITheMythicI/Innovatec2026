import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text(
          'Personas & Rescate',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Crear Reporte',
            icon: const Icon(Icons.person_add_alt_1, color: Colors.amberAccent),
            onPressed: () => _showCreateReportDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de Protocolo de Menores / RBAC Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: canViewSensitive
                ? Colors.blueGrey.shade900.withOpacity(0.8)
                : Colors.amber.shade900.withOpacity(0.3),
            child: Row(
              children: [
                Icon(
                  canViewSensitive ? Icons.verified_user : Icons.shield_outlined,
                  color: canViewSensitive ? Colors.tealAccent : Colors.amberAccent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    canViewSensitive
                        ? 'Modo Oficial Activo (${currentRole.displayName}): Acceso a datos y validación de menores habilitado.'
                        : 'Protocolo de Menores Activo: Datos sensibles y contacto de menores protegidos.',
                    style: TextStyle(
                      fontSize: 12,
                      color: canViewSensitive ? Colors.tealAccent : Colors.amber.shade100,
                      fontWeight: FontWeight.w500,
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
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, seña, albergue o zona...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF1E242D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
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
                      FilterChip(
                        label: const Text('Todos'),
                        selected: _selectedTypeFilter == null,
                        selectedColor: Colors.blueAccent.withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: _selectedTypeFilter == null ? Colors.blueAccent : Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        onSelected: (_) => setState(() => _selectedTypeFilter = null),
                        backgroundColor: const Color(0xFF1E242D),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('🚨 Desaparecidos'),
                        selected: _selectedTypeFilter == PersonReportType.missing,
                        selectedColor: Colors.redAccent.withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: _selectedTypeFilter == PersonReportType.missing ? Colors.redAccent : Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        onSelected: (_) => setState(() => _selectedTypeFilter = PersonReportType.missing),
                        backgroundColor: const Color(0xFF1E242D),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('🏠 En Albergue / Encontrados'),
                        selected: _selectedTypeFilter == PersonReportType.foundSheltered,
                        selectedColor: Colors.greenAccent.withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: _selectedTypeFilter == PersonReportType.foundSheltered ? Colors.greenAccent : Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        onSelected: (_) => setState(() => _selectedTypeFilter = PersonReportType.foundSheltered),
                        backgroundColor: const Color(0xFF1E242D),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('👶 Solo Menores'),
                        selected: _minorsOnly,
                        selectedColor: Colors.amberAccent.withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: _minorsOnly ? Colors.amberAccent : Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        onSelected: (val) => setState(() => _minorsOnly = val),
                        backgroundColor: const Color(0xFF1E242D),
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
                        Icon(Icons.person_search_outlined, size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 12),
                        Text(
                          'No se encontraron registros',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'La base de datos local funciona 100% offline.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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

  Widget _buildReportCard(BuildContext context, PersonReport report, UserRole currentRole, bool canVerify) {
    final isMissing = report.type == PersonReportType.missing;
    final accentColor = isMissing ? Colors.redAccent : Colors.greenAccent;

    return Card(
      color: const Color(0xFF1B2028),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: report.isMinor ? Colors.amber.withOpacity(0.5) : accentColor.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
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
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
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
                          style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (report.isMinor)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.child_care, size: 14, color: Colors.amberAccent),
                          SizedBox(width: 4),
                          Text(
                            'MENOR DE EDAD',
                            style: TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold),
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
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${report.age} años • Género: ${report.gender}',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
              const SizedBox(height: 8),

              // Ubicación / Albergue
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isMissing ? Icons.location_on_outlined : Icons.apartment_outlined,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      isMissing
                          ? 'Último avistamiento: ${report.lastKnownLocation}'
                          : 'Ubicación actual: ${report.currentShelterName ?? report.lastKnownLocation}',
                      style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
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
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),

              const Divider(color: Color(0xFF2C3440), height: 20),

              // Footer con botón de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${report.id}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontFamily: 'monospace'),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 14, color: Colors.blueAccent),
                    label: const Text('Ver Ficha', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
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
        bg = Colors.grey.shade800;
        text = Colors.grey.shade400;
        break;
      case VerificationStatus.underReview:
        bg = Colors.orange.withOpacity(0.2);
        text = Colors.orangeAccent;
        break;
      case VerificationStatus.verifiedByAuthority:
        bg = Colors.teal.withOpacity(0.2);
        text = Colors.tealAccent;
        break;
      case VerificationStatus.reunited:
        bg = Colors.purple.withOpacity(0.2);
        text = Colors.purpleAccent;
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
        style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold),
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
      backgroundColor: const Color(0xFF181D24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        report.fullName,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildStatusBadge(report.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text('ID de Reporte: ${report.id}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontFamily: 'monospace')),
                const Divider(color: Color(0xFF2E3846), height: 28),

                if (report.isMinor)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amberAccent.withOpacity(0.6)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield, color: Colors.amberAccent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'PROTOCOLO DE MENOR: La entrega de este menor requiere validación obligatoria con credenciales oficiales.',
                            style: TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold),
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

                const SizedBox(height: 24),

                // Botones de acción oficial
                if (canVerify)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Acciones Oficiales de Rescate y Reunificación',
                        style: TextStyle(color: Colors.tealAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.verified, color: Colors.white),
                        label: const Text('Validar y Marcar Verificado', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showOfficialActionDialog(context, report, VerificationStatus.verifiedByAuthority);
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.family_restroom, color: Colors.white),
                        label: const Text('Registrar Reunificación Oficial / Entrega', style: TextStyle(color: Colors.white)),
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
                      color: const Color(0xFF1E242D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Para solicitar la entrega o validación de esta persona, acuda a la mesa de control del albergue con una identificación oficial.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
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
          Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
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
          backgroundColor: const Color(0xFF1C222B),
          title: Text(
            newStatus == VerificationStatus.reunited ? 'Autorizar Entrega / Reunificación' : 'Verificación Oficial',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Persona: ${report.fullName}',
                style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Firma / Folio de acta y observaciones',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFF13171D),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(dCtx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent),
              child: const Text('Firmar y Registrar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                    SnackBar(
                      content: Text('Operación registrada exitosamente en la cadena de auditoría inmutable.'),
                      backgroundColor: Colors.teal.shade800,
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
      backgroundColor: const Color(0xFF181D24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                    const Text(
                      'Nuevo Reporte de Persona',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),

                    // Tipo de reporte
                    SegmentedButton<PersonReportType>(
                      segments: const [
                        ButtonSegment(
                          value: PersonReportType.missing,
                          label: Text('Desaparecido', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.warning, size: 14),
                        ),
                        ButtonSegment(
                          value: PersonReportType.foundSheltered,
                          label: Text('En Refugio', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.home, size: 14),
                        ),
                      ],
                      selected: {reportType},
                      onSelectionChanged: (set) => setModalState(() => reportType = set.first),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Nombre Completo', filled: true, fillColor: Color(0xFF222933)),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Edad', filled: true, fillColor: Color(0xFF222933)),
                            onChanged: (v) {
                              final age = int.tryParse(v) ?? 0;
                              setModalState(() => isMinor = age > 0 && age < 18);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: gender,
                            dropdownColor: const Color(0xFF222933),
                            style: const TextStyle(color: Colors.white),
                            items: ['Masculino', 'Femenino', 'Otro']
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) => setModalState(() => gender = v ?? 'Masculino'),
                            decoration: const InputDecoration(labelText: 'Género', filled: true, fillColor: Color(0xFF222933)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (isMinor)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: const Row(
                          children: [
                            Icon(Icons.child_care, color: Colors.amberAccent, size: 16),
                            SizedBox(width: 6),
                            Text('Detectado como Menor de Edad (Protegido)', style: TextStyle(color: Colors.amberAccent, fontSize: 11)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: locationController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: reportType == PersonReportType.missing ? 'Último lugar visto (Colonia/Calle)' : 'Lugar donde se encontró',
                        filled: true,
                        fillColor: const Color(0xFF222933),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (reportType == PersonReportType.foundSheltered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextField(
                          controller: shelterController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Nombre del Albergue o Refugio', filled: true, fillColor: Color(0xFF222933)),
                        ),
                      ),

                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Descripción física y vestimenta', filled: true, fillColor: Color(0xFF222933)),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: marksController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Señas particulares (Cicatrices/Tatuajes)', filled: true, fillColor: Color(0xFF222933)),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Teléfono de contacto familiar', filled: true, fillColor: Color(0xFF222933)),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: reporterController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Nombre de quien reporta', filled: true, fillColor: Color(0xFF222933)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: relationshipController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Parentesco', filled: true, fillColor: Color(0xFF222933)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Registrar Reporte (Offline-First)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty || locationController.text.trim().isEmpty) return;

                        final auth = AuthService().currentUser;
                        final age = int.tryParse(ageController.text) ?? 18;

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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reporte guardado localmente y firmado criptográficamente.'),
                              backgroundColor: Colors.green,
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
