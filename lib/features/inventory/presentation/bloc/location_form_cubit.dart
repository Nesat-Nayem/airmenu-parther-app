import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// --- STATE ---
class LocationFormState extends Equatable {
  final String addLocationType;
  final String? transferFrom;
  final String? transferTo;
  final String stockFilter;
  final bool isSubmitting;

  const LocationFormState({
    this.addLocationType = 'Branch / Outlet',
    this.transferFrom,
    this.transferTo,
    this.stockFilter = 'All Locations',
    this.isSubmitting = false,
  });

  LocationFormState copyWith({
    String? addLocationType,
    String? transferFrom,
    String? transferTo,
    String? stockFilter,
    bool? isSubmitting,
  }) {
    return LocationFormState(
      addLocationType: addLocationType ?? this.addLocationType,
      transferFrom: transferFrom ?? this.transferFrom,
      transferTo: transferTo ?? this.transferTo,
      stockFilter: stockFilter ?? this.stockFilter,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    addLocationType,
    transferFrom,
    transferTo,
    stockFilter,
    isSubmitting,
  ];
}

// --- CUBIT ---
class LocationFormCubit extends Cubit<LocationFormState> {
  LocationFormCubit() : super(const LocationFormState());

  void setAddLocationType(String type) {
    emit(state.copyWith(addLocationType: type));
  }

  void setTransferFrom(String location) {
    emit(state.copyWith(transferFrom: location));
    // Reset To if it's the same
    if (state.transferTo == location) {
      emit(state.copyWith(transferTo: null));
    }
  }

  void setTransferTo(String location) {
    emit(state.copyWith(transferTo: location));
  }

  void setStockFilter(String filter) {
    emit(state.copyWith(stockFilter: filter));
  }

  Future<void> submitAddLocation() async {
    emit(state.copyWith(isSubmitting: true));
    await Future.delayed(const Duration(seconds: 1)); // Mock API
    emit(state.copyWith(isSubmitting: false));
  }

  Future<void> submitTransfer() async {
    emit(state.copyWith(isSubmitting: true));
    await Future.delayed(const Duration(seconds: 1)); // Mock API
    emit(state.copyWith(isSubmitting: false));
  }
}
