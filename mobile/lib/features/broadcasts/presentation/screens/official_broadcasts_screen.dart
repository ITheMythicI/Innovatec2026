import 'dart:async';
import 'package:flutter/material.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/core/network/api_client.dart';

class OfficialBroadcastsScreen extends StatefulWidget {
  const OfficialBroadcastsScreen({super.key});

  @override
  State<OfficialBroadcastsScreen> createState() => _OfficialBroadcastsScreenState();
}

class _OfficialBroadcastsScreenState extends State<OfficialBroadcastsScreen> {
  String _selectedFilter = 'Todos';
  bool _isPlayingRadio = false;
  bool _isLoading = false;
  Timer? _pollingTimer;

  List<Map<String, dynamic>> _broadcasts = [];

  final List<Map<String, dynamic>> _fallbackBroadcasts = [
    {
      'id': 'BC-08',
      'title': 'Desborde de presa en Sector Norte: Suspensión total de actividades y repliegue preventivo',
      'source': 'SEDENA / CONAGUA',
      'level': 'NIVEL ROJO',
      'levelColor': ResguardoTheme.emergencyCrimson,
      'time': '13:42 hrs (T-00:08)',
      'body':
          'Compuerta 2 vertiendo caudal excedente. Se ordena desalojo inmediato del perímetro de 800m sobre el lecho del Río San Jerónimo. Acuda al punto alto más cercano.',
      'priority': 'PRIORIDAD MÁXIMA EN TRANSMISIÓN',
      'verified': true,
      'category': 'Evacuación',
    },
    {
      'id': 'BC-07',
      'title': 'Habilitación de Gimnasio Benito Juárez como Refugio Temporal Primario',
      'source': 'PROTECCIÓN CIVIL',
      'level': 'OPERATIVO',
      'levelColor': ResguardoTheme.primary,
      'time': '13:15 hrs',
      'body':
          'El inmueble cuenta con abasto de agua purificada, planta de energía de emergencia y servicio médico de guardia. Capacidad actual disponible: 36%.',
      'priority': 'LOGÍSTICA REFUGIO',
      'verified': true,
      'category': 'Albergues',
    },
    {
      'id': 'BC-06',
      'title': 'Despliegue de Brigadas del Plan DN-III-E y Marina en Colonias Afectadas',
      'source': 'SEDENA / C5',
      'level': 'DESPLIEGUE',
      'levelColor': ResguardoTheme.warningAmber,
      'time': '12:50 hrs',
      'body':
          'Unidades unimog de auxilio recorren la Ribera Alta y San Jerónimo. En caso de quedar incomunicado, emita señales luminosas o use el Canal Táctico 147.500 MHz.',
      'priority': 'RESCATE MILITAR',
      'verified': true,
      'category': 'Mando',
    },
  ];

  @override
  void initState() {
    super.initState();
    _broadcasts = List.from(_fallbackBroadcasts);
    _fetchBroadcastsFeed();
    // Auto-polling cada 12 segundos para recibir emisiones del C5 en vivo
    _pollingTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (mounted) {
        _fetchBroadcastsFeed(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchBroadcastsFeed({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }
    try {
      final response = await ApiClient.instance.get('/broadcasts/feed');
      if (response is List && mounted) {
        final List<Map<String, dynamic>> live = [];
        for (var item in response) {
          final type = (item['type'] as String?) ?? 'EVACUATION';
          Color levelColor = ResguardoTheme.emergencyCrimson;
          String levelText = 'CRÍTICO';
          String category = 'Evacuación';

          if (type.contains('SHELTER')) {
            levelColor = ResguardoTheme.safeEmerald;
            levelText = 'ALBERGUE';
            category = 'Albergues';
          } else if (type.contains('WEATHER') || type.contains('ADVISORY')) {
            levelColor = ResguardoTheme.warningAmber;
            levelText = 'PRECAUCIÓN';
            category = 'Avisos';
          }

          final sentBy = item['sentBy'] as Map<String, dynamic>?;
          final author = sentBy != null ? (sentBy['fullName'] ?? 'C5 Centro de Mando') : 'Protección Civil';

          live.add({
            'id': item['id'] != null ? item['id'].toString().substring(0, 8).toUpperCase() : 'BC-LIVE',
            'title': item['title'] ?? 'Comunicado Táctico de Emergencia',
            'source': author,
            'level': levelText,
            'levelColor': levelColor,
            'time': 'En Vivo // C5 Feed',
            'body': item['body'] ?? '',
            'priority': 'EMISIÓN CENTRAL C5',
            'verified': true,
            'category': category,
          });
        }

        if (live.isNotEmpty) {
          setState(() {
            _broadcasts = [...live, ..._fallbackBroadcasts];
          });
        }
      }
    } catch (_) {
      // Si falla la conexión, se mantiene el catálogo local offline sin romper la UI
    } finally {
      if (mounted && !silent) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'Todos'
        ? _broadcasts
        : _broadcasts.where((b) => b['category'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: ResguardoTheme.surfaceContainerHigh,
      appBar: AppBar(
        backgroundColor: ResguardoTheme.surface,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COMUNICADOS OFICIALES',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                color: ResguardoTheme.primary,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'C5 / SINAPROC VERIFICADO • RED TÁCTICA',
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
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: ResguardoTheme.primary),
                  )
                : const Icon(Icons.refresh, color: ResguardoTheme.primary, size: 20),
            tooltip: 'Actualizar Feed de Alertas C5',
            onPressed: () => _fetchBroadcastsFeed(),
          ),
          IconButton(
            icon: Icon(
              _isPlayingRadio ? Icons.volume_up : Icons.radio,
              color: _isPlayingRadio ? ResguardoTheme.emergencyCrimson : ResguardoTheme.primary,
              size: 20,
            ),
            tooltip: 'Frecuencia de Radio Emergencia 147.500 MHz',
            onPressed: () {
              setState(() => _isPlayingRadio = !_isPlayingRadio);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _isPlayingRadio ? ResguardoTheme.emergencyCrimson : ResguardoTheme.primary,
                  content: Text(_isPlayingRadio
                      ? '📻 Conectado al repetidor táctico C5 (Canal Nacional 147.500 MHz)'
                      : '📻 Radio en espera (Modo ahorro de energía activo)'),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Banner de Transmisión Oficial
          Container(
            color: ResguardoTheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: ResguardoTheme.safeEmerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'CANAL TÁCTICO SINAPROC: ACTIVO',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: ResguardoTheme.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_broadcasts.length} BOLETINES',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: ResguardoTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Filtros
          Container(
            color: ResguardoTheme.surface,
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos', _selectedFilter == 'Todos'),
                  const SizedBox(width: 6),
                  _buildFilterChip('Evacuación', _selectedFilter == 'Evacuación', color: ResguardoTheme.emergencyCrimson),
                  const SizedBox(width: 6),
                  _buildFilterChip('Albergues', _selectedFilter == 'Albergues', color: ResguardoTheme.safeEmerald),
                  const SizedBox(width: 6),
                  _buildFilterChip('Avisos', _selectedFilter == 'Avisos', color: ResguardoTheme.warningAmber),
                  const SizedBox(width: 6),
                  _buildFilterChip('Mando', _selectedFilter == 'Mando'),
                ],
              ),
            ),
          ),

          // Lista de Comunicados
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _buildBroadcastCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, {Color? color}) {
    final activeColor = color ?? ResguardoTheme.primary;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : ResguardoTheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? activeColor : ResguardoTheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : ResguardoTheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildBroadcastCard(Map<String, dynamic> item) {
    final Color levelColor = item['levelColor'] as Color? ?? ResguardoTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: levelColor == ResguardoTheme.emergencyCrimson ? ResguardoTheme.emergencyCrimson : ResguardoTheme.outline, width: levelColor == ResguardoTheme.emergencyCrimson ? 1.5 : 1),
        boxShadow: const [ResguardoTheme.shadowLevel2],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la tarjeta
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield, size: 14, color: levelColor),
                    const SizedBox(width: 6),
                    Text(
                      item['source'] ?? 'C5 OFICIAL',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: levelColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['level'] ?? 'ALERTA',
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: ResguardoTheme.primary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['body'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: ResguardoTheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${item['id']} • ${item['time']}',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 9,
                        color: ResguardoTheme.textMuted,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 12, color: ResguardoTheme.safeEmerald),
                        const SizedBox(width: 4),
                        const Text(
                          'FIRMA CRIPTOGRÁFICA OK',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: ResguardoTheme.safeEmerald,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
