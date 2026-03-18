import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';
import '../../../domain/entities/moment.dart';
import '../../../domain/repositories/moment_repository.dart';

/// "Log a moment" screen — Figma node 173-7231.
class LogMomentScreen extends StatefulWidget {
  const LogMomentScreen({
    super.key,
    required this.friend,
  });

  final Friend friend;

  @override
  State<LogMomentScreen> createState() => _LogMomentScreenState();
}

class _LogMomentScreenState extends State<LogMomentScreen> {
  _ActivityType _selectedActivity = _ActivityType.coffee;
  _WhenOption _when = _WhenOption.today;
  final _noteController = TextEditingController();
  final _scrollController = ScrollController();
  final _notesFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _notesFocusNode.addListener(_onNotesFocusChanged);
  }

  void _onNotesFocusChanged() {
    if (_notesFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _notesFocusNode.removeListener(_onNotesFocusChanged);
    _notesFocusNode.dispose();
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _logMoment() async {
    final date = switch (_when) {
      _WhenOption.today => DateTime.now(),
      _WhenOption.yesterday =>
        DateTime.now().subtract(const Duration(days: 1)),
      _WhenOption.custom => DateTime.now(),
    };

    final moment = Moment(
      id: const Uuid().v4(),
      friendId: widget.friend.id,
      type: _selectedActivity.name,
      date: date,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      photoPaths: const [],
      createdAt: DateTime.now(),
    );

    await getIt<MomentRepository>().addMoment(moment);
    if (mounted) Navigator.pop(context);
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
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 8, 16, 100 + bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LogHeader(),
                  const SizedBox(height: 20),

                  _FriendMiniCard(friend: widget.friend),
                  const SizedBox(height: 20),

                  Text(
                    'How did you connect?',
                    style: AppTextStyles.sectionHeading,
                  ),
                  const SizedBox(height: 8),
                  _ActivityGrid(
                    selected: _selectedActivity,
                    onSelect: (t) => setState(() => _selectedActivity = t),
                  ),
                  const SizedBox(height: 20),

                  Text('When?', style: AppTextStyles.sectionHeading),
                  const SizedBox(height: 8),
                  _WhenRow(
                    selected: _when,
                    onSelect: (w) => setState(() => _when = w),
                  ),
                  const SizedBox(height: 20),

                  Text('Add photos', style: AppTextStyles.sectionHeading),
                  const SizedBox(height: 8),
                  const _PhotosRow(),
                  const SizedBox(height: 20),

                  Text('What happened?', style: AppTextStyles.sectionHeading),
                  const SizedBox(height: 8),
                  _NotesField(
                    controller: _noteController,
                    focusNode: _notesFocusNode,
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: bottomPad + 16,
              left: 16,
              right: 16,
              child: _LogButton(onTap: _logMoment),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _LogHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
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
              'Log a moment',
              style: AppTextStyles.headerTitle,
              textAlign: TextAlign.center,
            ),
          ),
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
  const _FriendMiniCard({required this.friend});
  final Friend friend;

  Widget _buildBackground() {
    if (friend.avatarPath != null && friend.avatarPath!.isNotEmpty) {
      return Image.file(
        File(friend.avatarPath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty) {
      return Image.network(
        friend.avatarUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (friend.planetIndex != null) {
      return Image.asset(
        'assets/images/planets/planet_${friend.planetIndex! + 1}.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Image.asset(
      'assets/onboarding1.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

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
            _buildBackground(),
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
            Positioned(
              bottom: 14,
              left: 20,
              child: Text(friend.name, style: AppTextStyles.friendName),
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
  String get emoji => switch (this) {
        _ActivityType.coffee => '☕',
        _ActivityType.call => '📞',
        _ActivityType.text => '💬',
        _ActivityType.dinner => '🍽',
        _ActivityType.movie => '🎬',
        _ActivityType.shopping => '🛍',
        _ActivityType.other => '✨',
      };

  String get label => switch (this) {
        _ActivityType.coffee => 'Coffee',
        _ActivityType.call => 'Call',
        _ActivityType.text => 'Text',
        _ActivityType.dinner => 'Dinner',
        _ActivityType.movie => 'Movie',
        _ActivityType.shopping => 'Shopping',
        _ActivityType.other => 'Other',
      };
}

class _ActivityGrid extends StatelessWidget {
  const _ActivityGrid({required this.selected, required this.onSelect});
  final _ActivityType selected;
  final ValueChanged<_ActivityType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _ActivityType.values
          .map((t) => _ActivityChip(
                type: t,
                isSelected: selected == t,
                onTap: () => onSelect(t),
              ))
          .toList(),
    );
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final _ActivityType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hPadding = isSelected ? 24.0 : 16.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            children: [
              if (isSelected) ...[
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/planets/planet_4.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const Positioned.fill(
                  child: ColoredBox(color: Color(0x8C000000)),
                ),
              ],
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: hPadding,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 35,
                      height: 42,
                      child: Center(
                        child: Text(
                          type.emoji,
                          style: const TextStyle(fontSize: 28, height: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.label,
                      style: isSelected
                          ? AppTextStyles.tagLabel.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            )
                          : AppTextStyles.bodyRegular14.copyWith(
                              color: const Color(0xFF334155),
                              fontSize: 14,
                            ),
                    ),
                  ],
                ),
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isSelected) ...[
                Image.asset(
                  'assets/images/planets/planet_6.png',
                  fit: BoxFit.cover,
                ),
                const ColoredBox(color: Color(0x8C000000)),
              ],
              Center(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium16.copyWith(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DD/MM',
              style: AppTextStyles.bodyRegular14.copyWith(
                color: const Color(0xFF96A8C2),
                fontSize: 14,
              ),
            ),
            Image.asset(
              'assets/images/calendar.png',
              width: 19,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add photos ───────────────────────────────────────────────────────────────

class _PhotosRow extends StatelessWidget {
  const _PhotosRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PhotoSlot(onTap: () {}),
        const SizedBox(width: 8),
        _PhotoSlot(onTap: () {}),
      ],
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 83,
        height: 80,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Center(
            child: Text(
              '+',
              style: AppTextStyles.headerTitle.copyWith(
                fontSize: 24,
                color: const Color(0xFF96A8C2),
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashLen = 6.0;
    const gapLen = 7.0;
    const radius = 16.0;
    const sw = 1.0;

    final paint = Paint()
      ..color = const Color(0xFF96A8C2)
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(sw / 2, sw / 2, size.width - sw, size.height - sw),
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      bool draw = true;
      while (dist < metric.length) {
        final len = draw ? dashLen : gapLen;
        if (draw) {
          canvas.drawPath(metric.extractPath(dist, dist + len), paint);
        }
        dist += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => false;
}

// ─── Notes textarea ───────────────────────────────────────────────────────────

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller, required this.focusNode});
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1),
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: 5,
      style: AppTextStyles.bodyRegular14.copyWith(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Caught up at the usual spot...',
        hintStyle: AppTextStyles.bodyRegular14.copyWith(
          color: const Color(0xFF96A8C2),
          fontSize: 14,
        ),
        filled: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: Color(0xFF96A8C2), width: 1),
        ),
      ),
    );
  }
}

// ─── Log button ───────────────────────────────────────────────────────────────

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
