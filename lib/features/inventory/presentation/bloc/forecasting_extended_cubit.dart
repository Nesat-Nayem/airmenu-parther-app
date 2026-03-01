import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ForecastingExtStatus { initial, loading, loaded, error }

class ForecastingExtState extends Equatable {
  final ForecastingData data;
  final String selectedItemId;
  final String selectedTimeRange;
  final ForecastingExtStatus status;
  final String errorMessage;

  const ForecastingExtState({
    this.data = ForecastingData.empty,
    this.selectedItemId = '',
    this.selectedTimeRange = 'Next 7 Days',
    this.status = ForecastingExtStatus.initial,
    this.errorMessage = '',
  });

  ForecastingExtState copyWith({
    ForecastingData? data,
    String? selectedItemId,
    String? selectedTimeRange,
    ForecastingExtStatus? status,
    String? errorMessage,
  }) {
    return ForecastingExtState(
      data: data ?? this.data,
      selectedItemId: selectedItemId ?? this.selectedItemId,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [data, selectedItemId, selectedTimeRange, status, errorMessage];
}

class ForecastingExtCubit extends Cubit<ForecastingExtState> {
  final InventoryRepository _repo;

  ForecastingExtCubit(this._repo) : super(const ForecastingExtState());

  int _daysFromRange(String range) {
    if (range == 'Next 14 Days') return 14;
    if (range == 'Next 30 Days') return 30;
    return 7;
  }

  Future<void> load() async {
    emit(state.copyWith(status: ForecastingExtStatus.loading));
    final days = _daysFromRange(state.selectedTimeRange);
    final result = await _repo.getForecasting(days: days);
    if (result is DataSuccess<ForecastingData>) {
      final data = result.data!;
      final firstId = data.forecasts.isNotEmpty ? data.forecasts.first.id : '';
      emit(state.copyWith(
        data: data,
        selectedItemId: firstId,
        status: ForecastingExtStatus.loaded,
      ));
    } else {
      emit(state.copyWith(status: ForecastingExtStatus.error, errorMessage: 'Failed to load forecasting'));
    }
  }

  void selectItem(String id) {
    emit(state.copyWith(selectedItemId: id));
  }

  Future<void> selectTimeRange(String range) async {
    emit(state.copyWith(selectedTimeRange: range));
    await load();
  }
}
