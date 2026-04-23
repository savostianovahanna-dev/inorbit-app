part of 'settings_bloc.dart';

abstract class SettingsEvent {
  const SettingsEvent();
}

class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

/// Dispatched when returning from EditProfileScreen so the bloc can refresh
/// the cached local avatar path without the widget touching UserProfileService.
class SettingsProfileRefreshed extends SettingsEvent {
  const SettingsProfileRefreshed();
}

class SettingsRemindersToggled extends SettingsEvent {
  const SettingsRemindersToggled(this.value);
  final bool value;
}

class SettingsBirthdaysToggled extends SettingsEvent {
  const SettingsBirthdaysToggled(this.value, this.friends);
  final bool value;
  final List<Friend> friends;
}

class SettingsLogOutRequested extends SettingsEvent {
  const SettingsLogOutRequested();
}

class SettingsDeleteAccountRequested extends SettingsEvent {
  const SettingsDeleteAccountRequested();
}
