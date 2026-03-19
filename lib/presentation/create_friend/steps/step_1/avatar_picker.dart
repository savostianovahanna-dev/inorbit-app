import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inorbit/core/theme/app_colors.dart';
import 'package:inorbit/core/theme/app_text_styles.dart';
import 'package:inorbit/shared/widgets/ghost_button.dart';

const kPlanets = [
  'assets/images/planets/planet_1.png',
  'assets/images/planets/planet_2.png',
  'assets/images/planets/planet_3.png',
  'assets/images/planets/planet_4.png',
  'assets/images/planets/planet_5.png',
  'assets/images/planets/planet_6.png',
  'assets/images/planets/planet_7.png',
  'assets/images/planets/planet_8.png',
];

class AvatarPicker extends StatefulWidget {
  const AvatarPicker({
    super.key,
    this.onPlanetIndexChanged,
    this.onAvatarPathChanged,
    this.initialPlanetIndex,
    this.initialAvatarPath,
  });

  final ValueChanged<int?>? onPlanetIndexChanged;
  final ValueChanged<String?>? onAvatarPathChanged;
  final int? initialPlanetIndex;
  final String? initialAvatarPath;

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  String? _selectedPlanet;
  XFile? _pickedFile;
  String? _customPath; // for pre-filled file-path avatars (edit flow)

  @override
  void initState() {
    super.initState();
    if (widget.initialPlanetIndex != null) {
      final idx = widget.initialPlanetIndex!;
      if (idx >= 0 && idx < kPlanets.length) {
        _selectedPlanet = kPlanets[idx];
      }
    } else if (widget.initialAvatarPath != null) {
      _customPath = widget.initialAvatarPath;
    }
  }

  bool get _hasPhoto =>
      _selectedPlanet != null || _pickedFile != null || _customPath != null;

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
                _customPath = null;
              });
              final index = int.tryParse(path.split('_').last.split('.').first);
              widget.onPlanetIndexChanged?.call(index);
              widget.onAvatarPathChanged?.call(null);
              Navigator.pop(context);
            },
            onPhotoSelected: (file) {
              setState(() {
                _pickedFile = file;
                _selectedPlanet = null;
                _customPath = null;
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
    if (_customPath != null) {
      return Image.file(
        File(_customPath!),
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (_, __, ___) => Center(
          child: CustomPaint(
            size: const Size(44, 44),
            painter: _CameraIconPainter(),
          ),
        ),
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

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.27, size.width, size.height * 0.67),
        const Radius.circular(5),
      ),
      strokePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.61),
      size.width * 0.20,
      strokePaint,
    );
    final bump =
        Path()
          ..moveTo(size.width * 0.30, size.height * 0.27)
          ..lineTo(size.width * 0.38, size.height * 0.16)
          ..lineTo(size.width * 0.62, size.height * 0.16)
          ..lineTo(size.width * 0.70, size.height * 0.27);
    canvas.drawPath(bump, strokePaint);
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            SizedBox(
              height: 184,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(31, 0, 31, 0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 16,
                      ),
                  itemCount: kPlanets.length,
                  itemBuilder: (context, i) {
                    final path = kPlanets[i];
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
                          GhostButton(
                            label: 'Take a photo',
                            onTap: _takePhoto,
                          ),
                          const SizedBox(height: 8),
                          GhostButton(
                            label: 'Choose from library',
                            onTap: _chooseFromLibrary,
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
