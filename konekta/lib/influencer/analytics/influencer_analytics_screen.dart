import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import '../../core/format.dart';
import '../../data/models/campaign.dart';
import '../../data/models/influencer_summary.dart';
import '../../data/repositories/campaign_repository.dart';
import '../../data/repositories/dashboard_repository.dart';

class InfluencerAnalyticsScreen extends StatefulWidget {
  const InfluencerAnalyticsScreen({super.key});

  static const _bg = Color(0xFFEFF5FA);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textMuted = Color(0xFF7A8B9E);
  static const _cardBg = Colors.white;
  static const _iconBlue = Color(0xFF1E75FF);
  static const _iconBlueSoft = Color(0xFFE8F1FF);
  static const _accentPurple = Color(0xFF7A5BFF);
  static const _accentOrange = Color(0xFFFF7A45);
  static const _accentGreen = Color(0xFF1FB76A);
  static const _accentPink = Color(0xFFFF4F8B);

  @override
  State<InfluencerAnalyticsScreen> createState() => _InfluencerAnalyticsScreenState();
}

class _InfluencerAnalyticsScreenState extends State<InfluencerAnalyticsScreen> {
  bool _loading = true;
  String? _error;
  InfluencerSummary? _summary;
  List<Campaign> _activeCampaigns = [];
  List<Campaign> _completedCampaigns = [];
  int _rangeDays = 30;
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
    if (_scope == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dashRepo = DashboardRepository(_scope!.api);
      final campRepo = CampaignRepository(_scope!.api);
      final results = await Future.wait([
        _scope!.run<InfluencerSummary>(() => dashRepo.influencerSummary()),
        _scope!.run<List<Campaign>>(() => campRepo.listOffers(role: 'influencer', status: 'in_progress')),
        _scope!.run<List<Campaign>>(() => campRepo.listOffers(role: 'influencer', status: 'completed')),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = results[0] as InfluencerSummary;
        _activeCampaigns = results[1] as List<Campaign>;
        _completedCampaigns = results[2] as List<Campaign>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: InfluencerAnalyticsScreen._bg,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator(color: InfluencerAnalyticsScreen._iconBlue)),
      );
    }
    if (_error != null || _summary == null) {
      return Scaffold(
        backgroundColor: InfluencerAnalyticsScreen._bg,
        appBar: _buildAppBar(),
        body: _ErrorState(message: _error ?? 'Unknown error', onRetry: _load),
      );
    }
    final summary = _summary!;
    return Scaffold(
      backgroundColor: InfluencerAnalyticsScreen._bg,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RangeSelector(
                selected: _rangeDays,
                onSelected: (d) => setState(() => _rangeDays = d),
              ),
              const SizedBox(height: 16),
              _HeadlineStatsRow(summary: summary),
              const SizedBox(height: 16),
              _EngagementCard(summary: summary),
              const SizedBox(height: 16),
              _AudienceReachCard(summary: summary),
              const SizedBox(height: 16),
              _CampaignPerformanceSection(
                active: _activeCampaigns,
                completed: _completedCampaigns,
                summary: summary,
              ),
              const SizedBox(height: 16),
              _TopPerformingCampaignsCard(campaigns: _completedCampaigns.isNotEmpty ? _completedCampaigns : _activeCampaigns),
              const SizedBox(height: 16),
              _InsightsSection(summary: summary, active: _activeCampaigns, completed: _completedCampaigns),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: InfluencerAnalyticsScreen._bg,
      elevation: 0,
      title: const Text('Analytics',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: InfluencerAnalyticsScreen._textPrimary)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: InfluencerAnalyticsScreen._textPrimary, size: 20),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

// ---- RANGE SELECTOR ----

class _RangeSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;
  const _RangeSelector({required this.selected, required this.onSelected});
  @override
  Widget build(BuildContext context) {
    final ranges = const [7, 30, 90];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: ranges.map((d) {
          final isSel = selected == d;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSel
                      ? const LinearGradient(colors: [Color(0xFF4FB6FF), Color(0xFF1E75FF)])
                      : null,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${d}d',
                  style: TextStyle(
                    color: isSel ? Colors.white : InfluencerAnalyticsScreen._textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---- HEADLINE STATS ----

class _HeadlineStatsRow extends StatelessWidget {
  final InfluencerSummary summary;
  const _HeadlineStatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Reach',
            value: Format.compact(summary.audienceReached),
            icon: Icons.visibility_outlined,
            color: InfluencerAnalyticsScreen._iconBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            label: 'Engagement',
            value: '${summary.engagementRate.toStringAsFixed(1)}%',
            icon: Icons.favorite_rounded,
            color: InfluencerAnalyticsScreen._accentPink,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: InfluencerAnalyticsScreen._textPrimary)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: InfluencerAnalyticsScreen._textMuted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ---- ENGAGEMENT CARD ----

class _EngagementCard extends StatelessWidget {
  final InfluencerSummary summary;
  const _EngagementCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final rate = summary.engagementRate;
    final pct = (rate / 20).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4FB6FF), Color(0xFF1E75FF)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Engagement Rate',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Text('${rate.toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('${rate.toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Across all active platforms',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct.toDouble(),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- AUDIENCE REACH CARD ----

class _AudienceReachCard extends StatelessWidget {
  final InfluencerSummary summary;
  const _AudienceReachCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Audience Reach',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: InfluencerAnalyticsScreen._textPrimary)),
          const SizedBox(height: 4),
          Text('${Format.compact(summary.audienceReached)} people reached',
              style: const TextStyle(color: InfluencerAnalyticsScreen._textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          _ReachRow(label: 'Total interactions', value: Format.compact(summary.totalInteractions), color: InfluencerAnalyticsScreen._accentPurple),
          const SizedBox(height: 10),
          _ReachRow(label: 'Active campaigns', value: '${summary.activeCampaigns}', color: InfluencerAnalyticsScreen._accentOrange),
          const SizedBox(height: 10),
          _ReachRow(label: 'Pending proposals', value: '${summary.pendingProposals}', color: InfluencerAnalyticsScreen._accentGreen),
        ],
      ),
    );
  }
}

class _ReachRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ReachRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: InfluencerAnalyticsScreen._textMuted, fontWeight: FontWeight.w600)),
        ),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: InfluencerAnalyticsScreen._textPrimary)),
      ],
    );
  }
}

// ---- CAMPAIGN PERFORMANCE SECTION ----

class _CampaignPerformanceSection extends StatelessWidget {
  final List<Campaign> active;
  final List<Campaign> completed;
  final InfluencerSummary summary;
  const _CampaignPerformanceSection({
    required this.active,
    required this.completed,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Campaign Performance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: InfluencerAnalyticsScreen._textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PerformanceStat(
                  label: 'Active',
                  value: '${active.length}',
                  color: InfluencerAnalyticsScreen._accentOrange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PerformanceStat(
                  label: 'Completed',
                  value: '${completed.length}',
                  color: InfluencerAnalyticsScreen._accentGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PerformanceStat(
                  label: 'Total',
                  value: '${summary.completedCampaigns}',
                  color: InfluencerAnalyticsScreen._accentPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Earnings overview',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: InfluencerAnalyticsScreen._textPrimary)),
          const SizedBox(height: 8),
          if (completed.isEmpty)
            const Text('No completed campaigns yet — your first paid campaign will appear here.',
                style: TextStyle(fontSize: 12, color: InfluencerAnalyticsScreen._textMuted))
          else
            ...completed.take(3).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CompletedCampaignRow(campaign: c),
                )),
        ],
      ),
    );
  }
}

class _PerformanceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _PerformanceStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: InfluencerAnalyticsScreen._textMuted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CompletedCampaignRow extends StatelessWidget {
  final Campaign campaign;
  const _CompletedCampaignRow({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: InfluencerAnalyticsScreen._accentGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.campaign_rounded, color: InfluencerAnalyticsScreen._accentGreen, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(campaign.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: InfluencerAnalyticsScreen._textPrimary)),
              Text(campaign.brandName ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: InfluencerAnalyticsScreen._textMuted)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(Format.currency(campaign.budget ?? 0),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: InfluencerAnalyticsScreen._textPrimary)),
      ],
    );
  }
}

// ---- TOP PERFORMING ----

class _TopPerformingCampaignsCard extends StatelessWidget {
  final List<Campaign> campaigns;
  const _TopPerformingCampaignsCard({required this.campaigns});

  @override
  Widget build(BuildContext context) {
    if (campaigns.isEmpty) {
      return _EmptyStateCard(
        title: 'No campaigns yet',
        subtitle: 'Top performing campaigns will appear here once you complete one.',
      );
    }
    final sorted = [...campaigns]..sort((a, b) => (b.budget ?? 0).compareTo(a.budget ?? 0));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Performing Campaigns',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: InfluencerAnalyticsScreen._textPrimary)),
          const SizedBox(height: 16),
          ...sorted.take(3).map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TopRow(
                  campaign: c,
                  rank: sorted.indexOf(c) + 1,
                ),
              )),
        ],
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  final Campaign campaign;
  final int rank;
  const _TopRow({required this.campaign, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: rank == 1
                ? const Color(0xFFFFC371)
                : InfluencerAnalyticsScreen._iconBlueSoft,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text('$rank',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: rank == 1 ? Colors.white : InfluencerAnalyticsScreen._iconBlue,
              )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(campaign.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: InfluencerAnalyticsScreen._textPrimary)),
              Text(campaign.brandName ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: InfluencerAnalyticsScreen._textMuted)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(Format.currency(campaign.budget ?? 0),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: InfluencerAnalyticsScreen._textPrimary)),
            Text('${campaign.daysLeft}d left',
                style: const TextStyle(fontSize: 10, color: InfluencerAnalyticsScreen._textMuted)),
          ],
        ),
      ],
    );
  }
}

// ---- INSIGHTS ----

class _InsightsSection extends StatelessWidget {
  final InfluencerSummary summary;
  final List<Campaign> active;
  final List<Campaign> completed;
  const _InsightsSection({required this.summary, required this.active, required this.completed});

  @override
  Widget build(BuildContext context) {
    final insights = _computeInsights();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Smart Insights',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: InfluencerAnalyticsScreen._textPrimary)),
          const SizedBox(height: 14),
          ...insights.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _InsightRow(text: s),
              )),
        ],
      ),
    );
  }

  List<String> _computeInsights() {
    final out = <String>[];
    final rate = summary.engagementRate;
    if (rate >= 5) {
      out.add('Your engagement rate (${rate.toStringAsFixed(1)}%) is above the industry average — keep it up.');
    } else if (rate > 0) {
      out.add('Engagement rate is ${rate.toStringAsFixed(1)}%. Aim for 5%+ to stand out to brands.');
    } else {
      out.add('No engagement data yet. Apply to a campaign to start building your record.');
    }
    if (summary.activeCampaigns > 0) {
      out.add('You have ${summary.activeCampaigns} active campaign${summary.activeCampaigns == 1 ? '' : 's'} running.');
    } else {
      out.add('No active campaigns. Browse the explore tab to find new opportunities.');
    }
    if (summary.pendingProposals > 0) {
      out.add('${summary.pendingProposals} proposal${summary.pendingProposals == 1 ? '' : 's'} awaiting brand response.');
    }
    if (summary.completedCampaigns >= 3) {
      out.add('Strong track record: ${summary.completedCampaigns} campaigns completed.');
    }
    if (out.isEmpty) {
      out.add('Stay active to unlock more personalised insights.');
    }
    return out;
  }
}

class _InsightRow extends StatelessWidget {
  final String text;
  const _InsightRow({required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lightbulb_outline_rounded, color: InfluencerAnalyticsScreen._iconBlue, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 13, color: InfluencerAnalyticsScreen._textPrimary, height: 1.4)),
        ),
      ],
    );
  }
}

// ---- ERROR / EMPTY ----

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: Color(0xFFB0B8C4)),
            const SizedBox(height: 12),
            const Text('Could not load analytics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: InfluencerAnalyticsScreen._textPrimary)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: InfluencerAnalyticsScreen._textMuted)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: InfluencerAnalyticsScreen._iconBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyStateCard({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Icon(Icons.insights_rounded, size: 40, color: InfluencerAnalyticsScreen._textMuted),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: InfluencerAnalyticsScreen._textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: InfluencerAnalyticsScreen._textMuted)),
        ],
      ),
    );
  }
}
