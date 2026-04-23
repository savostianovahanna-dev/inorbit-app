import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/home/home_bloc.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../domain/entities/friend.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/screens/login_screen.dart';
import 'edit_profile_screen.dart';

/// The content shown when the Settings tab is active.
/// Embedded inside HomeScreen's Expanded area so the bottom nav stays visible.
/// Figma: node 60-8000
class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return BlocProvider<SettingsBloc>(
      create: (_) => getIt<SettingsBloc>()..add(const SettingsStarted()),
      child: BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (ctx, state) {
          if (state.status == SettingsStatus.loggedOut) {
            Navigator.of(ctx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          } else if (state.status == SettingsStatus.error) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomPad),
          child: Builder(
            builder: (context) {
              final settingsState = context.watch<SettingsBloc>().state;
              final friends = switch (context.watch<HomeBloc>().state) {
                HomeLoaded(:final friends) => friends,
                _ => <Friend>[],
              };

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Page header ──────────────────────────────────────────────
                  SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Settings', style: AppTextStyles.headerTitle),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Profile card ─────────────────────────────────────────────
                  _ProfileCard(
                    friendCount: friends.length,
                    localAvatarPath: settingsState.localAvatarPath,
                  ),
                  const SizedBox(height: 24),

                  // ── Notifications ────────────────────────────────────────────
                  const _SectionLabel('Notifications'),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    children: [
                      _ToggleRow(
                        title: 'Reminders & nudges',
                        subtitle: "Get reminded when it's time to connect",
                        value: settingsState.reminders,
                        onChanged:
                            (v) => context.read<SettingsBloc>().add(
                              SettingsRemindersToggled(v),
                            ),
                      ),
                      const _RowDivider(),
                      _ToggleRow(
                        title: 'Birthday reminders',
                        subtitle: '7-day hint & a reminder on the day',
                        value: settingsState.birthdays,
                        onChanged:
                            (v) => context.read<SettingsBloc>().add(
                              SettingsBirthdaysToggled(v, friends),
                            ),
                      ),
                      // const _RowDivider(),
                      // const _ValueRow(
                      //   title: 'Reminder time',
                      //   subtitle: 'When daily nudges arrive',
                      //   value: '9:00 AM (orbit), 12:00 PM (birthdays)',
                      // ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Data & Privacy ───────────────────────────────────────────
                  const _SectionLabel('Data & Privacy'),
                  const SizedBox(height: 12),
                  const _SettingsCard(
                    children: [_ValueRow(title: 'Privacy policy')],
                  ),
                  const SizedBox(height: 32),

                  // ── Bottom: version + log out + delete ───────────────────────
                  const _BottomSection(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Profile card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.friendCount,
    required this.localAvatarPath,
  });

  final int friendCount;
  final String? localAvatarPath;

  void _openEditProfile(BuildContext context, String name) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(initialName: name)),
    ).then((changed) {
      if (changed == true && context.mounted) {
        context.read<SettingsBloc>().add(const SettingsProfileRefreshed());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'You';
    final googlePhotoUrl = user?.photoURL;
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final orbitLabel =
        friendCount == 1 ? '1 person in orbit' : '$friendCount people in orbit';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ── Avatar circle ──────────────────────────────────────────────────
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 1.9),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildAvatar(localAvatarPath, googlePhotoUrl, initial),
          ),
          const SizedBox(width: 12),

          // ── Name + people count ────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: AppTextStyles.headerTitle),
                const SizedBox(height: 2),
                Text(
                  orbitLabel,
                  style: AppTextStyles.labelRegular14.copyWith(
                    color: const Color(0xFFAEAEB2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Edit chevron ───────────────────────────────────────────────────
          GestureDetector(
            onTap: () => _openEditProfile(context, name),
            child: CustomPaint(
              size: const Size(16, 16),
              painter: _ChevronRightPainter(),
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
    if (localPath != null && File(localPath).existsSync()) {
      return Image.file(File(localPath), fit: BoxFit.cover);
    }
    if (googlePhotoUrl != null) {
      return CachedNetworkImage(
        imageUrl: googlePhotoUrl,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _avatarPlaceholder(initial),
      );
    }
    return _avatarPlaceholder(initial);
  }

  Widget _avatarPlaceholder(String initial) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.headerTitle.copyWith(
            color: AppColors.textSecondary,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelRegular14.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Settings card (container for rows) ──────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

// ─── Hairline divider between rows ───────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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

  Future<bool> _confirmDeleteAccount(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Delete account?'),
                content: const Text(
                  'This will permanently delete your account and all your data. This cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<SettingsBloc>().state.status == SettingsStatus.loading;

    return Column(
      children: [
        Text(
          'InOrbit v1.0.0',
          style: AppTextStyles.labelRegular14.copyWith(
            color: AppColors.cardBorder,
          ),
        ),
        const SizedBox(height: 12),

        // Log Out ghost button
        GestureDetector(
          onTap:
              isLoading
                  ? null
                  : () => context.read<SettingsBloc>().add(
                    const SettingsLogOutRequested(),
                  ),
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
              child:
                  isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(
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
        GestureDetector(
          onTap:
              isLoading
                  ? null
                  : () async {
                    final confirmed = await _confirmDeleteAccount(context);
                    if (confirmed && context.mounted) {
                      context.read<SettingsBloc>().add(
                        const SettingsDeleteAccountRequested(),
                      );
                    }
                  },
          child: Text(
            'Delete account',
            style: AppTextStyles.labelRegular14.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.cardBorder,
            ),
          ),
        ),
      ],
    );
  }
}
