import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/home/home_bloc.dart';
import '../../../domain/entities/friend.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/screens/login_screen.dart';
import 'edit_profile_screen.dart';

/// The content shown when the Settings tab is active.
/// Embedded inside HomeScreen's Expanded area so the bottom nav stays visible.
/// Figma: node 60-8000
class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  // Toggle states
  bool _reminders = true;
  bool _birthdays = true;
  bool _countMessages = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final data = await getIt<UserProfileService>().load(uid);
    if (data == null || !mounted) return;
    final s = (data['settings'] as Map<String, dynamic>?) ?? {};
    setState(() {
      _reminders = s['reminders'] as bool? ?? true;
      _birthdays = s['birthdays'] as bool? ?? true;
      _countMessages = s['countMessages'] as bool? ?? false;
    });
    // Keep in-memory cache in sync.
    getIt<UserProfileService>().birthdaysEnabled = _birthdays;
  }

  /// Called when the birthday-reminder toggle is flipped.
  /// Requests notification permission on first enable, then reschedules.
  Future<void> _onBirthdaysToggled(bool enabled) async {
    // Keep the in-memory cache up to date for HomeScreen's listener.
    getIt<UserProfileService>().birthdaysEnabled = enabled;

    // Capture friends list BEFORE any await so we don't use BuildContext
    // across an async gap.
    final friends = switch (context.read<HomeBloc>().state) {
      HomeLoaded(:final friends) => friends,
      _ => <Friend>[],
    };

    if (enabled) {
      // Ask iOS for permission if we don't have it yet.
      await getIt<NotificationService>().requestPermissions();
    }

    // Reschedule (or cancel) using the current friends list.
    await getIt<NotificationService>().scheduleBirthdayReminders(
      friends,
      globalEnabled: enabled,
    );
  }

  void _saveSettings() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    getIt<UserProfileService>().save(uid, {
      'settings': {
        'reminders': _reminders,
        'birthdays': _birthdays,
        'countMessages': _countMessages,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page header ──────────────────────────────────────────────────────
          SizedBox(
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Settings', style: AppTextStyles.headerTitle),
            ),
          ),
          const SizedBox(height: 20),

          // ── Profile card ─────────────────────────────────────────────────────
          _ProfileCard(
            friendCount: switch (context.watch<HomeBloc>().state) {
              HomeLoaded(:final friends) => friends.length,
              _ => 0,
            },
          ),
          const SizedBox(height: 24),

          // ── Notifications ────────────────────────────────────────────────────
          const _SectionLabel('Notifications'),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _ToggleRow(
                title: 'Reminders & nudges',
                subtitle: "Get reminded when it's time to connect",
                value: _reminders,
                onChanged: (v) {
                  setState(() => _reminders = v);
                  _saveSettings();
                },
              ),
              const _RowDivider(),
              _ToggleRow(
                title: 'Birthday reminders',
                subtitle: 'A quiet reminder the day before',
                value: _birthdays,
                onChanged: (v) {
                  setState(() => _birthdays = v);
                  _saveSettings();
                  _onBirthdaysToggled(v);
                },
              ),
              const _RowDivider(),
              const _ValueRow(
                title: 'Reminder time',
                subtitle: 'When daily nudges arrive',
                value: '9:00 AM',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Preferences ──────────────────────────────────────────────────────
          const _SectionLabel('Preferences'),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              const _ValueRow(
                title: 'Default contact frequency',
                value: 'Monthly',
              ),
              const _RowDivider(),
              _ToggleRow(
                title: 'Count messages as contact',
                subtitle: 'Include texts and DMs in your history',
                value: _countMessages,
                onChanged: (v) {
                  setState(() => _countMessages = v);
                  _saveSettings();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Data & Privacy ───────────────────────────────────────────────────
          const _SectionLabel('Data & Privacy'),
          const SizedBox(height: 12),
          const _SettingsCard(children: [_ValueRow(title: 'Privacy policy')]),
          const SizedBox(height: 32),

          // ── Bottom: version + log out + delete ───────────────────────────────
          const _BottomSection(),
        ],
      ),
    );
  }
}

// ─── Profile card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatefulWidget {
  const _ProfileCard({required this.friendCount});

  final int friendCount;

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  void _openEditProfile(String name) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(initialName: name),
      ),
    ).then((changed) {
      // Rebuild to pick up the updated displayName + localAvatarPath.
      if (changed == true && mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'You';
    final googlePhotoUrl = user?.photoURL;
    final localPath = getIt<UserProfileService>().localAvatarPath;
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final orbitLabel = widget.friendCount == 1
        ? '1 person in orbit'
        : '${widget.friendCount} people in orbit';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ── Avatar circle ─────────────────────────────────────────────────
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 1.9),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildAvatar(localPath, googlePhotoUrl, initial),
          ),
          const SizedBox(width: 12),

          // ── Name + people count ───────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: AppTextStyles.headerTitle),
                const SizedBox(height: 3),
                Text(
                  orbitLabel,
                  style: AppTextStyles.settingsRowSubtitle.copyWith(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ── Edit profile link ─────────────────────────────────────────────
          GestureDetector(
            onTap: () => _openEditProfile(name),
            child: Text(
              'Edit profile',
              style: AppTextStyles.labelRegular14.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    String? localPath,
    String? googlePhotoUrl,
    String initial,
  ) {
    // 1. Locally picked photo (set after editing profile).
    if (localPath != null) {
      return Image.file(File(localPath), fit: BoxFit.cover);
    }
    // 2. Google account photo.
    if (googlePhotoUrl != null) {
      return CachedNetworkImage(
        imageUrl: googlePhotoUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => _AvatarFallback(initial: initial),
        errorWidget: (_, __, ___) => _AvatarFallback(initial: initial),
      );
    }
    // 3. Gradient + initial.
    return _AvatarFallback(initial: initial);
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initial});

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
          style: AppTextStyles.bodyMedium16.copyWith(
            color: AppColors.white,
            fontSize: 22,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ─── Section overline label ───────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.bodyMedium16.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.cardBorder,
        letterSpacing: 0.5,
        height: 1.5,
      ),
    );
  }
}

// ─── White rounded card wrapper ───────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ─── Hairline divider between rows ────────────────────────────────────────────

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 0.5, color: AppColors.divider);
  }
}

// ─── Row with a toggle switch ─────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.settingsRowTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTextStyles.settingsRowSubtitle),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          _Toggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─── Row with a value label + chevron ────────────────────────────────────────

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.title, this.subtitle, this.value});

  final String title;
  final String? subtitle;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.settingsRowTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTextStyles.settingsRowSubtitle),
                ],
              ],
            ),
          ),
          if (value != null) ...[
            Text(
              value!,
              style: AppTextStyles.labelRegular14.copyWith(
                fontSize: 14,
                color: AppColors.cardBorder,
              ),
            ),
            const SizedBox(width: 4),
          ],
          // Chevron >
          CustomPaint(
            size: const Size(16, 16),
            painter: _ChevronRightPainter(),
          ),
        ],
      ),
    );
  }
}

// ─── Toggle switch ────────────────────────────────────────────────────────────

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 51,
        height: 31,
        decoration: BoxDecoration(
          // ON: #334155 (textSecondary), OFF: #E2E8F0 (divider)
          color: value ? AppColors.textSecondary : AppColors.divider,
          borderRadius: BorderRadius.circular(100),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Chevron-right icon ───────────────────────────────────────────────────────

class _ChevronRightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.cardBorder
          ..strokeWidth = 1.33
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

    final path =
        Path()
          ..moveTo(size.width * 0.36, size.height * 0.22)
          ..lineTo(size.width * 0.64, size.height * 0.50)
          ..lineTo(size.width * 0.36, size.height * 0.78);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronRightPainter old) => false;
}

// ─── Bottom section: version + log out + delete ───────────────────────────────

class _BottomSection extends StatelessWidget {
  const _BottomSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Version label
        Text(
          'InOrbit v1.0.0',
          style: AppTextStyles.labelRegular14.copyWith(
            color: AppColors.cardBorder,
          ),
        ),
        const SizedBox(height: 12),

        // Log Out ghost button
        GestureDetector(
          onTap: () async {
            await getIt<AuthService>().signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false, // clear entire stack
              );
            }
          },
          child: Container(
            width: double.infinity,
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
                'Log Out',
                style: AppTextStyles.bodyMedium16.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Delete account
        Text(
          'Delete account',
          style: AppTextStyles.labelRegular14.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.cardBorder,
          ),
        ),
      ],
    );
  }
}
