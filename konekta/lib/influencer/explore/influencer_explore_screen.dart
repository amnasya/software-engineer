import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_scope.dart';
import '../../core/theme.dart';
import '../../core/format.dart';
import '../../core/navigation.dart';
import '../../data/models/campaign.dart';
import '../../data/repositories/campaign_repository.dart';
import '../../campaign/campaign_detail_screen.dart';
import '../../notification/notifications_screen.dart';

class InfluencerExploreScreen extends StatefulWidget {
  const InfluencerExploreScreen({super.key});

  @override
  State<InfluencerExploreScreen> createState() => _InfluencerExploreScreenState();
}

class _InfluencerExploreScreenState extends State<InfluencerExploreScreen> {
  bool _loading = true;
  String? _error;
  List<Campaign> _campaigns = const [];
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final scope = _scope;
    if (scope == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await scope.run<List<Campaign>>(
        () => CampaignRepository(scope.api).listOffers(role: 'influencer', status: 'open'),
      );
      if (!mounted) return;
      setState(() {
        _campaigns = list;
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

  List<Campaign> get _filtered {
    if (_search.isEmpty) return _campaigns;
    final q = _search.toLowerCase();
    return _campaigns.where((c) {
      final title = c.title.toLowerCase();
      final brand = (c.brandName ?? '').toLowerCase();
      return title.contains(q) || brand.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFEDF4FC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16, topPad + 16, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2FA2EE), Color(0xFF3B7CE5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.hub_outlined, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Konekta',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
          // ── Scrollable body ──────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pro banner
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: _ProBannerCard(),
                  ),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    onChanged: (v) => setState(() => _search = v.trim()),
                                    decoration: InputDecoration(
                                      hintText: 'Search campaigns or brands',
                                      hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (_search.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchCtrl.clear();
                                      setState(() => _search = '');
                                    },
                                    child: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 18),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 50,
                          width: 76,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A9FFF), Color(0xFF3581E1)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextButton(
                            onPressed: () => setState(() {}),
                            child: const Text(
                              'Search',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Section label
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'FEATURED PUBLIC CAMPAIGNS',
                          style: TextStyle(
                            color: KonektaColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${_filtered.length} OPEN',
                          style: const TextStyle(
                            color: KonektaColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Content
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF2FA2EE))),
                    )
                  else if (_error != null)
                    _ErrorBlock(message: _error!, onRetry: _load)
                  else if (_filtered.isEmpty)
                    _EmptyBlock(query: _search)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: _filtered.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildPublicCampaignCard(context, c),
                        )).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicCampaignCard(BuildContext context, Campaign c) {
    final rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final budget = c.budget != null ? rupiah.format(c.budget) : '—';
    final daysLeft = c.daysLeft;
    final daysText = daysLeft == null
        ? '— Days Left'
        : daysLeft > 0
            ? '$daysLeft Days Left'
            : daysLeft == 0
                ? 'Due today'
                : 'Closed';
    final brand = c.brandName ?? 'Brand';
    final subtitle = c.description ?? 'Open campaign';
    final applicants = c.applicantsCount ?? 0;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CampaignDetailScreen(campaign: c)),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A534E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    brand.isEmpty ? 'B' : brand[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        c.title,
                        style: const TextStyle(
                          color: KonektaColors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        brand,
                        style: const TextStyle(
                          color: KonektaColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            daysText,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.people_outline_rounded, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            '$applicants applicants',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: c.isOpen ? const Color(0xFFD6F8E8) : const Color(0xFFC8CED4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    c.isOpen ? 'OPEN' : c.status.toUpperCase(),
                    style: TextStyle(
                      color: c.isOpen ? const Color(0xFF00C853) : const Color(0xFF6B7280),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.3),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUDGET',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      budget,
                      style: const TextStyle(
                        color: Color(0xFF3AA1FF),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Format.compact(c.budget ?? 0),
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProBannerCard extends StatelessWidget {
  const _ProBannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2FA2EE), Color(0xFF408CFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PREMIUM TIER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Konekta Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stand out to brands & unlock\nunlimited campaigns.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF408CFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
            ),
            child: const Text(
              'Upgrade',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String query;
  const _EmptyBlock({required this.query});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, color: Colors.grey.shade400, size: 40),
            const SizedBox(height: 12),
            Text(
              query.isEmpty ? 'No open campaigns right now' : 'No campaigns match "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF26264A)),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later or broaden your search.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40, color: Color(0xFFB0B8C4)),
            const SizedBox(height: 10),
            const Text('Could not load campaigns',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF26264A))),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF7E8CA0))),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2FA2EE),
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

class HeaderCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);
    var controlPoint = Offset(size.width / 2, size.height + 10);
    var endPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
