import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/usecases/sync_data.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/friend.dart';
import '../../../bloc/home/home_bloc.dart';
import '../../create_friend/screens/add_friend_screen.dart';
import '../../friend/screens/friend_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../widgets/birthday_notification_card.dart';
// ІМПОРТ ТВОГО BIRTHDAY TODAY WIDGET (замінити на реальне імя!)
// import '../widgets/birthday_today_card.dart';  ← ТИ ПОВИНЕН ЗНАТИ ЯК ВІН НАЗИВАЄТЬСЯ!
import '../widgets/bottom_nav_bar.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/friend_card.dart';
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
    if (state == AppLifecycleState.resumed && getIt.isRegistered<SyncData>()) {
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
      child: BlocListener<HomeBloc, HomeState>(
        // Reschedule birthday notifications whenever the friends list changes.
        listenWhen: (_, current) => current is HomeLoaded,
        listener: (_, state) {
          if (state is HomeLoaded) {
            final birthdaysEnabled =
                getIt<UserProfileService>().birthdaysEnabled;
            // ЗМІНА: scheduleBirthdayReminders тепер планує ДВА notifications
            getIt<NotificationService>().scheduleBirthdayReminders(
              state.friends,
              globalEnabled: birthdaysEnabled,
            );
            // ЗМІНА: scheduleOrbitReminders тепер планує раз на 2 тижні
            getIt<NotificationService>().scheduleOrbitReminders(state.friends);
          }
        },
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

class _LoadedView extends StatefulWidget {
  const _LoadedView({required this.friends});

  final List<Friend> friends;

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  // НОВЕ: зберігаємо які birthday preview cards були dismissed
  final Set<String> _dismissedBirthdayPreviews = {};

  static const _kCardH = 177.0;

  @override
  Widget build(BuildContext context) {
    if (widget.friends.isEmpty) return const _EmptyOrbitView();

    final overdueCount = widget.friends.where((f) => f.isOverdue).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Orbit takes ~42 % of the available height, never less than 200 px.
        final orbitH = (constraints.maxHeight * 0.42).clamp(
          200.0,
          double.infinity,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: HomeAppBar(
                onAddFriend:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddFriendScreen(),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Orbit (fixed proportion of screen) ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OrbitWidget(
                friends: widget.friends,
                userInitials: 'You',
                height: orbitH,
                onFriendTap:
                    (friend) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FriendScreen(friend: friend),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Subtitle ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _subtitle(widget.friends.length, overdueCount),
                style: AppTextStyles.bodyRegular14.copyWith(
                  fontSize: 12,
                  color: const Color(0xFFAEAEB2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Friends list: birthday card(s) + 2-column grid ────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // НОВЕ: Birthday preview cards (за 7 днів)
                  // - БЕЗ birthday sticker
                  // - Можна закрити (X кнопка)
                  // - Зберігаємо які cards були dismissed
                  ..._upcomingBirthdayPreviews(widget.friends)
                      .where(
                        (entry) =>
                            !_dismissedBirthdayPreviews.contains(entry.$1.id),
                      )
                      .map(
                        (entry) => SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          sliver: SliverToBoxAdapter(
                            child: _BirthdayPreviewCard(
                              friend: entry.$1,
                              daysUntil: entry.$2,
                              onDismiss: () {
                                setState(() {
                                  _dismissedBirthdayPreviews.add(entry.$1.id);
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                  // НОВЕ: Birthday today card (день в день)
                  // Використовуємо ТВІЙ ВЛАСНИЙ ВІДЖЕТ замість мого!
                  //
                  // ЗАМІНИТИ НА ТВІЙ КОМПОНЕНТ ЯКЩО ПОТРІБНО
                  // Проста логіка: якщо у друга день народження сьогодні
                  // Показуємо твій вже зроблений віджет
                  ..._birthdayToday(widget.friends).map(
                    (friend) => SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      sliver: SliverToBoxAdapter(
                        // ЗАМІНИТИ на твій віджет!
                        // Наприклад: BirthdayNotificationCard або твій custom widget
                        child: BirthdayNotificationCard(
                          friend: friend,
                          daysUntil: 0, // Сьогодні = 0 днів
                        ),
                      ),
                    ),
                  ),

                  // Friends grid
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: _kCardH,
                          ),
                      itemCount: widget.friends.length,
                      itemBuilder: (context, index) {
                        final friend = widget.friends[index];
                        return FriendCard(
                          friend: friend,
                          lastMeetingType: null,
                          daysSinceContact:
                              friend.lastConnectedAt != null
                                  ? friend.daysSinceContact
                                  : null,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FriendScreen(friend: friend),
                                ),
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// НОВА ФУНКЦІЯ: Повертає friends у яких день народження за 7 днів
  /// БЕЗ дня в день (тому що це окремо _birthdayToday)
  /// Кожен entry: (friend, daysUntil)
  static List<(Friend, int)> _upcomingBirthdayPreviews(List<Friend> friends) {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final result = <(Friend, int)>[];

    for (final f in friends) {
      if (f.birthday == null) continue;
      final bday = f.birthday!;

      var next = DateTime(today.year, bday.month, bday.day);
      if (next.isBefore(todayMidnight)) {
        next = DateTime(today.year + 1, bday.month, bday.day);
      }

      final diff = next.difference(todayMidnight).inDays;

      // ЗМІНА: Показувати за 7 днів ДО дня народження (diff > 0 && diff <= 7)
      // Але НЕ день в день (diff != 0)
      if (diff > 0 && diff <= 7) {
        result.add((f, diff));
      }
    }

    result.sort((a, b) => a.$2.compareTo(b.$2));
    return result;
  }

  /// НОВА ФУНКЦІЯ: Повертає friends у яких день народження СЬОГОДНІ
  static List<Friend> _birthdayToday(List<Friend> friends) {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    return friends.where((f) {
      if (f.birthday == null) return false;
      final bday = f.birthday!;
      final nextBday = DateTime(today.year, bday.month, bday.day);
      return nextBday.isAtSameMomentAs(todayMidnight);
    }).toList();
  }

  static String _subtitle(int total, int overdue) {
    final people = total == 1 ? '1 person' : '$total people';
    if (overdue == 0) return people;
    final attn = overdue == 1 ? '1 needs attention' : '$overdue need attention';
    return '$people · $attn';
  }
}

// ─── Birthday Preview Card (за 7 днів) ────────────────────────────────────

class _BirthdayPreviewCard extends StatelessWidget {
  const _BirthdayPreviewCard({
    required this.friend,
    required this.daysUntil,
    required this.onDismiss,
  });

  final Friend friend;
  final int daysUntil;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.name, style: AppTextStyles.bodyMedium16),
                const SizedBox(height: 4),
                Text(
                  'Birthday in $daysUntil ${daysUntil == 1 ? 'day' : 'days'}',
                  style: AppTextStyles.bodyRegular14.copyWith(
                    color: const Color(0xFFAEAEB2),
                  ),
                ),
              ],
            ),
          ),
          // НОВЕ: Close button (X)
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              child: Center(
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
