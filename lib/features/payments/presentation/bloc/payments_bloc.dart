import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/payments/domain/repositories/payments_repository.dart';
import 'payments_event.dart';
import 'payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final PaymentsRepository _repository;

  PaymentsBloc(this._repository) : super(PaymentsInitial()) {
    on<LoadPaymentsData>(_onLoadData);
    on<SwitchPaymentsTab>(_onSwitchTab);
    on<FilterPayments>(_onFilter);
  }

  Future<void> _onLoadData(
    LoadPaymentsData event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(PaymentsLoading());
    try {
      final stats = await _repository.getPaymentStats();
      final settlements = await _repository.getSettlements();
      final disputes = await _repository.getDisputes();
      final bottomStats = await _repository.getBottomStats();

      emit(
        PaymentsLoaded(
          stats: stats,
          settlements: settlements,
          disputes: disputes,
          bottomStats: bottomStats,
        ),
      );
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }

  void _onSwitchTab(SwitchPaymentsTab event, Emitter<PaymentsState> emit) {
    if (state is PaymentsLoaded) {
      emit((state as PaymentsLoaded).copyWith(selectedTabIndex: event.index));
    }
  }

  Future<void> _onFilter(
    FilterPayments event,
    Emitter<PaymentsState> emit,
  ) async {
    if (state is PaymentsLoaded) {
      // In a real app, this would query the API or filter locally thoroughly.
      // For now, we update the filter string in state,
      // which UI widgets can use to filter the list if needed.
      final currentState = state as PaymentsLoaded;
      emit(currentState.copyWith(activeFilter: event.query));
    }
  }
}
