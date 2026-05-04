import 'dart:math' show max;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';
import '../../../domain/repositories/friend_repository.dart';
import '../../../shared/widgets/dark_button.dart';
import '../../../shared/widgets/labeled_input.dart';
import '../../../shared/widgets/multiline_text_field.dart';
import '../../create_friend/steps/step_1/avatar_picker.dart';
import '../../create_friend/steps/step_1/labeled_birthday_input.dart';
import '../../create_friend/steps/step_1/remind_birthday_row.dart';

/// Edit friend screen — single-column form, pre-filled with [friend] data.
class EditFriendScreen extends StatefulWidget {
  const EditFriendScreen({super.key, required this.friend});

  final Friend friend;

  @override
  State<EditFriendScreen> createState() => _EditFriendScreenState();
}

class _EditFriendScreenState extends State<EditFriendScreen> {
  // ── Constants (mirrors add_friend_screen.dart) ──────────────────────────────
  static const _orbitTiers = ['inner_circle', 'regulars', 'casuals'];
  static const _freqDays = [14, 30, 90];
  static const _orbits = [
    (name: 'Inner Circle', freq: 'Every 2 weeks', desc: 'Your closest people'),
    (name: 'Regulars', freq: 'Monthly', desc: 'Important connections'),
    (name: 'Casuals', freq: 'Every 3 months', desc: 'Keeping in touch'),
  ];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // ── Controllers ─────────────────────────────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _birthdayCtrl;
  late final TextEditingController _notesCtrl;

  // ── State ───────────────────────────────────────────────────────────────────
  int? _planetIndex;
  String? _avatarPath;
  DateTime? _birthday;
  bool _remindBirthday = true;
  int _orbitIndex = 0;
  DateTime? _lastConnectedAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final f = widget.friend;
    _nameCtrl = TextEditingController(text: f.name);
    _birthdayCtrl = TextEditingController();
    _notesCtrl = TextEditingController(text: f.notes ?? '');

    _planetIndex = f.planetIndex;
    _avatarPath = f.avatarPath;
    _birthday = f.birthday;
    _remindBirthday = f.remindBirthday;
    _orbitIndex = max(0, _orbitTiers.indexOf(f.orbitTier));
    _lastConnectedAt = f.lastConnectedAt;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthdayCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Save ────────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final updated = widget.friend.copyWith(
      name:
          _nameCtrl.text.trim().isEmpty
              ? widget.friend.name
              : _nameCtrl.text.trim(),
      planetIndex: _planetIndex,
      avatarPath: _avatarPath,
      birthday: _birthday,
      remindBirthday: _remindBirthday,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      orbitTier: _orbitTiers[_orbitIndex],
      frequencyDays: _freqDays[_orbitIndex],
      lastConnectedAt: _lastConnectedAt,
    );

    await getIt<FriendRepository>().updateFriend(updated);
    if (mounted) Navigator.pop(context);
  }

  // ── Last connected date picker ───────────────────────────────────────────────
  void _showDatePicker() {
    final now = DateTime.now();
    var temp = _lastConnectedAt ?? now;

    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (ctx) => Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
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
                      Text('Last connected', style: AppTextStyles.headerTitle),
                      GestureDetector(
                        onTap: () {
                          setState(() => _lastConnectedAt = temp);
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

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final firstName = widget.friend.name.split(' ').first;
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
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
              'Edit $firstName',
              style: AppTextStyles.headerTitle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40), // balance the back button
        ],
      ),
    );
  }

  // ── Orbit picker ─────────────────────────────────────────────────────────────
  Widget _buildOrbitPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How close are you?', style: AppTextStyles.sectionHeading),
        const SizedBox(height: 12),
        ...List.generate(_orbits.length, (i) {
          final o = _orbits[i];
          final sel = _orbitIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _orbitIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: sel ? AppColors.orange : AppColors.divider,
                  width: sel ? 2.0 : 0.63,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(sel ? 14 : 15.37),
                child: Stack(
                  children: [
                    if (sel) ...[
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/planets/planet_8.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Positioned.fill(
                        child: ColoredBox(color: Color(0xCC000000)),
                      ),
                      Positioned.fill(
                        child: ColoredBox(
                          color: const Color(
                            0xFFDEA754,
                          ).withValues(alpha: 0.10),
                        ),
                      ),
                    ],
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
                                    color:
                                        sel
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  o.freq,
                                  style: AppTextStyles.bodyRegular14.copyWith(
                                    fontSize: 14,
                                    color:
                                        sel
                                            ? Colors.white.withValues(
                                              alpha: 0.75,
                                            )
                                            : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  o.desc,
                                  style: AppTextStyles.labelRegular14.copyWith(
                                    fontSize: 12,
                                    color:
                                        sel
                                            ? Colors.white.withValues(
                                              alpha: 0.55,
                                            )
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

  // ── Last connected row ───────────────────────────────────────────────────────
  Widget _buildLastConnected() {
    final label =
        _lastConnectedAt != null
            ? '${_months[_lastConnectedAt!.month - 1]} ${_lastConnectedAt!.day}, ${_lastConnectedAt!.year}'
            : 'Pick date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Last connected', style: AppTextStyles.sectionHeading),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showDatePicker,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider, width: 0.63),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyRegular14.copyWith(
                    fontSize: 14,
                    color:
                        _lastConnectedAt != null
                            ? AppColors.textPrimary
                            : AppColors.textPrimary.withValues(alpha: 0.35),
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // ── Scrollable form ─────────────────────────────────────────────
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 8, 16, 80 + bottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Avatar
                    AvatarPicker(
                      initialPlanetIndex: _planetIndex,
                      initialAvatarPath: _avatarPath,
                      onPlanetIndexChanged:
                          (i) => setState(
                            () =>
                                _planetIndex = (i != null && i > 0) ? i - 1 : i,
                          ),
                      onAvatarPathChanged:
                          (p) => setState(() => _avatarPath = p),
                    ),
                    const SizedBox(height: 24),

                    // Name
                    LabeledInput(
                      label: 'Name',
                      controller: _nameCtrl,
                      hint: 'Anna',
                    ),
                    const SizedBox(height: 20),

                    // Birthday
                    LabeledBirthdayInput(
                      controller: _birthdayCtrl,
                      initialDate: _birthday,
                    ),
                    const SizedBox(height: 8),

                    // Remind birthday toggle
                    RemindBirthdayRow(
                      initialValue: _remindBirthday,
                      onChanged: (v) => setState(() => _remindBirthday = v),
                    ),
                    const SizedBox(height: 20),

                    // Notes
                    Text('Notes', style: AppTextStyles.tagLabel),
                    const SizedBox(height: 8),
                    MultilineTextField(
                      controller: _notesCtrl,
                      hintText: "Something you don't want to forget about",
                    ),
                    const SizedBox(height: 28),

                    // Orbit picker
                    _buildOrbitPicker(),
                    const SizedBox(height: 8),

                    // Last connected
                    _buildLastConnected(),
                  ],
                ),
              ),

              // ── Sticky save button ───────────────────────────────────────────
              Positioned(
                bottom: bottomPad + 16,
                left: 16,
                right: 16,
                child: DarkButton(
                  label: 'Save changes',
                  onTap: _saving ? null : _save,
                  saving: _saving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Radio dot (matches AddFriendStep2) ────────────────────────────────────────

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

    final strokePaint =
        Paint()
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

// ── Back chevron (matches FriendHeader) ──────────────────────────────────────

class _ChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.textPrimary
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final path =
        Path()
          ..moveTo(cx + 3, cy - 6)
          ..lineTo(cx - 3, cy)
          ..lineTo(cx + 3, cy + 6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => false;
}
