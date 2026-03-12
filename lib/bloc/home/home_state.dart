part of 'home_bloc.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.friends);

  final List<Friend> friends;
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;
}
