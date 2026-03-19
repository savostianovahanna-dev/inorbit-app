import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/image_background_button.dart';
import '../../home/screens/home_screen.dart';

// ─── Page data ────────────────────────────────────────────────────────────────

const _kPages = [
  (
    image: 'assets/onboarding1.png',
    title: 'Your circle is your gravity',
    subtitle:
        'InOrbit helps you maintain the pull of your most important connections.',
  ),
  (
    image: 'assets/onboarding2.png',
    title: 'Out of sight,\nnot out of mind.',
    subtitle:
        "See who's drifting away from your orbit and reach out before the connection fades.",
  ),
  (
    image: 'assets/onboaring3.png', // intentional typo matches asset filename
    title: 'Start building\nyour orbit.',
    subtitle:
        'Add friends, log moments, and let InOrbit help you nurture the connections that matter.',
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

/// 3-page swipeable onboarding. All pages share the same visual design
/// (dark #222222 bg, gradient, textured button) — only image & text differ.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  void _goHome() => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

  void _next() {
    if (_page < _kPages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goHome();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final page = _kPages[_page];

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // ── Full-screen swipeable photos ────────────────────────────────
          PageView.builder(
            controller: _controller,
            itemCount: _kPages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => SizedBox.expand(
              child: Image.asset(_kPages[i].image, fit: BoxFit.cover),
            ),
          ),

          // ── Photo → dark background gradient ───────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.28, 0.56],
                    colors: [Colors.transparent, Color(0xFF000000)],
                  ),
                ),
              ),
            ),
          ),

          // ── Skip (top-right, white 75%) ─────────────────────────────────
          Positioned(
            top: topPad + 8,
            right: 16,
            child: GestureDetector(
              onTap: _goHome,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  'Skip',
                  style: AppTextStyles.labelRegular14.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom: white card + button ─────────────────────────────────
          Positioned(
            bottom: 30,
            left: 3,
            right: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // White content card (r=32, padding=24, gap=16)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium16.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF000000),
                          letterSpacing: -0.80,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      SizedBox(
                        width: 270,
                        child: Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyRegular14.copyWith(
                            fontSize: 14,
                            color: const Color(0xFF111111).withValues(alpha: 0.50),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Progress dots
                      _ProgressDots(count: _kPages.length, active: _page),
                    ],
                  ),
                ),

                const SizedBox(height: 11),

                // Get Started button
                ImageBackgroundButton(label: 'Get Started', onTap: _next),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress dots ────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 141,
      child: Row(
        children: List.generate(count, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              margin: i < count - 1 ? const EdgeInsets.only(right: 8) : null,
              decoration: BoxDecoration(
                color: i == active
                    ? const Color(0xFF111111)
                    : const Color(0xFF111111).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

