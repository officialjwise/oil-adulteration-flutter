import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['7 Days', '30 Days', '90 Days', '1 Year'];

  // New: state for backend data
  final ApiService _api = ApiService();
  bool _loadingSummary = false;
  bool _loadingRecent = false;
  String? _errorSummary;
  String? _errorRecent;
  Map<String, dynamic>? _summary; // from /analytics/summary
  Map<String, dynamic>? _recent; // from /analytics/recent

  // Helpers to read values defensively from maps
  num _numVal(Map<String, dynamic>? m, List<String> keys, {num def = 0}) {
    if (m == null) return def;
    for (final k in keys) {
      final v = m[k];
      if (v is num) return v;
      if (v is String) {
        final p = num.tryParse(v);
        if (p != null) return p;
      }
    }
    return def;
  }

  // Helper for debug - print map keys
  void _printMapKeys(Map<String, dynamic>? m, String label) {
    if (m == null) {
      print('$label: Map is null');
      return;
    }
    print('$label: Map contains keys: ${m.keys.join(', ')}');
    m.forEach((key, value) {
      print('  $key: ${value.runtimeType}');
    });
  }

  List<int> _listOfInt(Map<String, dynamic>? m, List<String> keys) {
    if (m == null) return const [];
    for (final k in keys) {
      final v = m[k];
      if (v is List) {
        try {
          return v
              .map((e) => (e is num) ? e.toInt() : int.parse('$e'))
              .toList();
        } catch (_) {
          continue;
        }
      }
    }
    return const [];
  }

  List<String> _listOfString(Map<String, dynamic>? m, List<String> keys) {
    if (m == null) return const [];
    for (final k in keys) {
      final v = m[k];
      if (v is List) {
        try {
          return v.map((e) => e.toString()).toList();
        } catch (_) {
          continue;
        }
      }
    }
    return const [];
  }

  int _daysForTab(int i) => [7, 30, 90, 365][i.clamp(0, 3)];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadSummary(),
      _loadRecent(days: _daysForTab(_selectedTab)),
    ]);
  }

  Future<void> _loadSummary() async {
    setState(() {
      _loadingSummary = true;
      _errorSummary = null;
    });
    final res = await _api.getAnalyticsSummary();
    if (!mounted) return;
    setState(() {
      _loadingSummary = false;
      if (res.isSuccess) {
        _summary = res.data;
      } else {
        _errorSummary = res.error ?? 'Failed to load summary';
      }
    });
  }

  Future<void> _loadRecent({required int days}) async {
    setState(() {
      _loadingRecent = true;
      _errorRecent = null;
    });
    final res = await _api.getRecentAnalytics(days: days);
    if (!mounted) return;
    setState(() {
      _loadingRecent = false;
      if (res.isSuccess) {
        _recent = res.data;
        _printMapKeys(_recent, 'Recent Analytics');
        
        // Add analyses data to recent for display
        if (_recent != null && _recent!.containsKey('analyses')) {
          print('Found analyses array with ${(_recent!['analyses'] as List?)?.length ?? 0} items');
        }
      } else {
        _errorRecent = res.error ?? 'Failed to load recent analytics';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Analytics',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Performance insights and trends',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFF6B7280),
                        ),
                        onPressed: () {},
                      ),
                      // Removed settings icon per requirements
                    ],
                  ),
                ),
                // Error banners
                if (_errorSummary != null) _errorBanner(_errorSummary!),
                if (_errorRecent != null) _errorBanner(_errorRecent!),
                // Tab bar
                Container(
                  margin: const EdgeInsets.only(
                    top: 8,
                    left: 20,
                    right: 20,
                    bottom: 8,
                  ),
                  child: Row(
                    children: List.generate(_tabs.length, (i) {
                      final selected = i == _selectedTab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedTab = i);
                            _loadRecent(days: _daysForTab(i));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF1746A2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _tabs[i],
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Overview cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _overviewCard(
                        icon: Icons.science,
                        iconColor: const Color(0xFF1746A2),
                        value: _loadingRecent
                            ? '—'
                            : _numVal(_recent, [
                                'total_analyses',
                                'total_tests',
                              ]).toString(),
                        label: 'Total Tests',
                        change: '',
                        changeColor: const Color(0xFF10B981),
                      ),
                      _overviewCard(
                        icon: Icons.track_changes,
                        iconColor: const Color(0xFF059669),
                        value: _loadingRecent
                            ? '—'
                            : '${_calculatePurityRate(_recent)}%',
                        label: 'Purity Rate',
                        change: '',
                        changeColor: const Color(0xFF10B981),
                      ),
                      _overviewCard(
                        icon: Icons.bolt,
                        iconColor: const Color(0xFFF59E0B),
                        value: _loadingSummary
                            ? '—'
                            : '${_numVal(_summary, ['avg_confidence', 'averageConfidence'], def: 92).toString()}%'
                                  .replaceAll('.0%', '%'),
                        label: 'Avg Confidence',
                        change: '',
                        changeColor: const Color(0xFF10B981),
                      ),
                      _overviewCard(
                        icon: Icons.grass_outlined,
                        iconColor: const Color(0xFF1746A2),
                        value: _loadingRecent
                            ? '—'
                            : _getMostAnalyzedOil(),
                        label: 'Most Analyzed',
                        change: '',
                        changeColor: const Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Daily Test Volume
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.show_chart,
                            color: Color(0xFF1746A2),
                            size: 20,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Daily Test Volume',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tests performed over the selected period',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_loadingRecent)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        _BarChart(
                          data:
                              _listOfInt(_recent, [
                                'daily_counts',
                                'counts',
                                'dailyCounts',
                              ]).isNotEmpty
                              ? _listOfInt(_recent, [
                                  'daily_counts',
                                  'counts',
                                  'dailyCounts',
                                ])
                              : const [0, 0, 0, 0, 0, 0, 0],
                          days:
                              _listOfString(_recent, [
                                'labels',
                                'days',
                              ]).isNotEmpty
                              ? _listOfString(_recent, ['labels', 'days'])
                              : const [
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun',
                                ],
                        ),
                    ],
                  ),
                ),
                // Oil Type Distribution
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.pie_chart_outline,
                            color: Color(0xFF1746A2),
                            size: 20,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Oil Type Distribution',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Breakdown by oil type tested',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildOilTypeRows(),
                    ],
                  ),
                ),
                // Quality Results
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.verified,
                            color: Color(0xFF059669),
                            size: 20,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Quality Results',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Purity vs adulteration detection',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _qualityResultLabel(
                            'Pure',
                            _numVal(_recent, [
                              'pure_count',
                              'pure',
                              'pureCount',
                            ]).toInt(),
                            _numVal(_recent, [
                              'pure_rate',
                              'purePercent',
                              'purity_rate',
                            ]).toDouble(),
                            true,
                          ),
                          const SizedBox(width: 24),
                          _qualityResultLabel(
                            'Adulterated',
                            _numVal(_recent, [
                              'adulterated_count',
                              'adulterated',
                              'adulteratedCount',
                            ]).toInt(),
                            _numVal(_recent, [
                              'adulterated_rate',
                              'adulteratedPercent',
                            ]).toDouble(),
                            false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Export Analytics
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.download,
                            color: Color(0xFF1746A2),
                            size: 20,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Export Analytics',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Download detailed reports and data',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _exportButton(
                        Icons.bar_chart,
                        'Download Analytics Report (PDF)',
                        () {},
                      ),
                      const SizedBox(height: 10),
                      _exportButton(
                        Icons.show_chart,
                        'Export Raw Data (CSV)',
                        () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorBanner(String msg) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg, style: const TextStyle(color: Color(0xFF991B1B))),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String change,
    required Color changeColor,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          if (change.isNotEmpty)
            Text(
              change,
              style: TextStyle(
                fontSize: 13,
                color: changeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  List<Widget> _buildOilTypeRows() {
    // Try to read a list of distribution items; support different shapes
    final items =
        _recent?['oil_type_distribution'] ??
        _recent?['distribution'] ??
        _recent?['oilTypes'];
    if (items is List) {
      // Determine counts and total for percent
      int total = 0;
      final parsed = <Map<String, dynamic>>[];
      for (final it in items) {
        if (it is Map) {
          final name =
              (it['name'] ?? it['oil_type'] ?? it['oilType'] ?? 'Unknown')
                  .toString();
          final countRaw = it['count'] ?? it['tests'] ?? it['value'] ?? 0;
          final count = (countRaw is num)
              ? countRaw.toInt()
              : int.tryParse('$countRaw') ?? 0;
          parsed.add({'name': name, 'count': count});
          total += count;
        }
      }
      if (parsed.isNotEmpty) {
        return parsed
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _oilTypeRow(
                  e['name'] as String,
                  '',
                  e['count'] as int,
                  total > 0 ? ((e['count'] as int) * 100 ~/ total) : 0,
                ),
              ),
            )
            .toList();
      }
    }
    // Fallback static if nothing available
    return [
      _oilTypeRow('Palm Oil', '', 0, 0),
      const SizedBox(height: 10),
      _oilTypeRow('Groundnut Oil', '', 0, 0),
    ];
  }

  static Widget _oilTypeRow(String name, String asset, int count, int percent) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFF1F5F9),
          radius: 18,
          child: Text(
            name.toLowerCase().contains('palm')
                ? '🌴'
                : name.toLowerCase().contains('ground')
                ? '🥜'
                : '🛢️',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                '$count tests',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        Text(
          '$percent%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1746A2),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: LinearProgressIndicator(
            value: (percent.clamp(0, 100)) / 100,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF1746A2)),
            minHeight: 7,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  static Widget _qualityResultLabel(
    String label,
    int count,
    double percent,
    bool pure,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pure ? const Color(0xFF1746A2) : const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count samples',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            pure ? 'No adulteration detected' : 'Adulteration found',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: pure
                      ? const Color(0xFF059669)
                      : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: (percent.isNaN ? 0 : percent.clamp(0, 100)) / 100,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation(
                    pure ? const Color(0xFF059669) : const Color(0xFFEF4444),
                  ),
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _exportButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1746A2)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.data, required this.days});

  final List<int> data;
  final List<String> days;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || days.isEmpty) {
      return const Text(
        'No data available',
        style: TextStyle(color: Color(0xFF6B7280)),
      );
    }
    final max = (data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 0)
        .toDouble();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(data.length, (i) {
        final h = (max == 0 ? 0.0 : 90.0 * (data[i] / max));
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 22,
              height: h,
              decoration: BoxDecoration(
                color: const Color(0xFF1746A2),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              i < days.length ? days[i] : '',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            Text(
              '${data[i]}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }),
    );
  }
}
