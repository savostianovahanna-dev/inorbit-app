part of 'settings_bloc.dart';

enum SettingsStatus { idle, loading, loggedOut, error }

class SettingsState {
  const SettingsState({
    this.reminders = true,
    this.birthdays = true,
    this.countMessages = false,
    this.localAvatarPath,
    this.status = SettingsStatus.idle,
    this.errorMessage,
  });

  final bool reminders;
  final bool birthdays;
  final bool countMessages;
  final String? localAvatarPath;
  final SettingsStatus status;
  final String? errorMessage;

  SettingsState copyWith({
    bool? reminders,
    bool? birthdays,
    bool? countMessages,
    String? localAvatarPath,
    SettingsStatus? status,
    String? errorMessage,
  }) {
    return SettingsState(
      reminders: reminders ?? this.reminders,
      birthdays: birthdays ?? this.birthdays,
      countMessages: countMessages ?? this.countMessages,
      localAvatarPath: localAvatarPath ?? this.localAvatarPath,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
