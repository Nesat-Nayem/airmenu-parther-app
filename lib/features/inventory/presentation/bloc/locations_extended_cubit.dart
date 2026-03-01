import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LocationsExtStatus { initial, loading, loaded, error }

class LocationsExtState extends Equatable {
  final List<LocationModel> locations;
  final List<StockTransferModel> transfers;
  final LocationsExtStatus status;
  final int selectedTabIndex;
  final String errorMessage;

  const LocationsExtState({
    this.locations = const [],
    this.transfers = const [],
    this.status = LocationsExtStatus.initial,
    this.selectedTabIndex = 0,
    this.errorMessage = '',
  });

  LocationsExtState copyWith({
    List<LocationModel>? locations,
    List<StockTransferModel>? transfers,
    LocationsExtStatus? status,
    int? selectedTabIndex,
    String? errorMessage,
  }) {
    return LocationsExtState(
      locations: locations ?? this.locations,
      transfers: transfers ?? this.transfers,
      status: status ?? this.status,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [locations, transfers, status, selectedTabIndex, errorMessage];
}

class LocationsExtCubit extends Cubit<LocationsExtState> {
  final InventoryRepository _repo;

  LocationsExtCubit(this._repo) : super(const LocationsExtState());

  void selectTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
    if (index == 0 || index == 1) loadLocations();
    if (index == 2) loadTransfers();
  }

  Future<void> loadLocations() async {
    emit(state.copyWith(status: LocationsExtStatus.loading));
    final result = await _repo.getLocations();
    if (result is DataSuccess<List<LocationModel>>) {
      emit(state.copyWith(locations: result.data!, status: LocationsExtStatus.loaded));
    } else {
      emit(state.copyWith(status: LocationsExtStatus.error, errorMessage: 'Failed to load locations'));
    }
  }

  Future<void> addLocation(Map<String, dynamic> params) async {
    final result = await _repo.createLocation(params);
    if (result is DataSuccess<LocationModel>) {
      emit(state.copyWith(locations: [...state.locations, result.data!]));
    }
  }

  Future<void> updateLocation(String id, Map<String, dynamic> params) async {
    final result = await _repo.updateLocation(id, params);
    if (result is DataSuccess<LocationModel>) {
      final updated = state.locations.map((l) => l.id == id ? result.data! : l).toList();
      emit(state.copyWith(locations: updated));
    }
  }

  Future<void> removeLocation(String id) async {
    await _repo.deleteLocation(id);
    emit(state.copyWith(locations: state.locations.where((l) => l.id != id).toList()));
  }

  Future<void> loadTransfers() async {
    emit(state.copyWith(status: LocationsExtStatus.loading));
    final result = await _repo.getTransfers();
    if (result is DataSuccess<List<StockTransferModel>>) {
      emit(state.copyWith(transfers: result.data!, status: LocationsExtStatus.loaded));
    } else {
      emit(state.copyWith(status: LocationsExtStatus.error, errorMessage: 'Failed to load transfers'));
    }
  }

  Future<void> createTransfer(Map<String, dynamic> params) async {
    final result = await _repo.createTransfer(params);
    if (result is DataSuccess<StockTransferModel>) {
      emit(state.copyWith(transfers: [result.data!, ...state.transfers]));
    }
  }

  Future<void> updateTransferStatus(String id, String status) async {
    final result = await _repo.updateTransferStatus(id, status);
    if (result is DataSuccess<StockTransferModel>) {
      final updated = state.transfers.map((t) => t.id == id ? result.data! : t).toList();
      emit(state.copyWith(transfers: updated));
    }
  }
}
