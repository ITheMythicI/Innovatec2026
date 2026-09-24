import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/features/emergencies/domain/models/emergency.dart';
import 'package:innovatec_mobile/features/emergencies/presentation/controllers/emergency_controller.dart';

class EmergenciesScreen extends StatefulWidget {
  const EmergenciesScreen({super.key});

  @override
  State<EmergenciesScreen> createState() => _EmergenciesScreenState();
}

class _EmergenciesScreenState extends State<EmergenciesScreen> {
  late final EmergencyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EmergencyController();
    _controller.loadEmergencies();
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
              'Emergencias & Desastres',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                color: ResguardoTheme.primary,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Sincronizar Catálogo',
                icon: const Icon(Icons.sync, color: ResguardoTheme.primary),
                onPressed: () => _controller.sync(),
              ),
              IconButton(
                tooltip: 'Nueva Alerta de Emergencia',
                icon: const Icon(Icons.add_alert, color: ResguardoTheme.emergencyCrimson),
                onPressed: () => _showCreateEmergencyDialog(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Botón SOS de Emergencia Crítica Rápida (Design.md)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ResguardoTheme.emergencyCrimson,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _triggerInstantSos(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'ACTIVAR ALERTA SOS CRÍTICA',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Filtros de Severidad
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    _buildFilterChip('Todas', _controller.selectedSeverity == null, () {
                      _controller.filterBySeverity(null);
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Crítica', _controller.selectedSeverity == EmergencySeverity.critical, () {
                      _controller.filterBySeverity(EmergencySeverity.critical);
                    }, color: ResguardoTheme.emergencyCrimson),
                    const SizedBox(width: 8),
                    _buildFilterChip('Alta', _controller.selectedSeverity == EmergencySeverity.high, () {
                      _controller.filterBySeverity(EmergencySeverity.high);
                    }, color: ResguardoTheme.warningAmber),
                    const SizedBox(width: 8),
                    _buildFilterChip('Media', _controller.selectedSeverity == EmergencySeverity.medium, () {
                      _controller.filterBySeverity(EmergencySeverity.medium);
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Baja', _controller.selectedSeverity == EmergencySeverity.low, () {
                      _controller.filterBySeverity(EmergencySeverity.low);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Lista de Emergencias
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {Color? color}) {
    final activeColor = color ?? ResguardoTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : ResguardoTheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? activeColor : ResguardoTheme.outline,
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
    if (_controller.status == EmergencyStateStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: ResguardoTheme.primary));
    }

    if (_controller.status == EmergencyStateStatus.error && _controller.emergencies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: ResguardoTheme.textMuted),
              const SizedBox(height: 12),
              const Text(
                'Modo Offline Activo',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: ResguardoTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'No hay emergencias registradas localmente en este momento.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', color: ResguardoTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _controller.loadEmergencies(forceRefresh: true),
                child: const Text('Reintentar Conexión'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.emergencies.isEmpty) {
      return const Center(
        child: Text(
          'No hay emergencias registradas en esta categoría.',
          style: TextStyle(fontFamily: 'Inter', color: ResguardoTheme.textMuted, fontSize: 14),
        ),
      );
    }

    return RefreshIndicator(
      color: ResguardoTheme.primary,
      onRefresh: () => _controller.loadEmergencies(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _controller.emergencies.length,
        itemBuilder: (context, index) {
          final emergency = _controller.emergencies[index];
          return _buildEmergencyCard(emergency);
        },
      ),
    );
  }

  Widget _buildEmergencyCard(Emergency emergency) {
    Color borderColor = ResguardoTheme.outline;
    Color notchColor = ResguardoTheme.safeEmerald;

    if (emergency.severity == EmergencySeverity.critical) {
      borderColor = ResguardoTheme.emergencyCrimson;
      notchColor = ResguardoTheme.emergencyCrimson;
    } else if (emergency.severity == EmergencySeverity.high) {
      borderColor = ResguardoTheme.warningAmber;
      notchColor = ResguardoTheme.warningAmber;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: ResguardoTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: emergency.severity == EmergencySeverity.critical ? 2 : 1),
        boxShadow: const [ResguardoTheme.shadowLevel2],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador notch vertical de 4px (Design.md)
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: notchColor,
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
                        // Meta-label
                        Text(
                          emergency.type.displayName.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ResguardoTheme.textMuted,
                          ),
                        ),
                        // Badge de severidad
                        _buildBadge(emergency.severity.displayName, notchColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      emergency.title,
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: ResguardoTheme.primary,
                      ),
                    ),
                    if (emergency.description != null && emergency.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        emergency.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: ResguardoTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: ResguardoTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${emergency.latitude.toStringAsFixed(4)}, ${emergency.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 11,
                            color: ResguardoTheme.textMuted,
                          ),
                        ),
                        const Spacer(),
                        if (emergency.syncStatus.startsWith('pending'))
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

  Widget _buildBadge(String text, Color color) {
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

  void _triggerInstantSos(BuildContext context) async {
    final newSos = Emergency(
      id: const Uuid().v4(),
      title: 'ALERTA SOS - IMPACTO URGENTE',
      description: 'Señal de auxilio prioritaria generada en campo por brigadista.',
      type: EmergencyType.other,
      severity: EmergencySeverity.critical,
      status: EmergencyStatus.active,
      latitude: 19.4326,
      longitude: -99.1332,
      startedAt: DateTime.now().toUtc(),
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    await _controller.createEmergency(newSos);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: ResguardoTheme.emergencyCrimson,
        content: Text(
          'Alerta SOS generada y registrada en cola local SQLite para retransmisión.',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showCreateEmergencyDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    EmergencySeverity selectedSev = EmergencySeverity.medium;
    EmergencyType selectedType = EmergencyType.earthquake;

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
                'Registrar Alerta de Emergencia',
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
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Título del Suceso *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Descripción / Situación'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<EmergencyType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Tipo de Evento'),
                      items: EmergencyType.values.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.displayName));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedType = val!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<EmergencySeverity>(
                      initialValue: selectedSev,
                      decoration: const InputDecoration(labelText: 'Nivel de Severidad'),
                      items: EmergencySeverity.values.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s.displayName));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedSev = val!),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ResguardoTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;
                    final emergency = Emergency(
                      id: const Uuid().v4(),
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      type: selectedType,
                      severity: selectedSev,
                      status: EmergencyStatus.active,
                      latitude: 19.4326,
                      longitude: -99.1332,
                      startedAt: DateTime.now().toUtc(),
                      createdAt: DateTime.now().toUtc(),
                      updatedAt: DateTime.now().toUtc(),
                    );
                    Navigator.pop(ctx);
                    await _controller.createEmergency(emergency);
                  },
                  child: const Text('Registrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
