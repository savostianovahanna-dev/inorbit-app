import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inorbit/bloc/add_friend/add_friend_bloc.dart';
import 'package:inorbit/bloc/add_friend/add_friend_event.dart';
import 'package:inorbit/bloc/add_friend/add_friend_state.dart';
import 'package:inorbit/core/di/injection.dart';
import 'package:inorbit/core/theme/app_colors.dart';
import 'package:inorbit/domain/usecases/add_friend.use_case.dart';
import 'package:inorbit/presentation/create_friend/screens/add_friend_success_screen.dart';
import 'package:inorbit/presentation/create_friend/steps/step_1/add_friend_step1.dart';
import 'package:inorbit/presentation/create_friend/steps/step_2/add_friend_step2.dart';
import 'package:inorbit/presentation/create_friend/steps/step_3/add_friend_step3.dart';
import 'package:inorbit/presentation/create_friend/widgets/add_friend_header.dart';
import 'package:inorbit/presentation/create_friend/widgets/continue_button.dart';
import 'package:inorbit/presentation/create_friend/widgets/progress_bar.dart';

class AddFriendScreen extends StatelessWidget {
  const AddFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddFriendBloc>(),
      child: const _AddFriendScreenContent(),
    );
  }
}

class _AddFriendScreenContent extends StatefulWidget {
  const _AddFriendScreenContent();

  @override
  State<_AddFriendScreenContent> createState() =>
      _AddFriendScreenContentState();
}

class _AddFriendScreenContentState extends State<_AddFriendScreenContent> {
  int _step = 1;
  static const _totalSteps = 3;

  final _nameCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  int _orbitTierIndex = 0;
  DateTime? _lastConnectedAt;
  int? _planetIndex;
  String? _avatarFilePath;
  DateTime? _birthday;
  bool _remindBirthday = true;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthdayCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (_step < _totalSteps) {
      setState(() => _step++);
      return;
    }
    if (_saving) return;

    const orbitTiers = ['inner_circle', 'regulars', 'casuals'];
    const freqDays = [14, 30, 90];
    final name =
        _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'Friend';

    context.read<AddFriendBloc>().add(
      AddFriendSubmitted(
        AddFriendParams(
          name: name,
          avatarFilePath: _avatarFilePath,
          planetIndex: _planetIndex,
          orbitTier: orbitTiers[_orbitTierIndex],
          frequencyDays: freqDays[_orbitTierIndex],
          birthday: _birthday,
          lastConnectedAt: _lastConnectedAt,
          remindBirthday: _remindBirthday,
          notes:
              _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        ),
      ),
    );
  }

  void _goBack() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 1:
        return AddFriendStep1(
          nameCtrl: _nameCtrl,
          birthdayCtrl: _birthdayCtrl,
          notesCtrl: _notesCtrl,
          onPlanetIndexChanged: (i) => setState(() => _planetIndex = i),
          onAvatarPathChanged: (p) => setState(() => _avatarFilePath = p),
          onRemindBirthdayChanged: (v) => setState(() => _remindBirthday = v),
          onBirthdayChanged: (d) => setState(() => _birthday = d),
        );
      case 2:
        return AddFriendStep2(
          onOrbitChanged: (i) => setState(() => _orbitTierIndex = i),
        );
      case 3:
        return AddFriendStep3(
          onDateChanged: (d) => setState(() => _lastConnectedAt = d),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddFriendBloc, AddFriendState>(
      listener: (context, state) {
        if (state is AddFriendLoading) {
          setState(() => _saving = true);
        } else if (state is AddFriendSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (_) => AddFriendSuccessScreen(friendName: state.friendName),
            ),
          );
        } else if (state is AddFriendError) {
          setState(() => _saving = false);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
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
                      AddFriendHeader(
                        onBack: _goBack,
                        onClose:
                            () => Navigator.of(
                              context,
                            ).popUntil((r) => r.isFirst),
                      ),
                      const SizedBox(height: 12),
                      AddFriendProgressBar(
                        currentStep: _step,
                        totalSteps: _totalSteps,
                      ),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder:
                            (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: _buildStepContent(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ContinueButton(
                label:
                    _step < _totalSteps
                        ? 'Continue →'
                        : (_saving ? 'Saving...' : 'Add to orbit'),
                showCheck: _step == _totalSteps && !_saving,
                onTap: _saving ? () {} : _goNext,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
