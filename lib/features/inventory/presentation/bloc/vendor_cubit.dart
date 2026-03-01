import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum VendorStatus { initial, loading, loaded, error }

class VendorState extends Equatable {
  final List<VendorModel> vendors;
  final VendorStatus status;
  final String errorMessage;

  const VendorState({
    this.vendors = const [],
    this.status = VendorStatus.initial,
    this.errorMessage = '',
  });

  VendorState copyWith({
    List<VendorModel>? vendors,
    VendorStatus? status,
    String? errorMessage,
  }) {
    return VendorState(
      vendors: vendors ?? this.vendors,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [vendors, status, errorMessage];
}

class VendorCubit extends Cubit<VendorState> {
  final InventoryRepository _repo;

  VendorCubit(this._repo) : super(const VendorState());

  Future<void> loadVendors() async {
    emit(state.copyWith(status: VendorStatus.loading));
    final result = await _repo.getVendors();
    if (result is DataSuccess<List<VendorModel>>) {
      emit(state.copyWith(vendors: result.data!, status: VendorStatus.loaded));
    } else {
      emit(state.copyWith(status: VendorStatus.error, errorMessage: 'Failed to load vendors'));
    }
  }

  Future<void> addVendor(Map<String, dynamic> params) async {
    final result = await _repo.createVendor(params);
    if (result is DataSuccess<VendorModel>) {
      emit(state.copyWith(
        vendors: [...state.vendors, result.data!],
        status: VendorStatus.loaded,
      ));
    }
  }

  Future<void> updateVendor(String id, Map<String, dynamic> params) async {
    final result = await _repo.updateVendor(id, params);
    if (result is DataSuccess<VendorModel>) {
      final updated = state.vendors.map((v) => v.id == id ? result.data! : v).toList();
      emit(state.copyWith(vendors: updated, status: VendorStatus.loaded));
    }
  }

  Future<void> removeVendor(String id) async {
    final result = await _repo.deleteVendor(id);
    if (result is DataSuccess<bool>) {
      final updated = state.vendors.where((v) => v.id != id).toList();
      emit(state.copyWith(vendors: updated, status: VendorStatus.loaded));
    }
  }
}
