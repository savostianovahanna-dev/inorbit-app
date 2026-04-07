import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/stats/stats_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';
import '../../../domain/entities/stats_data.dart';
import '../widgets/constellation_activity_section.dart';

// ─── Status-dot colours (spec) ────────────────────────────────────────────────

const _kStatusRed = Color(0xFFC0645A);
const _kStatusAmber = Color(0xFFC4985A);
const _kStatusGreen = Color(0xFF5B8A7D);

// ─── Root content widget ──────────────────────────────────────────────────────

/// Shown when the Stats tab is active. Provides its own [StatsBloc] and
/// handles all loading / error / loaded states.
class StatsContent extends StatelessWidget {
  const StatsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatsBloc>(
      create: (_) => getIt<StatsBloc>()..add(const StatsStarted()),
      child: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          return switch (state) {
            StatsInitial() || StatsLoading() => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            StatsError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyRegular14,
                ),
              ),
            ),
            StatsLoaded(:final data) => _StatsBody(data: data),
            // Dart exhaustiveness — never reached.
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

// ─── Loaded body ──────────────────────────────────────────────────────────────

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.data});

  final StatsData data;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroCard(data: data),
          const SizedBox(height: 20),
          ConstellationActivitySection(activityByDay: data.activityByDay),
          const SizedBox(height: 20),
          _OrbitHealthSection(friends: data.friendsOrderedByOverdue),
        ],
      ),
    );
  }
}

// ─── Hero card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.data});

  final StatsData data;

  static String _firstName(String name) => name.split(' ').first;

  String _attentionValue(Friend? f) {
    if (f == null) return '—';
    final d = f.daysSinceContact;
    if (d >= 9999) return '${_firstName(f.name)} · never';
    return '${_firstName(f.name)} · ${d}d';
  }

  String _connectedValue(Friend? f, int count) {
    if (f == null) return '—';
    return '${_firstName(f.name)} · $count×';
  }

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
          // Decorative orbit rings drawn behind content.
          const Positioned.fill(child: _HeroOrbits()),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── "N people in orbit" ───────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${data.totalFriends}',
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
                          label: 'Most connected',
                          friend: data.mostConnectedFriend,
                          value: _connectedValue(
                            data.mostConnectedFriend,
                            data.mostConnectedCount,
                          ),
                          valueColor: Colors.white,
                        ),
                      ),

                      // Vertical divider
                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color:
                            const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                      ),

                      // Needs attention
                      Expanded(
                        child: _HeroStat(
                          label: 'Needs attention',
                          friend: data.needsAttentionFriend,
                          value: _attentionValue(data.needsAttentionFriend),
                          valueColor: data.needsAttentionFriend != null
                              ? AppColors.orange
                              : Colors.white,
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
    required this.label,
    required this.friend,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final Friend? friend;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (friend != null) ...[
          _FriendAvatar(name: friend!.name, size: 28, showBorder: true),
          const SizedBox(width: 8),
        ],
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

/// Decorative orbit rings behind the hero card.
class _HeroOrbits extends StatelessWidget {
  const _HeroOrbits();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _HeroOrbitsPainter());
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

// ─── Orbit health section ─────────────────────────────────────────────────────

class _OrbitHealthSection extends StatelessWidget {
  const _OrbitHealthSection({required this.friends});

  final List<Friend> friends;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: 0.75,
          child: Text('Orbit health', style: AppTextStyles.bodyMedium16),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: friends.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Add friends to see orbit health',
                    style: AppTextStyles.bodyRegular14.copyWith(
                      color: AppColors.cardBorder,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Column(
                    children: List.generate(friends.length, (i) {
                      final isLast = i == friends.length - 1;
                      return Column(
                        children: [
                          _PersonRow(friend: friends[i]),
                          if (!isLast)
                            Container(
                              height: 0.5,
                              margin:
                                  const EdgeInsets.symmetric(vertical: 10),
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
  const _PersonRow({required this.friend});

  final Friend friend;

  Color get _statusColor {
    if (friend.isOverdue) return _kStatusRed;
    // Approaching: used ≥ 70 % of the allowed cadence.
    if (friend.frequencyDays > 0 &&
        friend.daysSinceContact > friend.frequencyDays * 0.7) {
      return _kStatusAmber;
    }
    return _kStatusGreen;
  }

  String get _daysText {
    final d = friend.daysSinceContact;
    if (d == 0) return 'Today';
    if (d == 1) return 'Yesterday';
    if (d >= 9999) return 'Never';
    return '$d days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _FriendAvatar(name: friend.name, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friend.name,
                style: AppTextStyles.settingsRowTitle.copyWith(
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              Text(
                _daysText,
                style: AppTextStyles.settingsRowSubtitle.copyWith(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Status dot 8 × 8
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _statusColor,
          ),
        ),
      ],
    );
  }
}

// ─── Shared avatar widget ─────────────────────────────────────────────────────

/// Circular avatar showing the first initial of [name] with a gradient
/// derived deterministically from the name.
class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({
    required this.name,
    required this.size,
    this.showBorder = false,
  });

  final String name;
  final double size;
  final bool showBorder;

  // Five gradient palettes — picked by name hash so the same friend always
  // gets the same colour.
  static const _palettes = [
    [Color(0xFF334155), Color(0xFF222222)],
    [Color(0xFF7E9ABB), Color(0xFF334155)],
    [Color(0xFF96A8C2), Color(0xFF4A6080)],
    [Color(0xFF4A6080), Color(0xFF222222)],
    [Color(0xFF6B8CAE), Color(0xFF1E2D3D)],
  ];

  List<Color> get _colors {
    final hash = name.codeUnits.fold(0, (acc, c) => acc * 31 + c);
    return _palettes[hash.abs() % _palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final colors = _colors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: showBorder
            ? Border.all(color: AppColors.divider, width: 1.5)
            : null,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}
