import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';
import '../../../domain/entities/moment.dart';
import '../../../domain/usecases/add_moment_use_case.dart';
import '../../../shared/widgets/dark_button.dart';
import '../../../shared/widgets/multiline_text_field.dart';

/// "Log a moment" screen — same visuals as LogMomentScreen but the submit
/// button scrolls with content instead of being pinned to the bottom.
class LogMomentScreenV2 extends StatefulWidget {
  const LogMomentScreenV2({
    super.key,
    required this.friend,
    this.variant = 1,
  });

  final Friend friend;
  final int variant;

  @override
  State<LogMomentScreenV2> createState() => _LogMomentScreenV2State();
}

class _LogMomentScreenV2State extends State<LogMomentScreenV2> {
  _ActivityType _selectedActivity = _ActivityType.coffee;
  _WhenOption _when = _WhenOption.today;
  DateTime? _customDate;
  bool _saving = false;
  final _noteController = TextEditingController();
  final _scrollController = ScrollController();
  final _notesFocusNode = FocusNode();
  final _notesKey = GlobalKey();
  final List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _notesFocusNode.addListener(_onNotesFocusChanged);
  }

  void _onNotesFocusChanged() {
    if (_notesFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        final ctx = _notesKey.currentContext;
        if (ctx != null) {
          // ignore: use_build_context_synchronously
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.0,
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

  void _showWhenDatePicker() {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    var temp = _customDate ?? now;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.bodyRegular14.copyWith(
                        color: AppColors.cardBorder,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text('When?', style: AppTextStyles.headerTitle),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _customDate = temp;
                        _when = _WhenOption.custom;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'Done',
                      style: AppTextStyles.headerTitle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 216,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: temp,
                maximumDate: now,
                minimumYear: 1900,
                onDateTimeChanged: (d) => temp = d,
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _logMoment() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final date = switch (_when) {
        _WhenOption.today => DateTime.now(),
        _WhenOption.yesterday =>
          DateTime.now().subtract(const Duration(days: 1)),
        _WhenOption.custom => _customDate ?? DateTime.now(),
      };

      final moment = Moment(
        id: const Uuid().v4(),
        friendId: widget.friend.id,
        type: _selectedActivity.name,
        date: date,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        photoPaths: List.unmodifiable(_photos),
        createdAt: DateTime.now(),
      );

      await getIt<AddMomentUseCase>().call(moment);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addPhoto(String path) => setState(() => _photos.add(path));

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomPad),
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
                  customDate: _customDate,
                  onSelect: (w) => setState(() => _when = w),
                  onPickDate: _showWhenDatePicker,
                ),
                const SizedBox(height: 20),

                Text('Add photos', style: AppTextStyles.sectionHeading),
                const SizedBox(height: 8),
                _PhotosRow(
                  photos: _photos,
                  onPhotoAdded: _addPhoto,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  key: _notesKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What happened?',
                        style: AppTextStyles.sectionHeading,
                      ),
                      const SizedBox(height: 8),
                      MultilineTextField(
                        controller: _noteController,
                        focusNode: _notesFocusNode,
                        hintText: 'Caught up at the usual spot...',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                DarkButton(
                  label: 'Log moment',
                  onTap: _saving ? null : _logMoment,
                  saving: _saving,
                  leadingIcon: SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomPaint(painter: _PlusPainter()),
                  ),
                ),
              ],
            ),
          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      type.emoji,
                      style: const TextStyle(fontSize: 22, height: 1),
                    ),
                    const SizedBox(width: 6),
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
  const _WhenRow({
    required this.selected,
    required this.onSelect,
    required this.onPickDate,
    this.customDate,
  });
  final _WhenOption selected;
  final ValueChanged<_WhenOption> onSelect;
  final VoidCallback onPickDate;
  final DateTime? customDate;

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
            date: customDate,
            onTap: onPickDate,
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
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
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
                    fontSize: 14,
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
  const _DateInputChip({
    required this.isSelected,
    required this.onTap,
    this.date,
  });
  final bool isSelected;
  final VoidCallback onTap;
  final DateTime? date;

  String get _label {
    if (date == null) return 'DD/MM';
    final d = date!.day.toString().padLeft(2, '0');
    final m = date!.month.toString().padLeft(2, '0');
    return '$d/$m';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _label,
                      style: AppTextStyles.bodyRegular14.copyWith(
                        fontSize: 14,
                        color: isSelected
                            ? Colors.white
                            : (date != null
                                ? AppColors.textPrimary
                                : const Color(0xFF96A8C2)),
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
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add photos ───────────────────────────────────────────────────────────────

class _PhotosRow extends StatefulWidget {
  const _PhotosRow({required this.photos, required this.onPhotoAdded});
  final List<String> photos;
  final ValueChanged<String> onPhotoAdded;

  @override
  State<_PhotosRow> createState() => _PhotosRowState();
}

class _PhotosRowState extends State<_PhotosRow> {
  Future<void> _pickImage({required bool fromCamera}) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) widget.onPhotoAdded(file.path);
  }

  void _showPicker(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _SheetButton(
                label: '📷  Take a photo',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(fromCamera: true);
                },
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              _SheetButton(
                label: '🖼  Choose from gallery',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(fromCamera: false);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final path in widget.photos)
          _PhotoSlot(imagePath: path, onTap: () {}),
        _PhotoSlot(
          imagePath: null,
          onTap: () => _showPicker(context),
        ),
      ],
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: Colors.transparent,
        child: Text(
          label,
          style: AppTextStyles.bodyMedium16.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.onTap, this.imagePath});
  final VoidCallback onTap;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 83,
        height: 80,
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                  width: 83,
                  height: 80,
                ),
              )
            : CustomPaint(
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
