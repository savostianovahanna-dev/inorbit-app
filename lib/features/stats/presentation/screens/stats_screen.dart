import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// ─── Local palette for activity grid ─────────────────────────────────────────

const _kEmpty = Color(0xFFEBEBED); // fill_I83KA5
const _kLight = Color(0xFFC7D2E0); // fill_XPWGW8
const _kMed = Color(0xFF7E9ABB); // fill_63KIB1
const _kDark = Color(0xFF334155); // fill_ZKJNRD
const _kGreen = Color(0xFF22C55E); // healthy
const _kRed = Color(0xFFEF4444); // overdue

// ─── Activity grid data (14 cols × 7 rows). 0=empty,1=light,2=med,3=dark ─────

const _kGrid = [
  // ← Nov ────────────── Dec ─────────────── Jan ─────────────── Feb →
  [0, 0, 0, 3, 0, 0, 0], // col 0
  [0, 0, 2, 0, 0, 0, 0], // col 1
  [0, 0, 0, 0, 0, 1, 0], // col 2
  [0, 2, 0, 0, 0, 0, 0], // col 3
  [0, 0, 0, 0, 3, 0, 0], // col 4
  [0, 0, 0, 0, 0, 0, 2], // col 5
  [0, 0, 1, 0, 0, 0, 0], // col 6
  [0, 0, 0, 1, 0, 0, 0], // col 7
  [0, 1, 0, 0, 0, 0, 2], // col 8
  [3, 0, 0, 0, 0, 0, 0], // col 9
  [0, 0, 3, 0, 0, 2, 0], // col 10
  [0, 2, 0, 3, 0, 0, 0], // col 11
  [0, 0, 1, 0, 2, 0, 0], // col 12
  [2, 0, 0, 0, 0, 0, 3], // col 13
];

const _kMonths = [
  (label: 'Nov', col: 0),
  (label: 'Dec', col: 4),
  (label: 'Jan', col: 7),
  (label: 'Feb', col: 11),
];

// ─── Orbit-health people data ─────────────────────────────────────────────────

const _kPeople = [
  (name: 'Anna K.', days: 47, initial: 'A', hue1: 0xFF334155, hue2: 0xFF222222),
  (name: 'Maria L.', days: 3, initial: 'M', hue1: 0xFF7E9ABB, hue2: 0xFF334155),
  (name: 'Sophie R.', days: 12, initial: 'S', hue1: 0xFF96A8C2, hue2: 0xFF4A6080),
  (name: 'Lena W.', days: 5, initial: 'L', hue1: 0xFF4A6080, hue2: 0xFF222222),
];

// ─── Root content widget ──────────────────────────────────────────────────────

/// Shown when the Stats tab is active.
/// Figma: node 65-6515 "Statistic"
class StatsContent extends StatelessWidget {
  const StatsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomPad),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroCard(),
          SizedBox(height: 20),
          _ActivitySection(),
          SizedBox(height: 20),
          _OrbitHealthSection(),
        ],
      ),
    );
  }
}

// ─── Hero card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment(0.6, -1),
          end: Alignment(-0.2, 1),
          colors: [Color(0xFF1A2332), Color(0xFF0D1117)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative orbit rings
          const Positioned.fill(child: _HeroOrbits()),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── "4 people in orbit" ───────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '4',
                      style: AppTextStyles.successTitle.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1.0,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'people in orbit',
                        style: AppTextStyles.bodyRegular14.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Border top divider ────────────────────────────────────
                Container(
                  height: 1,
                  color: const Color(0xFF96A8C2).withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),

                // ── Two stats side by side ────────────────────────────────
                IntrinsicHeight(
                  child: Row(
                    children: [
                      // Most connected
                      Expanded(
                        child: _HeroStat(
                          avatarColor1: const Color(0xFF7E9ABB),
                          avatarColor2: const Color(0xFF334155),
                          initial: 'A',
                          label: 'Most connected',
                          value: 'Anna K. · 8×',
                          valueColor: Colors.white,
                        ),
                      ),

                      // Vertical divider
                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                      ),

                      // Needs attention
                      Expanded(
                        child: _HeroStat(
                          avatarColor1: const Color(0xFF4A6080),
                          avatarColor2: const Color(0xFF0D1117),
                          initial: 'J',
                          label: 'Needs attention',
                          value: 'James · 47d',
                          valueColor: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.avatarColor1,
    required this.avatarColor2,
    required this.initial,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final Color avatarColor1;
  final Color avatarColor2;
  final String initial;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar 28×28
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [avatarColor1, avatarColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.divider, width: 1.5),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Label + value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.settingsRowSubtitle.copyWith(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.80),
                ),
              ),
              Text(
                value,
                style: AppTextStyles.settingsRowTitle.copyWith(
                  fontSize: 13,
                  color: valueColor,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Decorative orbit rings drawn behind the hero card content.
class _HeroOrbits extends StatelessWidget {
  const _HeroOrbits();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _HeroOrbitsPainter());
  }
}

class _HeroOrbitsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width * 0.85, size.height * 0.2);
    for (final r in [50.0, 100.0, 160.0, 230.0]) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(_HeroOrbitsPainter old) => false;
}

// ─── Activity section ─────────────────────────────────────────────────────────

class _ActivitySection extends StatelessWidget {
  const _ActivitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Activity" label (75% opacity)
        Opacity(
          opacity: 0.75,
          child: Text(
            'Activity',
            style: AppTextStyles.bodyMedium16,
          ),
        ),
        const SizedBox(height: 12),

        // White card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ActivityGrid(),
                SizedBox(height: 8),
                _MonthLabels(),
                SizedBox(height: 12),
                _ActivityLegend(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityGrid extends StatelessWidget {
  const _ActivityGrid();

  static Color _cellColor(int level) {
    switch (level) {
      case 1:
        return _kLight;
      case 2:
        return _kMed;
      case 3:
        return _kDark;
      default:
        return _kEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_kGrid.length, (col) {
        return Column(
          children: List.generate(_kGrid[col].length, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: row < 6 ? 3 : 0),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _cellColor(_kGrid[col][row]),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

class _MonthLabels extends StatelessWidget {
  const _MonthLabels();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final totalWidth = constraints.maxWidth;
      final colWidth = (totalWidth + 3) / 14; // cell 22 + gap 3

      return Stack(
        children: [
          SizedBox(width: totalWidth, height: 16),
          ..._kMonths.map((m) {
            final left = m.col * colWidth;
            return Positioned(
              left: left,
              top: 0,
              child: Text(
                m.label,
                style: AppTextStyles.settingsRowSubtitle.copyWith(
                  fontSize: 12,
                  color: AppColors.cardBorder,
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

class _ActivityLegend extends StatelessWidget {
  const _ActivityLegend();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Each square = one connection',
      style: AppTextStyles.settingsRowSubtitle.copyWith(
        fontSize: 12,
        color: AppColors.cardBorder,
      ),
    );
  }
}

// ─── Orbit health section ─────────────────────────────────────────────────────

class _OrbitHealthSection extends StatelessWidget {
  const _OrbitHealthSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Orbit health" label
        Opacity(
          opacity: 0.75,
          child: Text('Orbit health', style: AppTextStyles.bodyMedium16),
        ),
        const SizedBox(height: 12),

        // White card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              children: List.generate(_kPeople.length, (i) {
                final p = _kPeople[i];
                final isOverdue = p.days > 14;
                final isLast = i == _kPeople.length - 1;
                return Column(
                  children: [
                    _PersonRow(
                      initial: p.initial,
                      name: p.name,
                      daysAgo: '${p.days} days ago',
                      isOverdue: isOverdue,
                      avatarColor1: Color(p.hue1),
                      avatarColor2: Color(p.hue2),
                    ),
                    if (!isLast)
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        color: AppColors.divider,
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.initial,
    required this.name,
    required this.daysAgo,
    required this.isOverdue,
    required this.avatarColor1,
    required this.avatarColor2,
  });

  final String initial;
  final String name;
  final String daysAgo;
  final bool isOverdue;
  final Color avatarColor1;
  final Color avatarColor2;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar 36×36
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [avatarColor1, avatarColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Name + days ago
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.settingsRowTitle.copyWith(
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              Text(
                daysAgo,
                style: AppTextStyles.settingsRowSubtitle.copyWith(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Status dot 8×8
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOverdue ? _kRed : _kGreen,
          ),
        ),
      ],
    );
  }
}
