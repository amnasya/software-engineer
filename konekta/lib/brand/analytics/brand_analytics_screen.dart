import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../notification/notifications_screen.dart';

const Color _kBlue = Color(0xFF1E70E7);
const Color _kTextDark = Color(0xFF2C254A);
const Color _kTextSubtle = Color(0xFF757D95);
const Color _kGreen = Color(0xFF2FA85C);
const Color _kBg = Color(0xFFEDF4FF);
const Color _kViewsBar = Color(0xFFD3DCFA);
const Color _kEngageBar = Color(0xFFE8BEE3);

class BrandAnalyticsScreen extends StatefulWidget {
  const BrandAnalyticsScreen({super.key});

  @override
  State<BrandAnalyticsScreen> createState() => _BrandAnalyticsScreenState();
}

class _BrandAnalyticsScreenState extends State<BrandAnalyticsScreen> {
  int _selectedTab = 0;
  static const _tabs = ['Weekly', 'Monthly', 'Annually'];

  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  AppScope? _scope;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = AppScope.of(context);
    if (!_initialized) {
      _initialized = true;
      _load();
    }
  }

  Future<void> _load() async {
    final scope = _scope;
    if (scope == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await scope.run(() async {
        final summary = await scope.api.get('/dashboard/brand');
        final offers = await scope.api.get('/offers', query: {
          'role': 'brand',
          'status': 'in_progress',
        });
        return {'summary': summary, 'offers': offers};
      });
      if (!mounted) return;
      setState(() {
        _data = (results['summary'] is Map)
            ? Map<String, dynamic>.from(results['summary'] as Map)
            : <String, dynamic>{};
        _data!['offers'] = results['offers'] is List ? results['offers'] : [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  List<double> _viewsSeries() {
    final series = (_data?['series'] as List?) ?? const [];
    if (series.isEmpty) return const [110, 80, 130, 90, 150, 120, 135];
    return series
        .map<double>((e) => (e is Map ? (e['views'] ?? 0) : 0).toDouble())
        .toList();
  }

  List<double> _engagementSeries() {
    final series = (_data?['series'] as List?) ?? const [];
    if (series.isEmpty) return const [60, 40, 70, 30, 100, 85, 75];
    return series
        .map<double>((e) => (e is Map ? (e['engagement'] ?? 0) : 0).toDouble())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Performance',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _kTextDark),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Daily metrics and growth analysis for your all Campaigns',
                        style: TextStyle(fontSize: 14, color: _kTextSubtle, height: 1.3),
                      ),
                      const SizedBox(height: 20),
                      _buildTabFilter(),
                      const SizedBox(height: 20),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_error != null)
                        _ErrorState(message: _error!, onRetry: _load)
                      else ...[
                        _buildDailyPerformanceCard(),
                        const SizedBox(height: 24),
                        _buildGrowthSection(),
                        const SizedBox(height: 24),
                        _buildRecentSpendingSection(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(gradient: KonektaGradients.primary),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Konekta',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildTabFilter() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE2ECFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected
                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      color: selected ? _kBlue : _kTextSubtle,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildDailyPerformanceCard() {
    final views = _viewsSeries();
    final engagement = _engagementSeries();
    final maxVal = [...views, ...engagement].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ACTIVITY LOG',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _kBlue, letterSpacing: 0.5)),
              Row(
                children: [
                  _buildLegendDot(_kViewsBar, 'Views'),
                  const SizedBox(width: 12),
                  _buildLegendDot(_kEngageBar, 'Engagement'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Daily\nPerformance',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kTextDark, height: 1.1)),
          const SizedBox(height: 30),
          SizedBox(
            height: 170,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.15,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) {
                        const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
                        if (v.toInt() < days.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(days[v.toInt()],
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _kTextSubtle)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(views.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                          toY: views[i],
                          color: _kViewsBar,
                          width: 14,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                      BarChartRodData(
                          toY: engagement[i],
                          color: _kEngageBar,
                          width: 14,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: _kTextSubtle)),
      ],
    );
  }

  Widget _buildGrowthSection() {
    final stats = (_data?['stats'] as Map?)?.cast<String, dynamic>() ?? const {};
    final metrics = [
      ('NEW FOLLOWERS', '+${stats['new_followers'] ?? '1.2k'}'),
      ('ENGAGEMENT RATE', '${stats['engagement_rate'] ?? '8.2'}%'),
      ('TOTAL LIKES', '${stats['total_likes'] ?? '45k'}'),
      ('TOTAL COMMENTS', '${stats['total_comments'] ?? '1.2k'}'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Growth (7D)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kTextDark)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: metrics
              .map((m) => _MetricCard(title: m.$1, value: m.$2))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRecentSpendingSection() {
    final campaigns = (_data?['recent_campaigns'] as List?) ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Spending',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kTextDark)),
        const SizedBox(height: 16),
        Container(
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
                  color: Color(0xFFEBE6E6),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6E6E6E)))),
                    Expanded(flex: 2, child: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6E6E6E)))),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text('AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6E6E6E))),
                      ),
                    ),
                  ],
                ),
              ),
              if (campaigns.isEmpty) ...[
                _TransactionRow(title: 'Summer Tech Series', ref: '#TXN-90281', date: 'Oct\n24, 2023', amount: '+Rp125.000', isLast: false),
                _TransactionRow(title: 'Summer Tech Series', ref: '#TXN-90282', date: 'Oct\n24, 2023', amount: '+Rp123.000', isLast: false),
                _TransactionRow(title: 'Summer Tech Series', ref: '#TXN-90283', date: 'Oct\n24, 2023', amount: '+Rp99.000', isLast: true),
              ] else
                ...List.generate(campaigns.length, (i) {
                  final c = (campaigns[i] as Map).cast<String, dynamic>();
                  return _TransactionRow(
                    title: (c['title'] ?? 'Untitled').toString(),
                    ref: '#TXN-${c['id'] ?? i}',
                    date: (c['created_at'] ?? '-').toString(),
                    amount: '+Rp${c['amount'] ?? '0'}',
                    isLast: i == campaigns.length - 1,
                  );
                }),
              // Show All button
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFECEFFB),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                ),
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text(
                    'SHOW ALL TRANSACTIONS',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A5385),
                        letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _kTextSubtle, letterSpacing: 0.3)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _kBlue)),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String title;
  final String ref;
  final String date;
  final String amount;
  final bool isLast;

  const _TransactionRow({
    required this.title,
    required this.ref,
    required this.date,
    required this.amount,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFD9E7FF), borderRadius: BorderRadius.circular(50)),
                  child: const Icon(Icons.campaign, color: Color(0xFF4285F4), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _kTextDark),
                          overflow: TextOverflow.ellipsis),
                      Text('Ref: $ref', style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(date, style: const TextStyle(fontSize: 12, color: _kTextSubtle, height: 1.2)),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(amount,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _kGreen)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: _kBlue, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _kTextSubtle)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
