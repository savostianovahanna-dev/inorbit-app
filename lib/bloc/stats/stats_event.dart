part of 'stats_bloc.dart';

abstract class StatsEvent {
  const StatsEvent();
}

/// Dispatched once when the Stats screen mounts.
class StatsStarted extends StatsEvent {
  const StatsStarted();
}
