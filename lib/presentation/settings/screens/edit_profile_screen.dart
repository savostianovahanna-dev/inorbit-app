import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Figma: node 65-6762 "Edit profile"
/// Opened from Settings → "Edit profile" tap.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.initialName = 'Elena V.',
  });

  final String initialName;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              _EditProfileHeader(onBack: () => Navigator.pop(context)),
              const SizedBox(height: 20),

              // ── Avatar + tap label ───────────────────────────────────────────
              _AvatarSection(name: _nameCtrl.text),
              const SizedBox(height: 20),

              // ── Name input ───────────────────────────────────────────────────
              _NameInput(controller: _nameCtrl),

              const Spacer(),

              // ── Save button ──────────────────────────────────────────────────
              _SaveButton(onTap: () => Navigator.pop(context)),
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
          // Back button
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

          // Title (centered in remaining space)
          Expanded(
            child: Center(
              child: Text('Edit Profile', style: AppTextStyles.headerTitle),
            ),
          ),

          // Invisible spacer to balance the back button
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
  const _AvatarSection({required this.name});

  final String name;

  String get _initial =>
      name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // 100×100 circle avatar
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.avatarFill, AppColors.orbitDark],
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Center(
              child: Text(
                _initial,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Caption
          Text(
            'Tap to add photo',
            style: AppTextStyles.settingsRowSubtitle,
          ),
        ],
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
        // Label
        Text('Name', style: AppTextStyles.tagLabel),
        const SizedBox(height: 8),

        // Input box
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
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
  const _SaveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          // #0F172A — deep navy from Figma (AppColors.buttonDark)
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
          child: Text(
            'Save',
            style: AppTextStyles.logButtonLabel,
          ),
        ),
      ),
    );
  }
}
