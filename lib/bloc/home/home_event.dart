part of 'home_bloc.dart';

abstract class HomeEvent {
  const HomeEvent();
}

/// Dispatched once when the home screen mounts.
class HomeStarted extends HomeEvent {
  const HomeStarted();
}
