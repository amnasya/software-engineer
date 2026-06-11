import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../core/format.dart';
import '../chat/chat_room_screen.dart';
import '../data/models/campaign.dart';

class CampaignDetailScreen extends StatelessWidget {
  final Campaign? campaign;
  const CampaignDetailScreen({super.key, this.campaign});

  @override
  Widget build(BuildContext context) {
    final rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Scaffold(
      backgroundColor: KonektaColors.bg,
      appBar: AppBar(
        backgroundColor: KonektaColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: KonektaColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Campaign Detail', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: KonektaColors.textDark)),
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
                child: Row(
                  children: [
                    Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF8B5E3C), borderRadius: BorderRadius.circular(14))),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Kopi Susu Official', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: KonektaColors.textDark)),
                          SizedBox(height: 2),
                          Text('Food & Beverage', style: TextStyle(fontSize: 12, color: KonektaColors.textMuted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(20)),
                      child: const Text('IN PROGRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF246FE0), letterSpacing: 0.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Campaign brief
              const Text('Campaign Brief', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: KonektaColors.textDark)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE3E9F2))),
                child: const Text(
                  'Create 3 Instagram Feed posts and 2 Reels showcasing our new coffee menu collection. Content should highlight the premium quality and cozy atmosphere of Kopi Susu.',
                  style: TextStyle(fontSize: 13, color: KonektaColors.textSecondary, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              // Campaign details
              const Text('Campaign Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: KonektaColors.textDark)),
              const SizedBox(height: 8),
              _DetailRow(label: 'Budget', value: rupiah.format(2400000)),
              _DetailRow(label: 'Start Date', value: 'Jun 15, 2025'),
              _DetailRow(label: 'End Date', value: 'Jul 15, 2025'),
              _DetailRow(label: 'Platform', value: 'Instagram'),
              _DetailRow(label: 'Deadline', value: 'Jul 10, 2025'),
              const SizedBox(height: 20),
              // Progress
              const Text('Progress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: KonektaColors.textDark)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                child: Column(
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('67% Complete', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: KonektaColors.textDark)),
                        Text('3/5 posts', style: TextStyle(fontSize: 12, color: KonektaColors.textMuted)),
                      ],
                    ),
                    SizedBox(height: 10),
                    _ProgressTrack(percent: 0.67, color: const Color(0xFF246FE0)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _GradientMiniButton(
                      label: 'View Progress',
                      icon: Icons.trending_up_rounded,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GradientMiniButton(
                      label: 'Contact Brand',
                      icon: Icons.chat_bubble_rounded,
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatRoomScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: KonektaColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: KonektaColors.textDark)),
        ],
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  final double percent;
  final Color color;
  const _ProgressTrack({required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: percent,
        minHeight: 10,
        backgroundColor: const Color(0xFFE5E7EB),
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

class _GradientMiniButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _GradientMiniButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [KonektaColors.primaryGradientStart, KonektaColors.primaryGradientEnd]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
