import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';
import '../core/format.dart';
import '../chat/chat_room_screen.dart';
import 'campaign_performance_screen.dart';

class CampaignRoomScreen extends StatelessWidget {
  const CampaignRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KonektaColors.bg,
      appBar: AppBar(
        backgroundColor: KonektaColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: KonektaColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Campaign Room', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: KonektaColors.textDark)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert_rounded, color: KonektaColors.textSecondary), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Campaign header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF8B5E3C), borderRadius: BorderRadius.circular(12))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Kopi Susu Campaign', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: KonektaColors.textDark)),
                              SizedBox(height: 2),
                              Text('Coffee Menu Collection', style: TextStyle(fontSize: 12, color: KonektaColors.textMuted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(20)),
                          child: const Text('IN PROGRESS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF246FE0), letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _ProgressRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Campaign Period',
                      value: 'Jun 15 - Jul 15, 2025',
                    ),
                    const SizedBox(height: 8),
                    const _ProgressRow(
                      icon: Icons.attach_money_rounded,
                      label: 'Budget',
                      value: 'Rp 2,400,000',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Charts
              const Text('Performance Analytics', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: KonektaColors.textDark)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Views & Engagement (7 Days)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: KonektaColors.textDark)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1000, getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF0F0F0), strokeWidth: 1)),
                          titlesData: FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 800), FlSpot(1, 1200), FlSpot(2, 1800), FlSpot(3, 1400), FlSpot(4, 2200), FlSpot(5, 2800), FlSpot(6, 2400),
                              ],
                              isCurved: true,
                              color: KonektaColors.primary,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(show: true, color: KonektaColors.primary.withValues(alpha: 0.08)),
                            ),
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 300), FlSpot(1, 500), FlSpot(2, 400), FlSpot(3, 700), FlSpot(4, 600), FlSpot(5, 900), FlSpot(6, 850),
                              ],
                              isCurved: true,
                              color: const Color(0xFF22C55E),
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Legend(color: KonektaColors.primary, label: 'Views'),
                        const SizedBox(width: 20),
                        _Legend(color: const Color(0xFF22C55E), label: 'Engagements'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // KPI cards
              const Text('KPI Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: KonektaColors.textDark)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                child: _KPICard(label: 'TOTAL VIEWS', value: '12,847', change: '+12%', icon: Icons.visibility_rounded, color: KonektaColors.primary)),
                  const SizedBox(width: 10),
                  Expanded(
                child: _KPICard(label: 'ENGAGEMENT', value: '1,234', change: '+8%', icon: Icons.favorite_rounded, color: const Color(0xFFE11D74))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                child: _KPICard(label: 'CONVERSION', value: '5.6%', change: '+2%', icon: Icons.show_chart_rounded, color: const Color(0xFFF59E0B))),
                  const SizedBox(width: 10),
                  Expanded(
                child: _KPICard(label: 'REVENUE', value: 'Rp 2.4M', change: 'On Track', icon: Icons.account_balance_wallet_rounded, color: const Color(0xFF22C55E))),
                ],
              ),
              const SizedBox(height: 24),
              // View Performance card
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CampaignPerformanceScreen())),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: KonektaGradients.pillBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('View Performance', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Chat button
              GradientMiniButtonWidget(
                label: 'Open Chat',
                icon: Icons.chat_bubble_rounded,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatRoomScreen())),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// -- Mini gradient button --
class GradientMiniButtonWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const GradientMiniButtonWidget({super.key, required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [KonektaColors.primary, Color(0xFF818CF8)]),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ProgressRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: KonektaColors.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: KonektaColors.textMuted)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: KonektaColors.textDark))),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: KonektaColors.textSecondary)),
      ],
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label, value, change;
  final IconData icon;
  final Color color;
  const _KPICard({required this.label, required this.value, required this.change, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(7)), child: Icon(icon, color: color, size: 13)),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: KonektaColors.textMuted))),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: KonektaColors.textDark)),
          const SizedBox(height: 2),
          Text(change, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
