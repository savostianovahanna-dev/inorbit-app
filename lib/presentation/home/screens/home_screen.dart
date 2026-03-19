import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/usecases/sync_data.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';
import '../../../bloc/home/home_bloc.dart';
import '../../create_friend/screens/add_friend_screen.dart';
import '../../friend/screens/friend_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/friends_scroll_row.dart';
import '../widgets/orbit_widget.dart';

// ─── Root screen ──────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  NavTab _activeTab = NavTab.orbit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Sync from Firebase every time the app comes back to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        getIt.isRegistered<SyncData>()) {
      getIt<SyncData>().call().catchError((Object e) {
        debugPrint('Resume sync failed: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // BlocProvider lives above the Scaffold so the bloc survives tab switches.
    return BlocProvider<HomeBloc>(
      create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: switch (_activeTab) {
                  NavTab.settings => const SettingsContent(),
                  NavTab.stats => const StatsContent(),
                  NavTab.orbit => const _OrbitTab(),
                },
              ),
              HomeBottomNavBar(
                activeTab: _activeTab,
                onTabChanged: (tab) => setState(() => _activeTab = tab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Orbit tab ────────────────────────────────────────────────────────────────

class _OrbitTab extends StatelessWidget {
  const _OrbitTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder:
          (context, state) => switch (state) {
            HomeInitial() || HomeLoading() => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            HomeError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyRegular14,
                ),
              ),
            ),
            HomeLoaded(:final friends) => _LoadedView(friends: friends),
            // TODO: Handle this case.
            HomeState() => throw UnimplementedError(),
          },
    );
  }
}

// ─── Loaded view ──────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.friends});

  final List<Friend> friends;

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) return _EmptyOrbitView();

    final overdueCount = friends.where((f) => f.isOverdue).length;

    // Friends are ordered by overdue score — first entry is the most overdue.
    final mostOverdue =
        friends.isNotEmpty && friends.first.isOverdue ? friends.first : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: HomeAppBar(
              onAddFriend:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddFriendScreen()),
                  ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Orbit visualization ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OrbitWidget(
              friends: friends,
              userInitials: 'You',
              onFriendTap: (friend) => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FriendScreen(friend: friend)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Subtitle ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _subtitle(friends.length, overdueCount),
              style: AppTextStyles.bodyRegular14.copyWith(
                fontSize: 12,
                color: const Color(0xFFAEAEB2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Friends horizontal scroll ─────────────────────────────────────
          FriendsScrollRow(
            friends: friends,
            onFriendTap:
                (friend) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FriendScreen(friend: friend),
                  ),
                ),
          ),

          // ── Attention card (most overdue friend only) ─────────────────────
          if (mostOverdue != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: _AttentionCard(friend: mostOverdue),
            ),
          ] else
            const SizedBox(height: 24),
        ],
      ),
    );
  }

  static String _subtitle(int total, int overdue) {
    final people = total == 1 ? '1 person' : '$total people';
    if (overdue == 0) return people;
    final attn = overdue == 1 ? '1 needs attention' : '$overdue need attention';
    return '$people · $attn';
  }
}

// ─── Empty orbit view ─────────────────────────────────────────────────────────

class _EmptyOrbitView extends StatelessWidget {
  const _EmptyOrbitView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: HomeAppBar(
              onAddFriend:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddFriendScreen()),
                  ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Orbit visualization ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OrbitWidget(friends: const [], userInitials: 'You'),
          ),
          const SizedBox(height: 16),

          // ── Empty state card ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Your orbit is empty',
                    style: AppTextStyles.bodyMedium16.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add the people you want\nto stay close to',
                    style: AppTextStyles.bodyRegular14.copyWith(
                      color: const Color(0xFFAEAEB2),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddFriendScreen(),
                            ),
                          ),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Add your first person',
                        style: AppTextStyles.bodyMedium16.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Attention card ───────────────────────────────────────────────────────────

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: AppTextStyles.bodyMedium16,
              children: [
                const TextSpan(text: '✨  '),
                TextSpan(
                  text: friend.name,
                  style: AppTextStyles.bodyMedium16.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            'A simple hello is enough to keep the connection alive.',
            style: AppTextStyles.bodyRegular14,
          ),
        ],
      ),
    );
  }
}
