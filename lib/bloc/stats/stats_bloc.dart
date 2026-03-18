import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/stats_data.dart';
import '../../domain/usecases/get_stats.use_case.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc(this._getStats) : super(const StatsInitial()) {
    on<StatsStarted>(_onStarted);
  }

  final GetStatsUseCase _getStats;

  Future<void> _onStarted(StatsStarted event, Emitter<StatsState> emit) async {
    emit(const StatsLoading());
    await emit.forEach<StatsData>(
      _getStats(),
      onData: StatsLoaded.new,
      onError: (error, _) => StatsError(error.toString()),
    );
  }
}
