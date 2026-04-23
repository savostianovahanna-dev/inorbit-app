import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/user_profile_service.dart';
import '../../domain/entities/friend.dart';
import '../../domain/usecases/delete_account_use_case.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required DeleteAccountUseCase deleteAccount,
    required AuthService authService,
    required UserProfileService userProfileService,
    required NotificationService notificationService,
  })  : _deleteAccount = deleteAccount,
        _authService = authService,
        _userProfileService = userProfileService,
        _notificationService = notificationService,
        super(const SettingsState()) {
    on<SettingsStarted>(_onStarted);
    on<SettingsProfileRefreshed>(_onProfileRefreshed);
    on<SettingsRemindersToggled>(_onRemindersToggled);
    on<SettingsBirthdaysToggled>(_onBirthdaysToggled);
    on<SettingsLogOutRequested>(_onLogOutRequested);
    on<SettingsDeleteAccountRequested>(_onDeleteAccountRequested);
  }

  final DeleteAccountUseCase _deleteAccount;
  final AuthService _authService;
  final UserProfileService _userProfileService;
  final NotificationService _notificationService;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _onStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    final uid = _uid;
    if (uid == null) return;

    final data = await _userProfileService.load(uid);
    final s = (data?['settings'] as Map<String, dynamic>?) ?? {};
    final birthdays = s['birthdays'] as bool? ?? true;

    _userProfileService.birthdaysEnabled = birthdays;

    emit(state.copyWith(
      reminders: s['reminders'] as bool? ?? true,
      birthdays: birthdays,
      countMessages: s['countMessages'] as bool? ?? false,
      localAvatarPath: _userProfileService.localAvatarPath,
    ));
  }

  void _onProfileRefreshed(
    SettingsProfileRefreshed event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(localAvatarPath: _userProfileService.localAvatarPath));
  }

  void _onRemindersToggled(
    SettingsRemindersToggled event,
    Emitter<SettingsState> emit,
  ) {
    final next = state.copyWith(reminders: event.value);
    emit(next);
    _saveSettings(next);
  }

  Future<void> _onBirthdaysToggled(
    SettingsBirthdaysToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final next = state.copyWith(birthdays: event.value);
    emit(next);
    _userProfileService.birthdaysEnabled = event.value;
    _saveSettings(next);

    if (event.value) {
      await _notificationService.requestPermissions();
    }
    await _notificationService.scheduleBirthdayReminders(
      event.friends,
      globalEnabled: event.value,
    );
  }

  Future<void> _onLogOutRequested(
    SettingsLogOutRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      await _authService.signOut();
      emit(state.copyWith(status: SettingsStatus.loggedOut));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteAccountRequested(
    SettingsDeleteAccountRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      await _deleteAccount();
      emit(state.copyWith(status: SettingsStatus.loggedOut));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _saveSettings(SettingsState s) {
    final uid = _uid;
    if (uid == null) return;
    _userProfileService.save(uid, {
      'settings': {
        'reminders': s.reminders,
        'birthdays': s.birthdays,
        'countMessages': s.countMessages,
      },
    });
  }
}
