import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inorbit/core/shared/shared_icons.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../home/screens/home_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';

/// Login screen — Figma node 40-1669.
/// Dark (#181B21) background with main photo, orbit rings SVG,
/// InOrbit logo, tagline, and two auth buttons.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // If user is already signed in, skip login and go straight to HomeScreen.
    if (FirebaseAuth.instance.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      });
    }
  }

  Future<void> _handleAuth(Future<UserCredential?> Function() authFn) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final cred = await authFn();
      if (cred == null || !mounted) return; // user cancelled
      final isNew = cred.additionalUserInfo?.isNewUser ?? false;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => isNew ? const OnboardingScreen() : const HomeScreen(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF181B21),
      body: Stack(
        children: [
          // ── Main photo (bleeds past top, rounded bottom) ──────────────────
          Positioned(
            top: -42,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 676,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset('assets/onboarding1.png', fit: BoxFit.cover),
              ),
            ),
          ),

          // ── Gradient overlay: photo fades into dark bg ────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.28, 0.58],
                  colors: [Colors.transparent, Color(0xFF181B21)],
                ),
              ),
            ),
          ),

          // ── Orbit rings SVG (decorative, offset to the left) ─────────────
          Positioned(
            left: -59,
            top: 0,
            child: SvgPicture.asset(
              'assets/orbits.svg',
              width: 507.5,
              height: 532.59,
            ),
          ),

          // ── Foreground content ────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Flex space above logo — keeps logo at ~28% from top on any screen
                const Spacer(flex: 5),

                // InOrbit logo with orbit rings + title text
                SvgPicture.asset('assets/login_with_title.svg', width: 210),

                // Flex space between logo and tagline (~18% of available height)
                const Spacer(flex: 4),

                // Tagline (~y=481 in Figma frame)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Stay close to the people\nwho matter most',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium16.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: -0.80,
                      height: 1.2,
                    ),
                  ),
                ),

                // Flex space between tagline and buttons
                const Spacer(flex: 2),

                // ── Buttons + terms (~y=620 in Figma frame) ──────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _AuthButton(
                        iconPath: SharedIcons.google,
                        label: 'Continue with Google',
                        loading: _loading,
                        onTap:
                            () => _handleAuth(
                              () => getIt<AuthService>().signInWithGoogle(),
                            ),
                      ),
                      const SizedBox(height: 26),

                      // Terms of Service line
                      Text(
                        'Terms of Service and Privacy',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelRegular14.copyWith(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 0.5,
                          height: 1.5,
                        ),
                      ),

                      // Home indicator space
                      SizedBox(height: 34 + bottomPad),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Auth button ──────────────────────────────────────────────────────────────
/// Full-width button with button_background.png texture + dark overlay.

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final String iconPath;
  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background texture image
              Positioned.fill(
                child: Image.asset(
                  'assets/button_background.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Dark semi-transparent overlay: rgba(17,17,17,0.75)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xFF111111).withValues(alpha: 0.75),
                ),
              ),

              // Icon + label row (centred), or spinner while loading
              if (loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(iconPath, width: 20, height: 20),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: AppTextStyles.bodyMedium16.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
