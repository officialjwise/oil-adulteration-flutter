import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['7 Days', '30 Days', '90 Days', '1 Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Color(0xFF6B7280),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
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
                        onTap: () => setState(() => _selectedTab = i),
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
                      value: '1247',
                      label: 'Total Tests',
                      change: '+12% vs last period',
                      changeColor: const Color(0xFF10B981),
                    ),
                    _overviewCard(
                      icon: Icons.track_changes,
                      iconColor: const Color(0xFF059669),
                      value: '94.2%',
                      label: 'Success Rate',
                      change: '+2.1% vs last period',
                      changeColor: const Color(0xFF10B981),
                    ),
                    _overviewCard(
                      icon: Icons.bolt,
                      iconColor: const Color(0xFFF59E0B),
                      value: '91.8%',
                      label: 'Avg Confidence',
                      change: '+0.8% vs last period',
                      changeColor: const Color(0xFF10B981),
                    ),
                    _overviewCard(
                      icon: Icons.person,
                      iconColor: const Color(0xFF1746A2),
                      value: '12',
                      label: 'Active Users',
                      change: '→ Stable',
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
                      'Tests performed over the last 7 days',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),
                    _BarChart(),
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
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),
                    _oilTypeRow('Palm Oil', 'assets/palm.png', 848, 68),
                    const SizedBox(height: 10),
                    _oilTypeRow(
                      'Groundnut Oil',
                      'assets/groundnut.png',
                      399,
                      32,
                    ),
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
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _qualityResultLabel('Pure', 1175, 94.2, true),
                        const SizedBox(width: 24),
                        _qualityResultLabel('Adulterated', 72, 5.8, false),
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
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
            color: Colors.black.withOpacity(0.04),
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget _oilTypeRow(String name, String asset, int count, int percent) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFF1F5F9),
          radius: 18,
          child: asset.contains('palm')
              ? const Text('🌴', style: TextStyle(fontSize: 20))
              : const Text('🥜', style: TextStyle(fontSize: 20)),
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
            value: percent / 100,
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
                  value: percent / 100,
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
  final List<int> data = const [45, 52, 38, 61, 47, 23, 18];
  final List<String> days = const [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final max = data.reduce((a, b) => a > b ? a : b).toDouble();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(data.length, (i) {
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 22,
              height: 90 * (data[i] / max),
              decoration: BoxDecoration(
                color: const Color(0xFF1746A2),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[i],
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
