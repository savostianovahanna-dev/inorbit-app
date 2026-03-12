import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';
import '../../../domain/repositories/friend_repository.dart';
import 'add_friend_success_screen.dart';

// ─── Planet asset paths ───────────────────────────────────────────────────────

const _kPlanets = [
  'assets/images/planets/planet_1.png',
  'assets/images/planets/planet_2.png',
  'assets/images/planets/planet_3.png',
  'assets/images/planets/planet_4.png',
  'assets/images/planets/planet_5.png',
  'assets/images/planets/planet_6.png',
  'assets/images/planets/planet_7.png',
  'assets/images/planets/planet_8.png',
];

// ─── Main Screen ──────────────────────────────────────────────────────────────

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  int _step = 1;
  static const _totalSteps = 3;

  final _nameCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController();

  // Lifted state from child steps
  int _orbitTierIndex = 0;
  DateTime? _lastConnectedAt;
  int? _planetIndex;
  String? _avatarFilePath;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthdayCtrl.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (_step < _totalSteps) {
      setState(() => _step++);
    } else {
      if (_saving) return;
      setState(() => _saving = true);
      try {
        final name =
            _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'Friend';
        const orbitTiers = ['inner_circle', 'regulars', 'casuals'];
        const freqDays = [14, 30, 90];
        final friend = Friend(
          id: const Uuid().v4(),
          name: name,
          planetIndex: _planetIndex,
          avatarPath: _avatarFilePath,
          orbitTier: orbitTiers[_orbitTierIndex],
          frequencyDays: freqDays[_orbitTierIndex],
          lastConnectedAt: _lastConnectedAt,
          createdAt: DateTime.now(),
        );
        await getIt<FriendRepository>().addFriend(friend);
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AddFriendSuccessScreen(friendName: name),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }
  }

  void _goBack() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
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
              padding: EdgeInsets.fromLTRB(16, 8, 16, 96 + bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AddFriendHeader(
                    onBack: _goBack,
                    onClose:
                        () => Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                  const SizedBox(height: 12),
                  _ProgressBar(currentStep: _step, totalSteps: _totalSteps),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder:
                        (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _buildStepContent(),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ContinueButton(
                label: _step < _totalSteps
                    ? 'Continue →'
                    : (_saving ? 'Saving...' : 'Add to orbit'),
                showCheck: _step == _totalSteps && !_saving,
                onTap: _saving ? () {} : _goNext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 1:
        return _Step1(
          nameCtrl: _nameCtrl,
          birthdayCtrl: _birthdayCtrl,
          onPlanetIndexChanged: (i) => setState(() => _planetIndex = i),
          onAvatarPathChanged: (p) => setState(() => _avatarFilePath = p),
        );
      case 2:
        return _Step2(
          onOrbitChanged: (i) => setState(() => _orbitTierIndex = i),
        );
      case 3:
        return _Step3(
          onDateChanged: (d) => setState(() => _lastConnectedAt = d),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _AddFriendHeader extends StatelessWidget {
  const _AddFriendHeader({required this.onBack, required this.onClose});
  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          onTap: onBack,
          opacity: 0.35,
          child: CustomPaint(
            size: const Size(8, 13),
            painter: _BackChevronPainter(),
          ),
        ),
        Expanded(
          child: Center(
            child: Text('Add friend', style: AppTextStyles.headerTitle),
          ),
        ),
        _CircleIconButton(
          onTap: onClose,
          child: CustomPaint(
            size: const Size(12, 12),
            painter: _CloseIconPainter(),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.child,
    this.onTap,
    this.opacity = 1.0,
  });
  final Widget child;
  final VoidCallback? onTap;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder, width: 0.63),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _BackChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.textPrimary
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
    final path =
        Path()
          ..moveTo(size.width, 0)
          ..lineTo(0, size.height / 2)
          ..lineTo(size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BackChevronPainter old) => false;
}

class _CloseIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.textPrimary
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_CloseIconPainter old) => false;
}

// ─── Progress Bar ─────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.currentStep, required this.totalSteps});
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color:
                  i < currentStep ? AppColors.textPrimary : AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Step 1: Basic info ───────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  const _Step1({
    required this.nameCtrl,
    required this.birthdayCtrl,
    this.onPlanetIndexChanged,
    this.onAvatarPathChanged,
  });
  final TextEditingController nameCtrl;
  final TextEditingController birthdayCtrl;
  final ValueChanged<int?>? onPlanetIndexChanged;
  final ValueChanged<String?>? onAvatarPathChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AvatarPicker(
          onPlanetIndexChanged: onPlanetIndexChanged,
          onAvatarPathChanged: onAvatarPathChanged,
        ),
        const SizedBox(height: 24),
        _LabeledInput(label: 'Name', controller: nameCtrl, hint: 'Anna'),
        const SizedBox(height: 20),
        _LabeledBirthdayInput(controller: birthdayCtrl),
      ],
    );
  }
}

// ─── Avatar Picker (stateful — holds selected planet) ─────────────────────────

class _AvatarPicker extends StatefulWidget {
  const _AvatarPicker({this.onPlanetIndexChanged, this.onAvatarPathChanged});

  final ValueChanged<int?>? onPlanetIndexChanged;
  final ValueChanged<String?>? onAvatarPathChanged;

  @override
  State<_AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<_AvatarPicker> {
  String? _selectedPlanet; // asset path
  XFile? _pickedFile; // from camera / gallery

  bool get _hasPhoto => _selectedPlanet != null || _pickedFile != null;

  void _openSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF222222).withValues(alpha: 0.5),
      isScrollControlled: true,
      builder:
          (_) => _PhotoPickerSheet(
            selectedPlanet: _selectedPlanet,
            onPlanetSelected: (path) {
              setState(() {
                _selectedPlanet = path;
                _pickedFile = null;
              });
              // "assets/images/planets/planet_3.png" → 3
              final index = int.tryParse(
                path.split('_').last.split('.').first,
              );
              widget.onPlanetIndexChanged?.call(index);
              widget.onAvatarPathChanged?.call(null);
              Navigator.pop(context);
            },
            onPhotoSelected: (file) {
              setState(() {
                _pickedFile = file;
                _selectedPlanet = null;
              });
              widget.onAvatarPathChanged?.call(file.path);
              widget.onPlanetIndexChanged?.call(null);
              Navigator.pop(context);
            },
          ),
    );
  }

  Widget _buildAvatar() {
    if (_pickedFile != null) {
      return Image.file(
        File(_pickedFile!.path),
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    }
    if (_selectedPlanet != null) {
      return Image.asset(
        _selectedPlanet!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    }
    return Center(
      child: CustomPaint(
        size: const Size(44, 44),
        painter: _CameraIconPainter(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _openSheet,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildAvatar(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _hasPhoto ? 'Tap to change photo' : 'Tap to add photo',
            style: AppTextStyles.avatarInitials12.copyWith(
              color: AppColors.cardBorder,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint =
        Paint()
          ..color = AppColors.cardBorder
          ..strokeWidth = 2.14
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    // Camera body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.27, size.width, size.height * 0.67),
        const Radius.circular(5),
      ),
      strokePaint,
    );
    // Lens
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.61),
      size.width * 0.20,
      strokePaint,
    );
    // Viewfinder bump
    final bump =
        Path()
          ..moveTo(size.width * 0.30, size.height * 0.27)
          ..lineTo(size.width * 0.38, size.height * 0.16)
          ..lineTo(size.width * 0.62, size.height * 0.16)
          ..lineTo(size.width * 0.70, size.height * 0.27);
    canvas.drawPath(bump, strokePaint);
    // Indicator dot
    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.38),
      2.5,
      Paint()
        ..color = AppColors.cardBorder
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_CameraIconPainter old) => false;
}

// ─── Photo Picker Bottom Sheet ────────────────────────────────────────────────

class _PhotoPickerSheet extends StatefulWidget {
  const _PhotoPickerSheet({
    required this.onPlanetSelected,
    required this.onPhotoSelected,
    this.selectedPlanet,
  });
  final String? selectedPlanet;
  final void Function(String path) onPlanetSelected;
  final void Function(XFile file) onPhotoSelected;

  @override
  State<_PhotoPickerSheet> createState() => _PhotoPickerSheetState();
}

class _PhotoPickerSheetState extends State<_PhotoPickerSheet> {
  late String? _current;
  final _picker = ImagePicker();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _current = widget.selectedPlanet;
  }

  Future<void> _takePhoto() async {
    setState(() => _loading = true);
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 600,
        maxHeight: 600,
      );
      if (file != null && mounted) widget.onPhotoSelected(file);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _chooseFromLibrary() async {
    setState(() => _loading = true);
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 600,
        maxHeight: 600,
      );
      if (file != null && mounted) widget.onPhotoSelected(file);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 80,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // ── Title section (height ~69px) ──────────────────────────
          SizedBox(
            height: 69,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Choose a planet', style: AppTextStyles.headerTitle),
                  const SizedBox(height: 4),
                  Text(
                    'Or upload your own photo',
                    style: AppTextStyles.labelRegular14.copyWith(
                      color: AppColors.cardBorder,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Planet grid (4×2, height 184px) ──────────────────────
          SizedBox(
            height: 184,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(31, 0, 31, 0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                ),
                itemCount: _kPlanets.length,
                itemBuilder: (context, i) {
                  final path = _kPlanets[i];
                  final isSelected = _current == path;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _current = path);
                      Future.delayed(
                        const Duration(milliseconds: 120),
                        () => widget.onPlanetSelected(path),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.textSecondary
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(path, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Action buttons ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              15,
              8,
              15,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child:
                _loading
                    ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: CircularProgressIndicator(
                        color: AppColors.textPrimary,
                        strokeWidth: 2,
                      ),
                    )
                    : Column(
                      children: [
                        _GhostButton(label: 'Take a photo', onTap: _takePhoto),
                        const SizedBox(height: 8),
                        _GhostButton(
                          label: 'Choose from library',
                          onTap: _chooseFromLibrary,
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium16.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Labeled Inputs ───────────────────────────────────────────────────────────

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.controller,
    this.hint = '',
  });
  final String label;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.tagLabel),
        const SizedBox(height: 8),
        _InputBox(
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyRegular14.copyWith(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyRegular14.copyWith(
                fontSize: 14,
                color: AppColors.textPrimary.withValues(alpha: 0.35),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledBirthdayInput extends StatefulWidget {
  const _LabeledBirthdayInput({required this.controller});
  final TextEditingController controller;

  @override
  State<_LabeledBirthdayInput> createState() => _LabeledBirthdayInputState();
}

class _LabeledBirthdayInputState extends State<_LabeledBirthdayInput> {
  DateTime? _picked;

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

  void _showPicker() {
    final now = DateTime.now();
    var tempDate = _picked ?? DateTime(now.year - 25, now.month, now.day);

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
                // ── Toolbar ────────────────────────────────────────────
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
                      Text('Birthday', style: AppTextStyles.headerTitle),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _picked = tempDate;
                            widget.controller.text =
                                '${_months[tempDate.month - 1]} ${tempDate.day}';
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
                // ── Cupertino spinner ───────────────────────────────────
                SizedBox(
                  height: 216,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: tempDate,
                    maximumDate: now,
                    minimumYear: 1900,
                    onDateTimeChanged: (d) => tempDate = d,
                  ),
                ),
                SizedBox(height: MediaQuery.of(ctx).padding.bottom),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = _picked != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Birthday (optional)', style: AppTextStyles.tagLabel),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showPicker,
          child: _InputBox(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Text(
                      hasDate ? widget.controller.text : 'DD / MM',
                      style: AppTextStyles.bodyRegular14.copyWith(
                        fontSize: 14,
                        color:
                            hasDate
                                ? AppColors.textPrimary
                                : AppColors.textPrimary.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CustomPaint(
                    size: const Size(19, 20),
                    painter: _CalendarIconPainter(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.63),
      ),
      child: child,
    );
  }
}

class _CalendarIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.cardBorder
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.17, size.width, size.height * 0.80),
        const Radius.circular(3),
      ),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.26, 0),
      Offset(size.width * 0.26, size.height * 0.30),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.74, 0),
      Offset(size.width * 0.74, size.height * 0.30),
      paint,
    );

    final dot =
        Paint()
          ..color = AppColors.cardBorder
          ..style = PaintingStyle.fill;
    for (var r = 0; r < 2; r++) {
      for (var c = 0; c < 3; c++) {
        canvas.drawCircle(
          Offset(
            size.width * (0.20 + c * 0.30),
            size.height * (0.63 + r * 0.22),
          ),
          1.5,
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CalendarIconPainter old) => false;
}

// ─── Step 2: Which orbit? ─────────────────────────────────────────────────────

class _Step2 extends StatefulWidget {
  const _Step2({this.onOrbitChanged});
  final ValueChanged<int>? onOrbitChanged;

  @override
  State<_Step2> createState() => _Step2State();
}

class _Step2State extends State<_Step2> {
  int _selected = 0; // Inner Circle selected by default

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
        Text('Which orbit?', style: AppTextStyles.headerTitle),
        const SizedBox(height: 4),
        Text(
          'How often do you want to connect?',
          style: AppTextStyles.bodyRegular14.copyWith(
            color: AppColors.textSecondary,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color:
                    sel
                        ? AppColors.orange.withValues(alpha: 0.10)
                        : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: sel ? AppColors.orange : AppColors.divider,
                  width: sel ? 2.0 : 0.63,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.name, style: AppTextStyles.headerTitle),
                  const SizedBox(height: 4),
                  Text(
                    o.freq,
                    style: AppTextStyles.bodyRegular14.copyWith(
                      fontSize: 14,
                      color:
                          sel ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    o.desc,
                    style: AppTextStyles.labelRegular14.copyWith(
                      fontSize: 12,
                      color: AppColors.cardBorder,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Step 3: When did you last connect? ──────────────────────────────────────

class _Step3 extends StatefulWidget {
  const _Step3({this.onDateChanged});
  final ValueChanged<DateTime?>? onDateChanged;

  @override
  State<_Step3> createState() => _Step3State();
}

class _Step3State extends State<_Step3> {
  int? _selected; // index into _options, null = none
  DateTime? _exactDate;

  static const _options = ['Today', 'This week', 'This month', 'Longer ago'];
  // Days to subtract from now for each quick-pick option
  static const _optionDays = [0, 3, 15, 60];

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

  void _showExactDatePicker() {
    final now = DateTime.now();
    var temp = _exactDate ?? now;

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
                          setState(() {
                            _exactDate = temp;
                            _selected = null;
                          });
                          Navigator.pop(ctx);
                          widget.onDateChanged?.call(temp);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('When did you last connect?', style: AppTextStyles.headerTitle),
        const SizedBox(height: 4),
        Text(
          "We'll use this to set your first reminder",
          style: AppTextStyles.bodyRegular14.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        // Quick-pick chips
        ...List.generate(_options.length, (i) {
          final sel = _selected == i;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selected = i;
                _exactDate = null;
              });
              widget.onDateChanged?.call(
                DateTime.now().subtract(Duration(days: _optionDays[i])),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              height: 60,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color:
                    sel
                        ? AppColors.orange.withValues(alpha: 0.08)
                        : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? AppColors.orange : AppColors.divider,
                  width: sel ? 2.0 : 1.0,
                ),
              ),
              child: Center(
                child: Text(
                  _options[i],
                  style: AppTextStyles.bodyMedium16.copyWith(
                    color:
                        sel ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
        // "Pick exact date" input
        GestureDetector(
          onTap: _showExactDatePicker,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _exactDate != null
                      ? '${_months[_exactDate!.month - 1]} ${_exactDate!.day}, ${_exactDate!.year}'
                      : 'Pick exact date',
                  style: AppTextStyles.bodyRegular14.copyWith(
                    fontSize: 14,
                    color:
                        _exactDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary.withValues(alpha: 0.75),
                  ),
                ),
                CustomPaint(
                  size: const Size(19, 20),
                  painter: _CalendarIconPainter(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Continue / Done Button ───────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.label,
    required this.onTap,
    this.showCheck = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomPad),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 30,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTextStyles.logButtonLabel),
                if (showCheck) ...[
                  const SizedBox(width: 10),
                  CustomPaint(
                    size: const Size(18, 18),
                    painter: _CheckIconPainter(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.white
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
    final path =
        Path()
          ..moveTo(size.width * 0.17, size.height * 0.50)
          ..lineTo(size.width * 0.42, size.height * 0.75)
          ..lineTo(size.width * 0.83, size.height * 0.25);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckIconPainter old) => false;
}
