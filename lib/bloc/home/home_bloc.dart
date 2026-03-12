import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/friend.dart';
import '../../domain/usecases/watch_friends.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._watchFriends) : super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
  }

  final WatchFriends _watchFriends;

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await emit.forEach<List<Friend>>(
      _watchFriends(),
      onData: HomeLoaded.new,
      onError: (error, _) => HomeError(error.toString()),
    );
  }
}
