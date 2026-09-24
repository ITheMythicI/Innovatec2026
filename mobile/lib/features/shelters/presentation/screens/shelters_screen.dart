import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/features/shelters/domain/models/shelter.dart';
import 'package:innovatec_mobile/features/shelters/presentation/controllers/shelter_controller.dart';

class SheltersScreen extends StatefulWidget {
  const SheltersScreen({super.key});

  @override
  State<SheltersScreen> createState() => _SheltersScreenState();
}

class _SheltersScreenState extends State<SheltersScreen> {
  late final ShelterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ShelterController();
    _controller.loadShelters();
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
              'Red de Albergues & Refugio',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                color: ResguardoTheme.primary,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Sincronizar Albergues',
                icon: const Icon(Icons.sync, color: ResguardoTheme.primary),
                onPressed: () => _controller.sync(),
              ),
              IconButton(
                tooltip: 'Registrar Nuevo Albergue',
                icon: const Icon(Icons.add_home_work_outlined, color: ResguardoTheme.primary),
                onPressed: () => _showCreateShelterDialog(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Barra de Filtros Rápidos (Design.md)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    FilterChip(
                      selected: _controller.onlyAvailable,
                      label: const Text('Solo con Camas Disponibles'),
                      labelStyle: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _controller.onlyAvailable ? Colors.white : ResguardoTheme.primary,
                      ),
                      selectedColor: ResguardoTheme.primary,
                      backgroundColor: ResguardoTheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: const BorderSide(color: ResguardoTheme.outline),
                      ),
                      onSelected: (val) => _controller.toggleOnlyAvailable(val),
                    ),
                  ],
                ),
              ),

              // Lista de Albergues
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_controller.status == ShelterStateStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: ResguardoTheme.primary));
    }

    if (_controller.shelters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.night_shelter_outlined, size: 48, color: ResguardoTheme.textMuted),
              const SizedBox(height: 12),
              const Text(
                'Sin Albergues en Caché Local',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: ResguardoTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Conecta a red para sincronizar los albergues habilitados por Protección Civil.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', color: ResguardoTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _controller.loadShelters(forceRefresh: true),
                child: const Text('Actualizar Albergues'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: ResguardoTheme.primary,
      onRefresh: () => _controller.loadShelters(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _controller.shelters.length,
        itemBuilder: (context, index) {
          final shelter = _controller.shelters[index];
          return _buildShelterCard(shelter);
        },
      ),
    );
  }

  Widget _buildShelterCard(Shelter shelter) {
    Color statusColor = ResguardoTheme.safeEmerald;
    if (shelter.status == ShelterStatus.full) {
      statusColor = ResguardoTheme.emergencyCrimson;
    } else if (shelter.status == ShelterStatus.closed || shelter.status == ShelterStatus.evacuating) {
      statusColor = ResguardoTheme.warningAmber;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: ResguardoTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ResguardoTheme.outline, width: 1),
        boxShadow: const [ResguardoTheme.shadowLevel2],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador notch 4px
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
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
                        Expanded(
                          child: Text(
                            shelter.name,
                            style: const TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: ResguardoTheme.primary,
                            ),
                          ),
                        ),
                        _buildStatusBadge(shelter.status.displayName, statusColor),
                      ],
                    ),
                    if (shelter.address != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        shelter.address!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: ResguardoTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Barra de Ocupación Telemetría (Design.md)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'OCUPACIÓN: ${shelter.currentOccupancy} / ${shelter.capacity} CAMAS',
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ResguardoTheme.primary,
                              ),
                            ),
                            Text(
                              '${(shelter.occupancyPercentage * 100).toInt()}%',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: shelter.occupancyPercentage,
                            backgroundColor: ResguardoTheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),

                    if (shelter.services.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: shelter.services.map((svc) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ResguardoTheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: ResguardoTheme.outline),
                            ),
                            child: Text(
                              svc.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: ResguardoTheme.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 8),
                    if (shelter.syncStatus.startsWith('pending'))
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Pendiente de envío',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            color: ResguardoTheme.warningAmber,
                          ),
                        ),
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

  void _showCreateShelterDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final capCtrl = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: ResguardoTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: ResguardoTheme.primary, width: 1.5),
          ),
          title: const Text(
            'Registrar Nuevo Albergue',
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
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre del Albergue *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addrCtrl,
                  decoration: const InputDecoration(labelText: 'Dirección o Punto de Referencia'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: capCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Capacidad en Camas *'),
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
                if (nameCtrl.text.trim().isEmpty) return;
                final shelter = Shelter(
                  id: const Uuid().v4(),
                  name: nameCtrl.text.trim(),
                  address: addrCtrl.text.trim(),
                  latitude: 19.4326,
                  longitude: -99.1332,
                  capacity: int.tryParse(capCtrl.text.trim()) ?? 50,
                  currentOccupancy: 0,
                  status: ShelterStatus.open,
                  services: ['AGUA', 'MÉDICO', 'ENERGÍA', 'ALIMENTOS'],
                  createdAt: DateTime.now().toUtc(),
                  updatedAt: DateTime.now().toUtc(),
                );
                Navigator.pop(ctx);
                await _controller.createShelter(shelter);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
