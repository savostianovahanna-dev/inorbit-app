import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inorbit/bloc/add_friend/add_friend_event.dart';
import 'package:inorbit/domain/usecases/add_friend.use_case.dart';
import 'add_friend_state.dart';

class AddFriendBloc extends Bloc<AddFriendEvent, AddFriendState> {
  final AddFriendUseCase _addFriend;

  AddFriendBloc(this._addFriend) : super(AddFriendInitial()) {
    on<AddFriendSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    AddFriendSubmitted event,
    Emitter<AddFriendState> emit,
  ) async {
    emit(AddFriendLoading());
    try {
      final friend = await _addFriend(event.params);
      emit(AddFriendSuccess(friend.name));
    } catch (e) {
      emit(AddFriendError(e.toString()));
    }
  }
}
