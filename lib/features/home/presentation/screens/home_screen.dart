import 'package:flutter/material.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/orbit_visualization.dart';
import '../widgets/connection_card.dart';
import '../widgets/connect_button.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../friend/presentation/screens/friend_screen.dart';
import '../../../create_friend/presentation/screens/add_friend_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NavTab _activeTab = NavTab.orbit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row + add friend button
                    HomeAppBar(
                      onAddFriend: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddFriendScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Orbit network visualization
                    OrbitVisualization(
                      onHmTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FriendScreen(name: 'Hannah M.'),
                        ),
                      ),
                      onAkTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FriendScreen(name: 'Anna Kallin'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // People subtitle
                    Text(
                      '4 people · 1 need attention',
                      style: AppTextStyles.bodyRegular16.copyWith(
                        height: 2.25,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Connection alert card
                    const ConnectionCard(
                      name: 'Anna K.',
                      daysAgo: '47 days ago',
                      message:
                          'A simple hello is enough to keep the connection alive.',
                    ),
                    const SizedBox(height: 12),

                    // CTA button
                    const ConnectButton(),
                  ],
                ),
              ),
            ),

            // Bottom navigation (outside scroll, sticks to bottom)
            HomeBottomNavBar(
              activeTab: _activeTab,
              onTabChanged: (tab) => setState(() => _activeTab = tab),
            ),
          ],
        ),
      ),
    );
  }
}
