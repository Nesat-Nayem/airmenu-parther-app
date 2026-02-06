import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ForecastingState extends Equatable {
  const ForecastingState();
  @override
  List<Object?> get props => [];
}

class ForecastingInitial extends ForecastingState {
  final String selectedItemId;
  final String selectedTimeRange; // '7', '14', '30'

  const ForecastingInitial({
    this.selectedItemId = 'paneer',
    this.selectedTimeRange = 'Next 7 Days',
  });

  @override
  List<Object?> get props => [selectedItemId, selectedTimeRange];

  ForecastingInitial copyWith({
    String? selectedItemId,
    String? selectedTimeRange,
  }) {
    return ForecastingInitial(
      selectedItemId: selectedItemId ?? this.selectedItemId,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
    );
  }
}

class ForecastingCubit extends Cubit<ForecastingState> {
  ForecastingCubit() : super(const ForecastingInitial());

  void selectItem(String itemId) {
    if (state is ForecastingInitial) {
      emit((state as ForecastingInitial).copyWith(selectedItemId: itemId));
    }
  }

  void selectTimeRange(String range) {
    if (state is ForecastingInitial) {
      emit((state as ForecastingInitial).copyWith(selectedTimeRange: range));
    }
  }
}
