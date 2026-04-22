import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/friend.dart';

/// Handles scheduling and cancelling local birthday and orbit reminder notifications.
///
/// BIRTHDAY NOTIFICATIONS:
/// - Push за 7 днів о 12:00 (тихий, для приготування)
/// - Push день в день о 12:00 (громкий, фінальний нагадок)
///
/// ORBIT NOTIFICATIONS:
/// - Push раз на 2 тижні (дні 30, 44, 58, 72...) коли друг overdue
/// - In-app статус (Green/Yellow/Red) показується на HomeScreem
///
/// Notifications fire at specific local times and repeat automatically.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _scheduledBirthdayIds = <int>{};
  final _scheduledOrbitIds = <int>{};

  /// iOS notification details з громким звуком
  static const _iosDetailsWithSound = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  /// iOS notification details без звуку (для reminder за 7 днів)
  static const _iosDetailsQuiet = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: false,
  );

  // ── Init ────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    tz_data.initializeTimeZones();

    // Try to detect the local timezone from the device.
    try {
      final locationName = await _detectLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    } catch (_) {
      // Fallback — UTC is fine; notification times will just be in UTC.
    }

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // ask explicitly later
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(const InitializationSettings(iOS: iosInit));
  }

  // ── Permissions ─────────────────────────────────────────────────────────────

  /// Requests iOS notification permission. Returns true if granted.
  Future<bool> requestPermissions() async {
    final ios =
        _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    final granted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return granted ?? false;
  }

  // ── Scheduling ───────────────────────────────────────────────────────────────

  /// Cancels all existing birthday notifications and reschedules based on
  /// the current [friends] list and the [globalEnabled] toggle from Settings.
  ///
  /// ЗМІНА: Тепер планує ДВА notifications для кожного друга:
  /// 1. За 7 днів о 12:00 (тихий)
  /// 2. День в день о 12:00 (громкий)
  Future<void> scheduleBirthdayReminders(
    List<Friend> friends, {
    required bool globalEnabled,
  }) async {
    // Cancel only previously scheduled birthday notifications (not test ones).
    for (final id in _scheduledBirthdayIds) {
      await _plugin.cancel(id);
    }
    _scheduledBirthdayIds.clear();

    if (!globalEnabled) return;

    for (final friend in friends) {
      if (friend.birthday == null || !friend.remindBirthday) continue;
      // НОВЕ: планує дві notifications замість однієї
      await _scheduleBirthdayReminder_7DaysBefore(friend);
      await _scheduleBirthdayReminder_Today(friend);
    }

    debugPrint(
      '[NotificationService] Scheduled birthday reminders for '
      '${friends.where((f) => f.birthday != null && f.remindBirthday).length} friends.',
    );
  }

  /// Cancels all existing orbit reminders and reschedules based on the current
  /// [friends] list.
  ///
  /// ЗМІНА: Тепер планує notifications раз на 2 тижні (дні 30, 44, 58...)
  /// замість одного за день до overdue
  Future<void> scheduleOrbitReminders(List<Friend> friends) async {
    for (final id in _scheduledOrbitIds) {
      await _plugin.cancel(id);
    }
    _scheduledOrbitIds.clear();

    for (final friend in friends) {
      await _scheduleOrbitReminders_Recurring(friend);
    }

    debugPrint(
      '[NotificationService] Scheduled orbit reminders for ${friends.length} friends.',
    );
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// НОВА ФУНКЦІЯ: Планує push за 7 днів до дня народження о 12:00
  /// Текст: "🎁 {friend}'s birthday is in 7 days!"
  /// Звук: Тихий (для hint)
  /// ID: friend.id.hashCode + 300000
  Future<void> _scheduleBirthdayReminder_7DaysBefore(Friend friend) async {
    final birthday = friend.birthday!;
    final now = tz.TZDateTime.now(tz.local);

    // Розраховуємо дату 12:00 за 7 днів до ДН
    var reminderDate = tz.TZDateTime(
      tz.local,
      now.year,
      birthday.month,
      birthday.day,
      12, // ЗМІНА: 12:00 (обід) замість 9:00 AM
      0,
      0,
    ).subtract(const Duration(days: 7)); // ЗМІНА: мінус 7 днів

    // If today is past that date this year, push to next year.
    if (reminderDate.isBefore(now)) {
      reminderDate = tz.TZDateTime(
        tz.local,
        now.year + 1,
        birthday.month,
        birthday.day,
        12,
        0,
        0,
      ).subtract(const Duration(days: 7));
    }

    // НОВЕ: ID offset +300000 для 7-day reminders
    final notifId = friend.id.hashCode.abs() % 100000 + 300000;
    _scheduledBirthdayIds.add(notifId);

    await _plugin.zonedSchedule(
      notifId,
      "🎁 ${friend.name}'s birthday is in 7 days!",
      "Time to think about a gift or plan something special",
      reminderDate,
      // ЗМІНА: Використовуємо тихий звук для цього reminder
      NotificationDetails(iOS: _iosDetailsQuiet),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// НОВА ФУНКЦІЯ: Планує push день в день дня народження о 12:00
  /// Текст: "🎂 {friend}'s birthday is today!"
  /// Звук: Громкий (важна)
  /// ID: friend.id.hashCode + 400000
  Future<void> _scheduleBirthdayReminder_Today(Friend friend) async {
    final birthday = friend.birthday!;
    final now = tz.TZDateTime.now(tz.local);

    // Розраховуємо дату 12:00 день в день
    var reminderDate = tz.TZDateTime(
      tz.local,
      now.year,
      birthday.month,
      birthday.day,
      12, // ЗМІНА: 12:00 день в день
      0,
      0,
    );

    // If today is the birthday itself, we need next year
    if (reminderDate.isBefore(now)) {
      reminderDate = tz.TZDateTime(
        tz.local,
        now.year + 1,
        birthday.month,
        birthday.day,
        12,
        0,
        0,
      );
    }

    // НОВЕ: ID offset +400000 для today reminders
    final notifId = friend.id.hashCode.abs() % 100000 + 400000;
    _scheduledBirthdayIds.add(notifId);

    await _plugin.zonedSchedule(
      notifId,
      "🎂 ${friend.name}'s birthday is today!",
      "Don't forget to call or send a message",
      reminderDate,
      // ЗМІНА: Використовуємо громкий звук для цього reminder
      const NotificationDetails(iOS: _iosDetailsWithSound),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// ЗМІНЕНА ФУНКЦІЯ: Планує orbit reminders раз на 2 тижні (дні 30, 44, 58, 72...)
  /// замість одного за день до overdue
  ///
  /// ЛОГІКА:
  /// День 0: User спілкується з друзом
  /// День 1-25: Green "In orbit" (no notifications)
  /// День 26-29: Yellow "Coming up soon" (no notifications)
  /// День 30: PUSH "needs attention!" (перша push)
  /// День 44: PUSH "still waiting..." (друга push)
  /// День 58: PUSH "really waiting..." (третя push)
  /// День 72: PUSH "don't forget..." (четверта push)
  /// ... і так далі кожні 14 днів
  ///
  /// ID: friend.id.hashCode + 200000 + (multiplier * 10)
  Future<void> _scheduleOrbitReminders_Recurring(Friend friend) async {
    final baseline = friend.lastConnectedAt ?? friend.createdAt;
    final now = tz.TZDateTime.now(tz.local);
    final frequencyDays = friend.frequencyDays;

    // Планує notifications для дні 30, 44, 58, 72... (кожні 14 днів після overdue)
    for (int multiplier = 0; multiplier < 6; multiplier++) {
      final overdueDay = frequencyDays + (multiplier * 14);

      var notificationDate = tz.TZDateTime(
        tz.local,
        baseline.year,
        baseline.month,
        baseline.day,
        9, // 9:00 AM
        0,
        0,
      ).add(Duration(days: overdueDay));

      // Skip if this date is already in the past
      if (notificationDate.isBefore(now)) continue;

      // НОВЕ: ID схема для overdue notifications
      // День 30: +200000, День 44: +210000, День 58: +220000 тощо
      final notifId =
          friend.id.hashCode.abs() % 100000 + 200000 + (multiplier * 10000);
      _scheduledOrbitIds.add(notifId);

      final message = _getOrbitPushMessage(
        multiplier,
        friend.name,
        frequencyDays,
      );

      await _plugin.zonedSchedule(
        notifId,
        message,
        "You haven't connected in $overdueDay days.",
        notificationDate,
        const NotificationDetails(iOS: _iosDetailsWithSound),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// НОВА ФУНКЦІЯ: Повертає різні повідомлення для orbit reminders
  /// залежно від того, яка по номеру це push
  /// (escalation: від м'яких до більш настійливих)
  String _getOrbitPushMessage(
    int weekNumber,
    String friendName,
    int frequencyDays,
  ) {
    return switch (weekNumber) {
      0 => '👋 $friendName needs your attention!',
      1 => '👋 Still waiting to hear from $friendName...',
      2 => '👋 $friendName is really waiting for you...',
      3 => '👋 Don\'t forget about $friendName!',
      4 => '👋 Time to reconnect with $friendName!',
      _ => '👋 Reach out to $friendName!',
    };
  }

  /// Best-effort detection of the device timezone name (e.g. "Europe/London").
  /// Falls back to "UTC" on error.
  Future<String> _detectLocalTimezone() async {
    // On Flutter, DateTime.now().timeZoneName gives platform abbreviation
    // ("EET", "EST", etc.) which is not a valid tz database name.
    // The simplest reliable approach: map UTC offset to a reasonable zone.
    final offsetHours = DateTime.now().timeZoneOffset.inHours;
    // Common offsets → a representative tz name.
    const offsetToZone = <int, String>{
      -12: 'Etc/GMT+12',
      -11: 'Pacific/Apia',
      -10: 'Pacific/Honolulu',
      -9: 'America/Anchorage',
      -8: 'America/Los_Angeles',
      -7: 'America/Denver',
      -6: 'America/Chicago',
      -5: 'America/New_York',
      -4: 'America/Halifax',
      -3: 'America/Sao_Paulo',
      -2: 'Etc/GMT+2',
      -1: 'Atlantic/Azores',
      0: 'Europe/London',
      1: 'Europe/Paris',
      2: 'Europe/Helsinki',
      3: 'Europe/Moscow',
      4: 'Asia/Dubai',
      5: 'Asia/Karachi',
      6: 'Asia/Dhaka',
      7: 'Asia/Bangkok',
      8: 'Asia/Shanghai',
      9: 'Asia/Tokyo',
      10: 'Australia/Sydney',
      11: 'Pacific/Noumea',
      12: 'Pacific/Auckland',
    };
    return offsetToZone[offsetHours] ?? 'UTC';
  }
}
