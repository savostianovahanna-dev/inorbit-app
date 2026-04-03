import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/ghost_button.dart';

/// Figma: node 65-6762 "Edit profile"
/// Opened from Settings → "Edit profile" tap.
/// Pops with [true] when a save was performed so the caller can refresh.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.initialName = '',
  });

  final String initialName;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;

  /// Locally picked image — overrides Google photo until saved.
  File? _pickedImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    // Pre-fill with any previously picked path (in-memory cache).
    final cached = getIt<UserProfileService>().localAvatarPath;
    if (cached != null) _pickedImage = File(cached);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Photo picker ─────────────────────────────────────────────────────────

  void _openPhotoPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF222222).withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (_) => _ProfilePhotoSheet(
        onPhotoSelected: (file) {
          setState(() => _pickedImage = File(file.path));
        },
      ),
    );
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_saving) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update Firebase Auth display name.
        await user.updateDisplayName(name);

        // Build the Firestore patch.
        final patch = <String, dynamic>{'name': name};
        if (_pickedImage != null) {
          patch['avatarPath'] = _pickedImage!.path;
        }
        await getIt<UserProfileService>().save(user.uid, patch);

        // Update in-memory cache so Settings reflects change immediately.
        if (_pickedImage != null) {
          getIt<UserProfileService>().localAvatarPath = _pickedImage!.path;
        }
      }
    } catch (e) {
      debugPrint('EditProfile save error: $e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        // Pop with true so the Settings screen knows to rebuild.
        Navigator.pop(context, true);
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
    final name = _nameCtrl.text;
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              _EditProfileHeader(onBack: () => Navigator.pop(context)),
              const SizedBox(height: 20),

              // ── Avatar ────────────────────────────────────────────────────
              _AvatarSection(
                pickedImage: _pickedImage,
                googlePhotoUrl: photoUrl,
                initial: initial,
                onTap: _openPhotoPicker,
              ),
              const SizedBox(height: 20),

              // ── Name input ────────────────────────────────────────────────
              _NameInput(controller: _nameCtrl),

              const Spacer(),

              // ── Save button ───────────────────────────────────────────────
              _SaveButton(saving: _saving, onTap: _save),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 0.63),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(8, 13),
                  painter: _BackChevronPainter(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text('Edit Profile', style: AppTextStyles.headerTitle),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _BackChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BackChevronPainter old) => false;
}

// ─── Avatar section ───────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.pickedImage,
    required this.googlePhotoUrl,
    required this.initial,
    required this.onTap,
  });

  final File? pickedImage;
  final String? googlePhotoUrl;
  final String initial;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = pickedImage != null || googlePhotoUrl != null;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: _buildAvatar(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasPhoto ? 'Tap to change photo' : 'Tap to add photo',
            style: AppTextStyles.settingsRowSubtitle,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    // 1. Locally picked image takes highest priority.
    if (pickedImage != null) {
      return Image.file(pickedImage!, fit: BoxFit.cover);
    }
    // 2. Google account photo.
    if (googlePhotoUrl != null) {
      return CachedNetworkImage(
        imageUrl: googlePhotoUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _GradientInitial(initial: initial),
        errorWidget: (_, __, ___) => _GradientInitial(initial: initial),
      );
    }
    // 3. Gradient + initial fallback.
    return _GradientInitial(initial: initial);
  }
}

class _GradientInitial extends StatelessWidget {
  const _GradientInitial({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.avatarFill, AppColors.orbitDark],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 38,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ─── Name input ───────────────────────────────────────────────────────────────

class _NameInput extends StatelessWidget {
  const _NameInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name', style: AppTextStyles.tagLabel),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            // Transparent so the background colour shows through.
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 0.63),
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyRegular14.copyWith(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Your name',
              hintStyle: AppTextStyles.bodyRegular14.copyWith(
                fontSize: 14,
                color: AppColors.textPrimary.withValues(alpha: 0.35),
              ),
              // No fill — keeps the field transparent.
              filled: false,
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

// ─── Save button ──────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onTap, this.saving = false});

  final VoidCallback onTap;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: saving ? null : onTap,
      child: Container(
        width: double.infinity,
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
        child: Center(
          child: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text('Save', style: AppTextStyles.logButtonLabel),
        ),
      ),
    );
  }
}

// ─── Profile photo picker sheet ───────────────────────────────────────────────

/// Simple bottom sheet for picking a profile photo — camera or gallery only.
/// No planet selection (unlike the friend avatar picker).
class _ProfilePhotoSheet extends StatefulWidget {
  const _ProfilePhotoSheet({required this.onPhotoSelected});

  final void Function(XFile file) onPhotoSelected;

  @override
  State<_ProfilePhotoSheet> createState() => _ProfilePhotoSheetState();
}

class _ProfilePhotoSheetState extends State<_ProfilePhotoSheet> {
  final _picker = ImagePicker();
  bool _loading = false;

  Future<void> _pick(ImageSource source) async {
    setState(() => _loading = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 600,
        maxHeight: 600,
      );
      if (file != null && mounted) {
        widget.onPhotoSelected(file);
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

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
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 80,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Profile photo', style: AppTextStyles.headerTitle),
            ),
            // Buttons
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 16 + bottomPad),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(
                        color: AppColors.textPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Column(
                      children: [
                        GhostButton(
                          label: 'Take a photo',
                          onTap: () => _pick(ImageSource.camera),
                        ),
                        const SizedBox(height: 8),
                        GhostButton(
                          label: 'Choose from library',
                          onTap: () => _pick(ImageSource.gallery),
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
