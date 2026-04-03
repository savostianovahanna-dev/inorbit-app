import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/friend.dart';

/// Handles scheduling and cancelling local birthday reminder notifications.
///
/// Notifications fire at 9 AM **the day before** each friend's birthday
/// and repeat automatically every year.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
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

    await _plugin.initialize(
      const InitializationSettings(iOS: iosInit),
    );
  }

  // ── Permissions ─────────────────────────────────────────────────────────────

  /// Requests iOS notification permission. Returns true if granted.
  Future<bool> requestPermissions() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
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
  Future<void> scheduleBirthdayReminders(
    List<Friend> friends, {
    required bool globalEnabled,
  }) async {
    // Always cancel everything first so we start clean.
    await _plugin.cancelAll();

    if (!globalEnabled) return;

    for (final friend in friends) {
      if (friend.birthday == null || !friend.remindBirthday) continue;
      await _scheduleForFriend(friend);
    }

    debugPrint(
      '[NotificationService] Scheduled birthday reminders for '
      '${friends.where((f) => f.birthday != null && f.remindBirthday).length} friends.',
    );
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<void> _scheduleForFriend(Friend friend) async {
    final birthday = friend.birthday!;
    final now = tz.TZDateTime.now(tz.local);

    // The reminder fires at 9:00 AM the day before the birthday.
    var reminderDate = tz.TZDateTime(
      tz.local,
      now.year,
      birthday.month,
      birthday.day,
      9, 0, 0,
    ).subtract(const Duration(days: 1));

    // If today is past that date this year, push to next year.
    if (reminderDate.isBefore(now)) {
      reminderDate = tz.TZDateTime(
        tz.local,
        now.year + 1,
        birthday.month,
        birthday.day,
        9, 0, 0,
      ).subtract(const Duration(days: 1));
    }

    // Stable int ID — friends are identified by UUID strings, so hash them.
    final notifId = friend.id.hashCode.abs() % 100000;

    // Schedule for the next occurrence (one-shot).
    // Re-scheduling happens every time the app opens via HomeScreen's
    // BlocListener, so the notification effectively repeats annually.
    await _plugin.zonedSchedule(
      notifId,
      "🎂 ${friend.name}'s birthday is tomorrow",
      "Don't forget to reach out and wish them a happy birthday!",
      reminderDate,
      const NotificationDetails(iOS: _iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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
