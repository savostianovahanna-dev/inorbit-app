import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/friend_header.dart';

/// "Log a moment" screen — Figma node 58-7441.
///
/// Lets the user record a recent interaction with a friend:
/// activity type, when it happened, optional photos, and a free-text note.
class LogMomentScreen extends StatefulWidget {
  const LogMomentScreen({super.key, required this.friendName});

  final String friendName;

  @override
  State<LogMomentScreen> createState() => _LogMomentScreenState();
}

class _LogMomentScreenState extends State<LogMomentScreen> {
  _ActivityType _selected = _ActivityType.coffee;
  _WhenOption _when = _WhenOption.yesterday;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 8, 16, 80 + bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: back + "Log a moment" + invisible right btn
                  _LogHeader(title: 'Log a moment'),
                  const SizedBox(height: 20),

                  // Mini friend card (photo + name)
                  _FriendMiniCard(name: widget.friendName),
                  const SizedBox(height: 20),

                  // Activity type picker
                  _SectionLabel('How did you connect?'),
                  const SizedBox(height: 8),
                  _ActivityRow(
                    selected: _selected,
                    onSelect: (t) => setState(() => _selected = t),
                  ),
                  const SizedBox(height: 20),

                  // When picker
                  _SectionLabel('When?'),
                  const SizedBox(height: 8),
                  _WhenRow(
                    selected: _when,
                    onSelect: (w) => setState(() => _when = w),
                  ),
                  const SizedBox(height: 20),

                  // Add photos
                  _SectionLabel('Add photos'),
                  const SizedBox(height: 8),
                  _AddPhotosButton(),
                  const SizedBox(height: 20),

                  // Notes textarea
                  _SectionLabel('What happened?'),
                  const SizedBox(height: 8),
                  _NotesField(controller: _noteController),
                ],
              ),
            ),

            // Sticky "Log moment" button
            Positioned(
              bottom: bottomPad + 16,
              left: 16,
              right: 16,
              child: _LogButton(onTap: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.sectionHeading);
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _LogHeader extends StatelessWidget {
  const _LogHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CustomPaint(painter: _ChevronPainter()),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headerTitle,
              textAlign: TextAlign.center,
            ),
          ),
          // Invisible placeholder to keep title centered
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawPath(
      Path()
        ..moveTo(cx + 3, cy - 6)
        ..lineTo(cx - 3, cy)
        ..lineTo(cx + 3, cy + 6),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => false;
}

// ─── Friend mini card ─────────────────────────────────────────────────────────

class _FriendMiniCard extends StatelessWidget {
  const _FriendMiniCard({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: 82,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder photo background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A6275), Color(0xFF1E2D3D)],
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.30, 0.68],
                  colors: [Colors.transparent, Color(0xFF111111)],
                ),
              ),
            ),
            // Name
            Positioned(
              top: 26,
              left: 20,
              child: Text(name, style: AppTextStyles.friendName),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Activity type ────────────────────────────────────────────────────────────

enum _ActivityType { coffee, call, text, dinner, movie, shopping, other }

extension _ActivityTypeX on _ActivityType {
  String get emoji {
    switch (this) {
      case _ActivityType.coffee:   return '☕';
      case _ActivityType.call:     return '📞';
      case _ActivityType.text:     return '💬';
      case _ActivityType.dinner:   return '🍽';
      case _ActivityType.movie:    return '🎬';
      case _ActivityType.shopping: return '🛍';
      case _ActivityType.other:    return '✨';
    }
  }

  String get label {
    switch (this) {
      case _ActivityType.coffee:   return 'Coffee';
      case _ActivityType.call:     return 'Call';
      case _ActivityType.text:     return 'Text';
      case _ActivityType.dinner:   return 'Dinner';
      case _ActivityType.movie:    return 'Movie';
      case _ActivityType.shopping: return 'Shopping';
      case _ActivityType.other:    return 'Other';
    }
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.selected, required this.onSelect});

  final _ActivityType selected;
  final ValueChanged<_ActivityType> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _ActivityType.values
            .map((t) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ActivityPill(
                    type: t,
                    isSelected: selected == t,
                    onTap: () => onSelect(t),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _ActivityPill extends StatelessWidget {
  const _ActivityPill({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final _ActivityType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.textSecondary : AppColors.divider,
            width: isSelected ? 1.0 : 1.0,
          ),
        ),
        child: SizedBox(
          width: 58,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type.emoji,
                style: const TextStyle(fontSize: 28, height: 1.2),
              ),
              const SizedBox(height: 6),
              Text(
                type.label,
                style: isSelected
                    ? AppTextStyles.momentTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )
                    : AppTextStyles.bodyRegular14.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── When picker ──────────────────────────────────────────────────────────────

enum _WhenOption { today, yesterday, custom }

class _WhenRow extends StatelessWidget {
  const _WhenRow({required this.selected, required this.onSelect});

  final _WhenOption selected;
  final ValueChanged<_WhenOption> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _WhenChip(
            label: 'Today',
            isSelected: selected == _WhenOption.today,
            onTap: () => onSelect(_WhenOption.today),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _WhenChip(
            label: 'Yesterday',
            isSelected: selected == _WhenOption.yesterday,
            onTap: () => onSelect(_WhenOption.yesterday),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _DateInputChip(
            isSelected: selected == _WhenOption.custom,
            onTap: () => onSelect(_WhenOption.custom),
          ),
        ),
      ],
    );
  }
}

class _WhenChip extends StatelessWidget {
  const _WhenChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.orange.withValues(alpha: 0.08)
              : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.textSecondary : AppColors.divider,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: isSelected
              ? AppTextStyles.sectionHeading.copyWith(
                  color: AppColors.textPrimary,
                  height: 1,
                )
              : AppTextStyles.bodyRegular14.copyWith(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1,
                ),
        ),
      ),
    );
  }
}

class _DateInputChip extends StatelessWidget {
  const _DateInputChip({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DD/MM',
              style: AppTextStyles.bodyRegular14.copyWith(
                color: AppColors.cardBorder,
              ),
            ),
            const _CalendarIcon(),
          ],
        ),
      ),
    );
  }
}

class _CalendarIcon extends StatelessWidget {
  const _CalendarIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 19,
      height: 20,
      child: CustomPaint(painter: _CalendarPainter()),
    );
  }
}

class _CalendarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cardBorder
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Outer rectangle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 2, size.width, size.height - 2),
        const Radius.circular(3),
      ),
      paint,
    );
    // Top bar
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      paint,
    );
    // Left tab
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, 5),
      paint..strokeWidth = 1.5,
    );
    // Right tab
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, 5),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CalendarPainter old) => false;
}

// ─── Add photos ───────────────────────────────────────────────────────────────

class _AddPhotosButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: open image picker
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          '+',
          style: AppTextStyles.sectionHeading.copyWith(
            fontSize: 24,
            color: AppColors.cardBorder,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ─── Notes textarea ───────────────────────────────────────────────────────────

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 5,
      style: AppTextStyles.bodyRegular14,
      decoration: InputDecoration(
        hintText: 'Caught up at the usual spot...',
        hintStyle: AppTextStyles.bodyRegular14.copyWith(
          color: AppColors.cardBorder,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

// ─── Log moment button ────────────────────────────────────────────────────────

class _LogButton extends StatelessWidget {
  const _LogButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.buttonDark,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(painter: _PlusPainter()),
            ),
            const SizedBox(width: 12),
            Text('Log moment', style: AppTextStyles.logButtonLabel),
          ],
        ),
      ),
    );
  }
}

class _PlusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const arm = 5.83;
    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), paint);
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), paint);
  }

  @override
  bool shouldRepaint(_PlusPainter old) => false;
}
