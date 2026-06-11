import 'package:flutter/material.dart';

void main() {
  runApp(const KonektaApp());
}

class KonektaApp extends StatelessWidget {
  const KonektaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Konekta Performance',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F8CFF)),
        useMaterial3: true,
      ),
      home: const PerformanceScreen(),
    );
  }
}

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Blue Header
            Container(
              height: 140,
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF3F8CFF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: kToolbarHeight - 20),
                  Text(
                    'Konekta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Performance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    const Text(
                      'Daily metrics and growth analysis for your all Campaigns',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Segmented Control (Weekly, Monthly, Annually)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EAF2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSegmentItem('Weekly', isSelected: true),
                          _buildSegmentItem('Monthly', isSelected: false),
                          _buildSegmentItem('Annually', isSelected: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Daily Performance Chart Card
                    _buildDailyPerformanceCard(),
                    const SizedBox(height: 30),

                    // Growth (7D) Title
                    const Text(
                      'GROWTH (7D)',
                      style: TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Growth Grid
                    _buildGrowthGrid(),
                    const SizedBox(height: 30),

                    // Recent Earnings Title
                    const Text(
                      'RECENT EARNINGS',
                      style: TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Earnings Table Card
                    _buildEarningsTableCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSegmentItem(String text, {required bool isSelected}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? const Color(0xFF3F8CFF) : const Color(0xFF6B7280),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyPerformanceCard() {
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
          // Header Row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVITY LOG',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  _buildLegendItem(Color(0xFF3F8CFF), 'Views'),
                  SizedBox(width: 15),
                  _buildLegendItem(Color(0xFFC48AFF), 'Engagement'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Large Title
          const Text(
            'Daily\nPerformance',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 25),
          // Chart
          _buildBarChart(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
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
        Text(
          text,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final data = [
      {'views': 60, 'eng': 35, 'day': 'MON'},
      {'views': 45, 'eng': 25, 'day': 'TUE'},
      {'views': 70, 'eng': 40, 'day': 'WED'},
      {'views': 55, 'eng': 20, 'day': 'THU'},
      {'views': 85, 'eng': 45, 'day': 'FRI'},
      {'views': 65, 'eng': 30, 'day': 'SAT'},
      {'views': 75, 'eng': 38, 'day': 'SUN'},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((item) {
            double viewsHeight = (item['views'] as num).toDouble();
            double engHeight = (item['eng'] as num).toDouble();
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 15,
                  height: viewsHeight,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3F8CFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Container(
                  width: 15,
                  height: engHeight,
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
          children: data.map((item) {
            return SizedBox(
              width: 33,
              child: Text(
                item['day'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
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

  Widget _buildGrowthGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _buildGrowthCard(
          title: 'NEW FOLLOWERS',
          value: '+1.2k',
          valueColor: const Color(0xFF2FA84F),
        ),
        _buildGrowthCard(
          title: 'ENGAGEMENT RATE',
          value: '8.2%',
          valueColor: const Color(0xFF3F8CFF),
        ),
        _buildGrowthCard(
          title: 'TOTAL LIKES',
          value: '45k',
          valueColor: const Color(0xFF3F8CFF),
        ),
        _buildGrowthCard(
          title: 'TOTAL COMMENTS',
          value: '-1.2k',
          valueColor: const Color(0xFFDC2626),
        ),
      ],
    );
  }

  Widget _buildGrowthCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
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
              color: Color(0xFF6B7280),
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

  Widget _buildEarningsTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE5EAF2),
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
                      style: TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('DATE',
                      style: TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3)),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('AMOUNT',
                        style: TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3)),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          _buildEarningsRow(amount: '+Rp125.000'),
          _buildEarningsRow(amount: '+Rp123.000'),
          _buildEarningsRow(amount: '+Rp99.000'),

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
                  color: Color(0xFF3F8CFF),
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

  Widget _buildEarningsRow({required String amount}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Description (Flex 3)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Campaign Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9E7FF),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.campaign, color: Color(0xFF3F8CFF), size: 20),
                ),
                const SizedBox(width: 12),
                // Text Col
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summer\nTech Series',
                        style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ref: #TXN-90281',
                        style: TextStyle(
                            color: Color(0xFF6B7280), fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Date (Flex 2)
          const Expanded(
            flex: 2,
            child: Text(
              'Oct\n24, 2023',
              style: TextStyle(
                  color: Color(0xFF6B7280), fontSize: 12, height: 1.2),
            ),
          ),
          // Amount (Flex 2)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                amount,
                style: const TextStyle(
                  color: Color(0xFF2FA84F),
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
