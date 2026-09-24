import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/features/shelters/domain/models/shelter.dart';
import 'package:innovatec_mobile/features/shelters/presentation/controllers/shelter_controller.dart';
import 'package:innovatec_mobile/features/map/presentation/screens/evacuation_route_screen.dart';

class SheltersScreen extends StatefulWidget {
  const SheltersScreen({super.key});

  @override
  State<SheltersScreen> createState() => _SheltersScreenState();
}

class _SheltersScreenState extends State<SheltersScreen> {
  late final ShelterController _controller;
  String _searchQuery = '';
  String? _selectedServiceFilter;
  final Set<String> _checkedInShelterIds = {};

  @override
  void initState() {
    super.initState();
    _controller = ShelterController();
    _controller.loadShelters(forceRefresh: true);
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
        final allShelters = _controller.shelters;
        final filteredShelters = allShelters.where((s) {
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            final matchesName = s.name.toLowerCase().contains(query);
            final matchesAddr = (s.address ?? '').toLowerCase().contains(query);
            if (!matchesName && !matchesAddr) return false;
          }
          if (_selectedServiceFilter != null) {
            final hasService = s.services.any((svc) =>
                svc.toLowerCase().contains(_selectedServiceFilter!.toLowerCase()));
            if (!hasService) return false;
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: ResguardoTheme.background,
          appBar: AppBar(
            backgroundColor: ResguardoTheme.surface,
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Red de Albergues & Refugio',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.w700,
                    color: ResguardoTheme.primary,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'CAPACIDAD EN TIEMPO REAL • PROTOCOLO SINAPROC',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: ResguardoTheme.outline,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
              // Buscador y Filtros Rápidos
              Container(
                color: ResguardoTheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Buscar albergue por nombre o colonia...',
                        prefixIcon: const Icon(Icons.search, size: 20, color: ResguardoTheme.textMuted),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        fillColor: ResguardoTheme.surfaceContainerLow,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            selected: _controller.onlyAvailable,
                            label: const Text('Con Cupo Disponible'),
                            labelStyle: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _controller.onlyAvailable ? Colors.white : ResguardoTheme.primary,
                            ),
                            selectedColor: ResguardoTheme.primary,
                            backgroundColor: ResguardoTheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: const BorderSide(color: ResguardoTheme.outline),
                            ),
                            onSelected: (val) => _controller.toggleOnlyAvailable(val),
                          ),
                          const SizedBox(width: 6),
                          _buildServiceFilterChip('Médico', 'MEDICAL', Icons.medical_services_outlined),
                          const SizedBox(width: 6),
                          _buildServiceFilterChip('Comida/Agua', 'FOOD', Icons.restaurant_outlined),
                          const SizedBox(width: 6),
                          _buildServiceFilterChip('Mascotas', 'PET', Icons.pets_outlined),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de Albergues
              Expanded(
                child: _buildContent(filteredShelters),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceFilterChip(String label, String serviceKey, IconData icon) {
    final isSelected = _selectedServiceFilter == serviceKey;
    return FilterChip(
      selected: isSelected,
      avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : ResguardoTheme.primary),
      label: Text(label),
      labelStyle: TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : ResguardoTheme.primary,
      ),
      selectedColor: ResguardoTheme.safeEmerald,
      backgroundColor: ResguardoTheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: ResguardoTheme.outline),
      ),
      onSelected: (val) {
        setState(() {
          _selectedServiceFilter = val ? serviceKey : null;
        });
      },
    );
  }

  Widget _buildContent(List<Shelter> shelters) {
    if (_controller.status == ShelterStateStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: ResguardoTheme.primary));
    }

    if (shelters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.night_shelter_outlined, size: 48, color: ResguardoTheme.textMuted),
              const SizedBox(height: 12),
              const Text(
                'No se encontraron albergues',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: ResguardoTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Intenta con otros filtros de búsqueda o sincroniza la base de datos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', color: ResguardoTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Recargar Catálogo'),
                onPressed: () => _controller.loadShelters(forceRefresh: true),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: shelters.length,
      itemBuilder: (context, index) {
        final shelter = shelters[index];
        return _buildShelterCard(shelter);
      },
    );
  }

  Widget _buildShelterCard(Shelter shelter) {
    Color statusColor = ResguardoTheme.safeEmerald;
    if (shelter.status == ShelterStatus.full || shelter.occupancyPercentage >= 0.9) {
      statusColor = ResguardoTheme.emergencyCrimson;
    } else if (shelter.occupancyPercentage >= 0.7) {
      statusColor = ResguardoTheme.warningAmber;
    }

    final isCheckedIn = _checkedInShelterIds.contains(shelter.id);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: ResguardoTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCheckedIn ? ResguardoTheme.safeEmerald : ResguardoTheme.outline,
          width: isCheckedIn ? 2 : 1,
        ),
        boxShadow: const [ResguardoTheme.shadowLevel2],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador vertical de estado
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
                padding: const EdgeInsets.all(12.0),
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
                              fontSize: 15,
                              color: ResguardoTheme.primary,
                            ),
                          ),
                        ),
                        if (isCheckedIn)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ResguardoTheme.safeEmerald,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'MI ALBERGUE',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          _buildStatusBadge(shelter.status.displayName, statusColor),
                      ],
                    ),
                    if (shelter.address != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: ResguardoTheme.textMuted),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              shelter.address!,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: ResguardoTheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),

                    // Barra de Ocupación
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'OCUPACIÓN: ${shelter.currentOccupancy} / ${shelter.capacity} PERSONAS',
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: ResguardoTheme.primary,
                              ),
                            ),
                            Text(
                              '${(shelter.occupancyPercentage * 100).toInt()}%',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: shelter.occupancyPercentage,
                            backgroundColor: ResguardoTheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),

                    // Tags de Servicios
                    if (shelter.services.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: shelter.services.map((svc) {
                          String label = svc.replaceAll('_', ' ');
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ResguardoTheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: ResguardoTheme.outline),
                            ),
                            child: Text(
                              label.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: ResguardoTheme.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Botones de Acción Táctica
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ResguardoTheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(color: ResguardoTheme.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            icon: const Icon(Icons.near_me, size: 14),
                            label: const Text(
                              'Trazar Ruta',
                              style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const EvacuationRouteScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCheckedIn ? ResguardoTheme.textMuted : ResguardoTheme.safeEmerald,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            icon: Icon(isCheckedIn ? Icons.check_circle : Icons.login, size: 14),
                            label: Text(
                              isCheckedIn ? 'Registrado' : 'Check-in',
                              style: const TextStyle(fontFamily: 'Space Grotesk', fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              setState(() {
                                if (isCheckedIn) {
                                  _checkedInShelterIds.remove(shelter.id);
                                } else {
                                  _checkedInShelterIds.add(shelter.id);
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: ResguardoTheme.safeEmerald,
                                  content: Text(
                                    isCheckedIn
                                        ? 'Has salido del albergue ${shelter.name}. Cupo liberado.'
                                        : '✅ ¡Check-in confirmado en ${shelter.name}! Censo actualizado en el C5.',
                                  ),
                                ),
                              );
                            },
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 9,
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
              fontSize: 16,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre del Albergue o Refugio *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addrCtrl,
                  decoration: const InputDecoration(labelText: 'Dirección o Ubicación *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: capCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Capacidad Total de Camas *'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final addr = addrCtrl.text.trim();
                final cap = int.tryParse(capCtrl.text) ?? 50;

                if (name.isNotEmpty) {
                  final now = DateTime.now().toUtc();
                  final newShelter = Shelter(
                    id: const Uuid().v4(),
                    name: name,
                    address: addr.isNotEmpty ? addr : null,
                    latitude: 19.4326,
                    longitude: -99.1332,
                    capacity: cap,
                    currentOccupancy: 0,
                    status: ShelterStatus.open,
                    services: const ['MEDICAL', 'FOOD', 'WATER'],
                    createdAt: now,
                    updatedAt: now,
                  );

                  final messenger = ScaffoldMessenger.of(context);
                  await _controller.createShelter(newShelter);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                        backgroundColor: ResguardoTheme.safeEmerald,
                        content: Text('Albergue registrado y transmitido al Centro de Mando.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
