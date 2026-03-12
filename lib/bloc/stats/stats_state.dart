part of 'stats_bloc.dart';

abstract class StatsState {
  const StatsState();
}

class StatsInitial extends StatsState {
  const StatsInitial();
}

class StatsLoading extends StatsState {
  const StatsLoading();
}

class StatsLoaded extends StatsState {
  const StatsLoaded(this.data);

  final StatsData data;
}

class StatsError extends StatsState {
  const StatsError(this.message);

  final String message;
}
