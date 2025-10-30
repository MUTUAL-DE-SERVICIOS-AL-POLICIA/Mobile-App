import 'package:bloc/bloc.dart';
import 'package:muserpol_pvt/model/economic_complement_model.dart';
import 'package:muserpol_pvt/model/procedure_model.dart';

part 'procedure_event.dart';
part 'procedure_state.dart';

class ProcedureBloc extends Bloc<ProcedureEvent, ProcedureState> {
  ProcedureBloc() : super(const ProcedureState()) {
    on<AddCurrentProcedures>((event, emit) {
      final prev = state.currentProcedures ?? <Datum>[];

      final byId = <dynamic, Datum>{
        for (final p in prev) (p.id): p,
      };

      for (final p in event.currentProcedures) {
        byId[(p.id)] = p;
      }

      emit(state.copyWith(
        existCurrentProcedures: true,
        currentProcedures: byId.values.toList(),
      ));
    });

    on<AddHistoryProcedures>((event, emit) {
      if (state.existHistoricalProcedures) {
        final prev = state.historicalProcedures ?? <Datum>[];
        final merged = [...prev, ...event.historicalProcedures];
        emit(state.copyWith(historicalProcedures: merged));
      } else {
        emit(state.copyWith(
          existHistoricalProcedures: true,
          historicalProcedures: event.historicalProcedures,
        ));
      }
    });

    on<UpdateEconomicComplement>((event, emit) => emit(
          state.copyWith(
            existInfoComplementInfo: true,
            economicComplementInfo: event.infoEC,
          ),
        ));

    on<UpdateCurrentProcedures>((event, emit) => emit(
          state.copyWith(
            existCurrentProcedures: true,
            currentProcedures: List<Datum>.from(event.currentProcedures),
          ),
        ));

    on<UpdateStateComplementInfo>((event, emit) =>
        emit(state.copyWith(existInfoComplementInfo: event.state)));

    on<ClearProcedures>((event, emit) => emit(state.copyWith(
          existCurrentProcedures: false,
          currentProcedures: [],
          existHistoricalProcedures: false,
          historicalProcedures: [],
        )));
  }
}
