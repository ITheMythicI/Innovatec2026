import 'package:flutter/material.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';

class OfficialBroadcastsScreen extends StatefulWidget {
  const OfficialBroadcastsScreen({super.key});

  @override
  State<OfficialBroadcastsScreen> createState() => _OfficialBroadcastsScreenState();
}

class _OfficialBroadcastsScreenState extends State<OfficialBroadcastsScreen> {
  String _selectedFilter = 'Todos';
  bool _isPlayingRadio = false;

  final List<Map<String, dynamic>> _broadcasts = [
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
      'category': 'CONAGUA',
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
      'category': 'Protección Civil',
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
      'category': 'SEDENA',
    },
    {
      'id': 'BC-05',
      'title': 'Puntos de Distribución de Agua Potable y Kits de Primeros Auxilios',
      'source': 'CRUZ ROJA MEXICANA',
      'level': 'ASISTENCIA',
      'levelColor': ResguardoTheme.safeEmerald,
      'time': '12:10 hrs',
      'body':
          'Puesto de socorro instalado en Explanada Hidalgo. Raciones secas y suero oral disponibles para personas vulnerables y menores.',
      'priority': 'AYUDA HUMANITARIA',
      'verified': true,
      'category': 'Cruz Roja',
    },
  ];

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
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ResguardoTheme.safeEmerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ResguardoTheme.safeEmerald),
            ),
            child: const Row(
              children: [
                Icon(Icons.cell_tower, color: ResguardoTheme.safeEmerald, size: 12),
                SizedBox(width: 4),
                Text(
                  'EN LÍNEA',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: ResguardoTheme.safeEmerald,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Radio Player Táctico (FM 98.5 MHz / 147.500 VHF)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: ResguardoTheme.primary,
            child: Row(
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: _isPlayingRadio ? ResguardoTheme.emergencyCrimson : Colors.white24,
                  ),
                  icon: Icon(
                    _isPlayingRadio ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _isPlayingRadio = !_isPlayingRadio);
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _isPlayingRadio ? 'TRANSMISIÓN EN VIVO' : 'RADIO PROTECCIÓN CIVIL',
                            style: const TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'FM 98.5 / 147.500 VHF',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                color: Colors.white,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Banda táctica oficial sin consumo de datos',
                        style: TextStyle(fontFamily: 'Inter', color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.offline_pin, color: Colors.white70, size: 16),
              ],
            ),
          ),

          // Filtros de Emisor
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildFilterTab('Todos', 12),
                  const SizedBox(width: 6),
                  _buildFilterTab('Protección Civil', 5),
                  const SizedBox(width: 6),
                  _buildFilterTab('CONAGUA', 4),
                  const SizedBox(width: 6),
                  _buildFilterTab('SEDENA', 2),
                  const SizedBox(width: 6),
                  _buildFilterTab('Cruz Roja', 1),
                ],
              ),
            ),
          ),

          // Lista de Boletines
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final b = filtered[i];
                final isRed = b['level'] == 'NIVEL ROJO';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isRed ? ResguardoTheme.emergencyCrimson : ResguardoTheme.outlineVariant,
                      width: isRed ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header del comunicado
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isRed
                              ? ResguardoTheme.emergencyCrimson.withValues(alpha: 0.08)
                              : ResguardoTheme.surfaceContainerHigh,
                          border: Border(
                            bottom: BorderSide(
                              color: isRed ? ResguardoTheme.emergencyCrimson.withValues(alpha: 0.2) : ResguardoTheme.outlineVariant,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: b['levelColor'],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    b['level'],
                                    style: const TextStyle(
                                      fontFamily: 'JetBrains Mono',
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.verified, size: 14, color: ResguardoTheme.safeEmerald),
                                const SizedBox(width: 4),
                                Text(
                                  b['source'],
                                  style: const TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: ResguardoTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              b['time'],
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                color: ResguardoTheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Cuerpo
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b['title'],
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isRed ? ResguardoTheme.emergencyCrimson : ResguardoTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              b['body'],
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                height: 1.4,
                                color: ResguardoTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: ResguardoTheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.shield, size: 11, color: ResguardoTheme.outline),
                                      const SizedBox(width: 4),
                                      Text(
                                        b['priority'],
                                        style: const TextStyle(
                                          fontFamily: 'JetBrains Mono',
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: ResguardoTheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Text(
                                  'OFICIAL • NO PROPAGAR RUMORES',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: ResguardoTheme.safeEmerald,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, int count) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? ResguardoTheme.primary : ResguardoTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? ResguardoTheme.primary : ResguardoTheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : ResguardoTheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : ResguardoTheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
