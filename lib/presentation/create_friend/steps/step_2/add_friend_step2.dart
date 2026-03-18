import 'package:flutter/material.dart';
import 'package:inorbit/core/theme/app_colors.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';

class AddFriendStep2 extends StatefulWidget {
  const AddFriendStep2({super.key, this.onOrbitChanged});
  final ValueChanged<int>? onOrbitChanged;

  @override
  State<AddFriendStep2> createState() => _AddFriendStep2State();
}

class _AddFriendStep2State extends State<AddFriendStep2> {
  int _selected = 0;

  static const _orbits = [
    (name: 'Inner Circle', freq: 'Every 2 weeks', desc: 'Your closest people'),
    (name: 'Regulars', freq: 'Monthly', desc: 'Important connections'),
    (name: 'Casuals', freq: 'Every 3 months', desc: 'Keeping in touch'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How close are you?', style: AppTextStyles.headerTitle),
        const SizedBox(height: 4),
        Text(
          'How often do you want to connect?',
          style: AppTextStyles.bodyRegular14.copyWith(
            color: const Color(0xFF334155),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_orbits.length, (i) {
          final o = _orbits[i];
          final sel = _selected == i;
          return GestureDetector(
            onTap: () {
              setState(() => _selected = i);
              widget.onOrbitChanged?.call(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: sel ? AppColors.orange : const Color(0xFFE2E8F0),
                  width: sel ? 2.0 : 0.63,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(sel ? 14 : 15.37),
                child: Stack(
                  children: [
                    // Planet image + overlays — only when selected
                    if (sel) ...[
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/planets/planet_8.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: ColoredBox(color: const Color(0xCC000000)),
                      ),
                      Positioned.fill(
                        child: ColoredBox(
                          color: const Color(0xFFDEA754).withValues(alpha: 0.10),
                        ),
                      ),
                    ],
                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  o.name,
                                  style: AppTextStyles.headerTitle.copyWith(
                                    color: sel
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  o.freq,
                                  style: AppTextStyles.bodyRegular14.copyWith(
                                    fontSize: 14,
                                    color: sel
                                        ? Colors.white.withValues(alpha: 0.75)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  o.desc,
                                  style: AppTextStyles.labelRegular14.copyWith(
                                    fontSize: 12,
                                    color: sel
                                        ? Colors.white.withValues(alpha: 0.55)
                                        : AppColors.textSecondary
                                            .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _RadioDot(selected: sel),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: 25,
      child: CustomPaint(painter: _RadioDotPainter(selected: selected)),
    );
  }
}

class _RadioDotPainter extends CustomPainter {
  const _RadioDotPainter({required this.selected});
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final strokePaint = Paint()
      ..color = const Color(0xFF96A8C2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawCircle(center, radius - 0.3, strokePaint);

    if (selected) {
      final innerRadius = 12.85 / 2;
      final innerCenter = Offset(6.07 + innerRadius, 6.07 + innerRadius);
      canvas.drawCircle(
        innerCenter,
        innerRadius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_RadioDotPainter old) => old.selected != selected;
}
