import 'package:flutter/material.dart';
import '../../core/theme.dart';

class InfluencerAnalyticsScreen extends StatelessWidget {
  const InfluencerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: KonektaColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Small blue pill header — "Konekta" only
          Container(
            padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 16),
            decoration: const BoxDecoration(
              gradient: KonektaColors.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const Text(
              'Konekta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + subtitle outside header
                  const Text(
                    'Performance',
                    style: TextStyle(
                      color: KonektaColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Daily metrics and growth analysis for your all Campaigns',
                    style: TextStyle(
                      color: KonektaColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Segmented Control
                  _SegmentedControl(),
                  const SizedBox(height: 20),

                    // Daily Performance Card
                    const _DailyPerformanceCard(),
                    const SizedBox(height: 30),

                    const Text(
                      'GROWTH (7D)',
                      style: TextStyle(
                        color: KonektaColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const _GrowthGrid(),
                    const SizedBox(height: 30),

                    const Text(
                      'RECENT EARNINGS',
                      style: TextStyle(
                        color: KonektaColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 15),

                    const _EarningsTableCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }
}

// --- Segmented Control ---

class _SegmentedControl extends StatefulWidget {
  @override
  State<_SegmentedControl> createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<_SegmentedControl> {
  int _selected = 0;
  final _tabs = ['Weekly', 'Monthly', 'Annually'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: KonektaColors.border,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isSelected = _selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      color: isSelected ? KonektaColors.primary : KonektaColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// --- Daily Performance Card ---

class _DailyPerformanceCard extends StatelessWidget {
  const _DailyPerformanceCard();

  static const _data = [
    {'views': 60, 'eng': 35, 'day': 'MON'},
    {'views': 45, 'eng': 25, 'day': 'TUE'},
    {'views': 70, 'eng': 40, 'day': 'WED'},
    {'views': 55, 'eng': 20, 'day': 'THU'},
    {'views': 85, 'eng': 45, 'day': 'FRI'},
    {'views': 65, 'eng': 30, 'day': 'SAT'},
    {'views': 75, 'eng': 38, 'day': 'SUN'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ACTIVITY LOG',
                style: TextStyle(
                  color: KonektaColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  _legendItem(KonektaColors.primary, 'Views'),
                  const SizedBox(width: 15),
                  _legendItem(const Color(0xFFC48AFF), 'Engagement'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Daily\nPerformance',
            style: TextStyle(
              color: KonektaColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 25),
          _buildBarChart(),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: KonektaColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildBarChart() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _data.map((item) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 15,
                  height: (item['views'] as int).toDouble(),
                  decoration: const BoxDecoration(
                    color: KonektaColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Container(
                  width: 15,
                  height: (item['eng'] as int).toDouble(),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC48AFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _data.map((item) {
            return SizedBox(
              width: 33,
              child: Text(
                item['day'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: KonektaColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// --- Growth Grid ---

class _GrowthGrid extends StatelessWidget {
  const _GrowthGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: const [
        _GrowthCard(title: 'NEW FOLLOWERS', value: '+1.2k', valueColor: KonektaColors.success),
        _GrowthCard(title: 'ENGAGEMENT RATE', value: '8.2%', valueColor: KonektaColors.primary),
        _GrowthCard(title: 'TOTAL LIKES', value: '45k', valueColor: KonektaColors.primary),
        _GrowthCard(title: 'TOTAL COMMENTS', value: '-1.2k', valueColor: KonektaColors.danger),
      ],
    );
  }
}

class _GrowthCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _GrowthCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: KonektaColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Earnings Table ---

class _EarningsTableCard extends StatelessWidget {
  const _EarningsTableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: KonektaColors.border,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('DESCRIPTION',
                      style: TextStyle(color: KonektaColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('DATE',
                      style: TextStyle(color: KonektaColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('AMOUNT',
                        style: TextStyle(color: KonektaColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                  ),
                ),
              ],
            ),
          ),

          // Rows
          const _EarningsRow(amount: '+Rp125.000'),
          const _EarningsRow(amount: '+Rp123.000'),
          const _EarningsRow(amount: '+Rp99.000'),

          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFFBFDFF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Center(
              child: Text(
                'SHOW ALL TRANSACTIONS',
                style: TextStyle(
                  color: KonektaColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsRow extends StatelessWidget {
  final String amount;
  const _EarningsRow({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Description
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: KonektaColors.softBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.campaign, color: KonektaColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summer\nTech Series',
                        style: TextStyle(
                          color: KonektaColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ref: #TXN-90281',
                        style: TextStyle(color: KonektaColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Date
          const Expanded(
            flex: 2,
            child: Text(
              'Oct\n24, 2023',
              style: TextStyle(color: KonektaColors.textSecondary, fontSize: 12, height: 1.2),
            ),
          ),
          // Amount
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                amount,
                style: const TextStyle(
                  color: KonektaColors.success,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
