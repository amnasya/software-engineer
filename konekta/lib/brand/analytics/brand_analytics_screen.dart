import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../notification/notifications_screen.dart';

const Color kKonektaBlue = Color(0xFF4A90E2);
const Color kKonektaPurple = Color(0xFF9B51E0);
const Color kTextDark = Color(0xFF333333);
const Color kTextSubtle = Colors.black;
const Color kPositiveGreen = Color(0xFF27AE60);
const Color kNegativeRed = Color(0xFFEB5757);

class BrandAnalyticsScreen extends StatefulWidget {
  const BrandAnalyticsScreen({super.key});

  @override
  State<BrandAnalyticsScreen> createState() => _BrandAnalyticsScreenState();
}

class _BrandAnalyticsScreenState extends State<BrandAnalyticsScreen> {
  int _selectedTab = 0;
  static const _tabs = ['Daily', 'Weekly', 'Monthly', 'Annually'];

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
        return {
          'summary': summary,
          'offers': offers,
        };
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
    if (series.isEmpty) {
      return const [60, 45, 80, 55, 95, 70, 85];
    }
    return series
        .map<double>((e) => (e is Map ? (e['views'] ?? 0) : 0).toDouble())
        .toList();
  }

  List<double> _engagementSeries() {
    final series = (_data?['series'] as List?) ?? const [];
    if (series.isEmpty) {
      return const [35, 25, 50, 20, 58, 40, 48];
    }
    return series
        .map<double>((e) => (e is Map ? (e['engagement'] ?? 0) : 0).toDouble())
        .toList();
  }

  BarChartData _buildBarChartData() {
    final views = _viewsSeries();
    final engagement = _engagementSeries();
    final n = views.length;
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 100,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
              if (value >= 0 && value < days.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 10,
                  child: Text(days[value.toInt()], style: const TextStyle(color: kTextSubtle, fontSize: 10)),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(n, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: views[i], color: kKonektaBlue, width: 8, borderRadius: BorderRadius.circular(4)),
            BarChartRodData(toY: engagement[i], color: kKonektaPurple, width: 8, borderRadius: BorderRadius.circular(4)),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const SizedBox(height: 20),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  _ErrorState(message: _error!, onRetry: _load)
                else ...[
                  _buildTabs(),
                  const SizedBox(height: 20),
                  _buildDailyPerformanceCard(),
                  const SizedBox(height: 20),
                  _buildGrowthSection(),
                  const SizedBox(height: 20),
                  _buildRecentEarningsSection(),
                ],
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
          const Text(
            'Konekta',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: const Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none, color: Colors.white, size: 26),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance', style: TextStyle(color: kTextDark, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text('Daily metrics and growth analysis for your campaigns', style: TextStyle(color: kTextSubtle, fontSize: 14)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final selected = _selectedTab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? kKonektaBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _tabs[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected ? Colors.white : kTextSubtle,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPerformanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily\nPerformance', style: TextStyle(color: kTextDark, fontSize: 22, fontWeight: FontWeight.bold, height: 1.1)),
                  Row(
                    children: [
                      _buildLegendItem('Views', kKonektaBlue),
                      const SizedBox(width: 15),
                      _buildLegendItem('Engagement', kKonektaPurple),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(height: 200, child: BarChart(_buildBarChartData())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: kTextSubtle, fontSize: 12)),
      ],
    );
  }

  Widget _buildGrowthSection() {
    final stats = (_data?['stats'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GROWTH (7D)', style: TextStyle(color: kTextSubtle, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 15),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildGrowthStatCard('NEW FOLLOWERS', '+${stats['new_followers'] ?? 0}', kKonektaBlue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildGrowthStatCard('ENGAGEMENT RATE', '${stats['engagement_rate'] ?? 0}%', kKonektaBlue)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildGrowthStatCard('TOTAL LIKES', '${stats['total_likes'] ?? 0}', kKonektaBlue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildGrowthStatCard('TOTAL COMMENTS', '${stats['total_comments'] ?? 0}', kKonektaBlue)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthStatCard(String title, String value, Color valueColor) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: kTextSubtle, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEarningsSection() {
    final campaigns = (_data?['recent_campaigns'] as List?) ?? const [];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RECENT CAMPAIGNS', style: TextStyle(color: kTextSubtle, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, spreadRadius: 1)],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 3, child: Text('DESCRIPTION', style: TextStyle(color: kTextSubtle, fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('DATE', textAlign: TextAlign.center, style: TextStyle(color: kTextSubtle, fontSize: 11, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('STATUS', textAlign: TextAlign.right, style: TextStyle(color: kTextSubtle, fontSize: 11, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                if (campaigns.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('No campaigns yet', style: TextStyle(color: kTextSubtle, fontSize: 12)),
                  )
                else
                  ...List.generate(campaigns.length, (i) {
                    final c = (campaigns[i] as Map).cast<String, dynamic>();
                    final title = (c['title'] ?? 'Untitled').toString();
                    final ref = c['id']?.toString() ?? '-';
                    final date = (c['created_at'] ?? '').toString();
                    final status = (c['status'] ?? 'pending').toString();
                    final hasBorder = i < campaigns.length - 1;
                    final color = _statusColor(status);
                    return _buildCampaignRow(title, ref, date, status.toUpperCase(), hasBorder, color);
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'active':
      case 'in_progress':
        return kKonektaBlue;
      case 'completed':
      case 'complete':
        return kPositiveGreen;
      default:
        return kNegativeRed;
    }
  }

  Widget _buildCampaignRow(String title, String ref, String date, String status, bool hasBorder, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        border: hasBorder ? const Border(bottom: BorderSide(color: Color(0xFFEEEEEE))) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(Icons.campaign_outlined, color: kKonektaBlue, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: kTextDark, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      Text('Ref: $ref', style: const TextStyle(color: kTextSubtle, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(date, textAlign: TextAlign.center, style: const TextStyle(color: kTextSubtle, fontSize: 11)),
          ),
          Expanded(
            flex: 2,
            child: Text(status, textAlign: TextAlign.right, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
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
          const Icon(Icons.cloud_off, color: kKonektaBlue, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: kTextSubtle)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
