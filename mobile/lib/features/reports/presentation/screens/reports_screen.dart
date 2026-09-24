import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/features/auth/domain/services/auth_service.dart';
import 'package:innovatec_mobile/features/reports/domain/models/report.dart';
import 'package:innovatec_mobile/features/reports/presentation/controllers/report_controller.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final ReportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReportController();
    _controller.loadReports();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: ResguardoTheme.background,
          appBar: AppBar(
            backgroundColor: ResguardoTheme.surface,
            title: const Text(
              'Reportes de Incidentes',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                color: ResguardoTheme.primary,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Sincronizar Reportes',
                icon: const Icon(Icons.sync, color: ResguardoTheme.primary),
                onPressed: () => _controller.sync(),
              ),
              IconButton(
                tooltip: 'Crear Reporte de Incidente',
                icon: const Icon(Icons.add_circle_outline, color: ResguardoTheme.emergencyCrimson),
                onPressed: () => _showCreateReportDialog(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Barra de Categorías (Design.md)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    _buildCategoryFilter('Todos', _controller.selectedCategory == null, () {
                      _controller.filterByCategory(null);
                    }),
                    const SizedBox(width: 8),
                    _buildCategoryFilter('Heridos', _controller.selectedCategory == ReportCategory.casualties, () {
                      _controller.filterByCategory(ReportCategory.casualties);
                    }),
                    const SizedBox(width: 8),
                    _buildCategoryFilter('Atrapados', _controller.selectedCategory == ReportCategory.trappedPersons, () {
                      _controller.filterByCategory(ReportCategory.trappedPersons);
                    }),
                    const SizedBox(width: 8),
                    _buildCategoryFilter('Daño Estructural', _controller.selectedCategory == ReportCategory.structuralDamage, () {
                      _controller.filterByCategory(ReportCategory.structuralDamage);
                    }),
                    const SizedBox(width: 8),
                    _buildCategoryFilter('Fuego', _controller.selectedCategory == ReportCategory.fireHazard, () {
                      _controller.filterByCategory(ReportCategory.fireHazard);
                    }),
                    const SizedBox(width: 8),
                    _buildCategoryFilter('Inundación', _controller.selectedCategory == ReportCategory.flooding, () {
                      _controller.filterByCategory(ReportCategory.flooding);
                    }),
                    const SizedBox(width: 8),
                    _buildCategoryFilter('Víveres', _controller.selectedCategory == ReportCategory.supplyNeed, () {
                      _controller.filterByCategory(ReportCategory.supplyNeed);
                    }),
                  ],
                ),
              ),

              // Lista de Reportes
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ResguardoTheme.primary : ResguardoTheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? ResguardoTheme.primary : ResguardoTheme.outline,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : ResguardoTheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.status == ReportStateStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: ResguardoTheme.primary));
    }

    if (_controller.reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment_outlined, size: 48, color: ResguardoTheme.textMuted),
              const SizedBox(height: 12),
              const Text(
                'Sin Reportes Registrados',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: ResguardoTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Puedes generar un reporte ciudadano o de brigada en campo incluso sin conexión.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', color: ResguardoTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Generar Primer Reporte'),
                onPressed: () => _showCreateReportDialog(context),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: ResguardoTheme.primary,
      onRefresh: () => _controller.loadReports(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _controller.reports.length,
        itemBuilder: (context, index) {
          final report = _controller.reports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    Color priorityColor = ResguardoTheme.safeEmerald;
    if (report.priority == ReportPriority.critical) {
      priorityColor = ResguardoTheme.emergencyCrimson;
    } else if (report.priority == ReportPriority.high) {
      priorityColor = ResguardoTheme.warningAmber;
    } else if (report.priority == ReportPriority.medium) {
      priorityColor = const Color(0xFF2563EB);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: ResguardoTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: report.priority == ReportPriority.critical ? ResguardoTheme.emergencyCrimson : ResguardoTheme.outline,
          width: report.priority == ReportPriority.critical ? 2 : 1,
        ),
        boxShadow: const [ResguardoTheme.shadowLevel2],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador notch 4px (Design.md)
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          report.category.displayName.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ResguardoTheme.textMuted,
                          ),
                        ),
                        _buildStatusBadge(report.priority.displayName, priorityColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      report.title,
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: ResguardoTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: ResguardoTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ResguardoTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ESTADO: ${report.status.displayName.toUpperCase()}',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: ResguardoTheme.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (report.syncStatus.startsWith('pending'))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ResguardoTheme.warningAmberContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.sync_problem, size: 12, color: ResguardoTheme.warningAmber),
                                SizedBox(width: 4),
                                Text(
                                  'PENDIENTE SYNC',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: ResguardoTheme.warningAmber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showCreateReportDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    ReportCategory selectedCat = ReportCategory.casualties;
    ReportPriority selectedPri = ReportPriority.high;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: ResguardoTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: ResguardoTheme.primary, width: 1.5),
              ),
              title: const Text(
                'Nuevo Reporte de Campo',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.w700,
                  color: ResguardoTheme.primary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Título del Incidente *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Descripción / Requerimiento *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addrCtrl,
                      decoration: const InputDecoration(labelText: 'Ubicación / Calle / Referencia'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ReportCategory>(
                      initialValue: selectedCat,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: ReportCategory.values.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c.displayName));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedCat = val!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ReportPriority>(
                      initialValue: selectedPri,
                      decoration: const InputDecoration(labelText: 'Prioridad de Respuesta'),
                      items: ReportPriority.values.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p.displayName));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedPri = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: ResguardoTheme.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) return;
                    final currentUser = AuthService().currentUser;
                    final now = DateTime.now().toUtc();
                    final messenger = ScaffoldMessenger.of(context);
                    final report = Report(
                      id: const Uuid().v4(),
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      address: addrCtrl.text.trim().isNotEmpty ? addrCtrl.text.trim() : null,
                      reporterUserId: currentUser?.id,
                      reporterName: currentUser?.fullName ?? 'Ciudadano Reportante',
                      reporterContact: currentUser?.emailOrPhone,
                      category: selectedCat,
                      priority: selectedPri,
                      status: ReportStatus.pending,
                      latitude: 19.4326,
                      longitude: -99.1332,
                      createdAt: now,
                      updatedAt: now,
                    );
                    Navigator.pop(ctx);
                    await _controller.createReport(report);
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          backgroundColor: ResguardoTheme.safeEmerald,
                          content: Text('✅ Reporte de incidente transmitido al Centro de Comando C5.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar Reporte'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
