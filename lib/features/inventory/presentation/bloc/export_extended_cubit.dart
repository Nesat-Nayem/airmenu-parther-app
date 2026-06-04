import 'dart:typed_data';

import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'export_download_helper_stub.dart'
    if (dart.library.html) 'export_download_helper_web.dart'
    as download_helper;

enum ExportFormat { excel, pdf }
enum ExportDataType { inventoryItems, purchaseOrders, analytics }
enum ExportExtStatus { initial, loading, success, error }

class ExportExtState extends Equatable {
  final ExportFormat selectedFormat;
  final List<ExportDataType> selectedDataTypes;
  final ExportExtStatus status;
  final String errorMessage;

  const ExportExtState({
    this.selectedFormat = ExportFormat.excel,
    this.selectedDataTypes = const [
      ExportDataType.inventoryItems,
      ExportDataType.purchaseOrders,
    ],
    this.status = ExportExtStatus.initial,
    this.errorMessage = '',
  });

  ExportExtState copyWith({
    ExportFormat? selectedFormat,
    List<ExportDataType>? selectedDataTypes,
    ExportExtStatus? status,
    String? errorMessage,
  }) {
    return ExportExtState(
      selectedFormat: selectedFormat ?? this.selectedFormat,
      selectedDataTypes: selectedDataTypes ?? this.selectedDataTypes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [selectedFormat, selectedDataTypes, status, errorMessage];
}

class ExportExtCubit extends Cubit<ExportExtState> {
  final InventoryRepository _repo;

  ExportExtCubit(this._repo) : super(const ExportExtState());

  void selectFormat(ExportFormat format) {
    if (state.status == ExportExtStatus.loading) return;
    emit(state.copyWith(selectedFormat: format));
  }

  void toggleDataType(ExportDataType type) {
    if (state.status == ExportExtStatus.loading) return;
    final current = List<ExportDataType>.from(state.selectedDataTypes);
    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }
    emit(state.copyWith(selectedDataTypes: current));
  }

  Future<void> exportData() async {
    if (state.status == ExportExtStatus.loading) return;
    emit(state.copyWith(status: ExportExtStatus.loading));

    final types = state.selectedDataTypes.map((t) {
      switch (t) {
        case ExportDataType.inventoryItems: return 'inventoryItems';
        case ExportDataType.purchaseOrders: return 'purchaseOrders';
        case ExportDataType.analytics: return 'analytics';
      }
    }).toList();

    final isPdf = state.selectedFormat == ExportFormat.pdf;
    final format = isPdf ? 'pdf' : 'excel';

    final result = await _repo.exportData(types, format);
    if (result is DataSuccess<Uint8List> && result.data != null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = isPdf ? 'pdf' : 'xlsx';
      final mimeType = isPdf
          ? 'application/pdf'
          : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      download_helper.downloadFileBytes(
        result.data!,
        'inventory_export_$timestamp.$extension',
        mimeType,
      );
      emit(state.copyWith(status: ExportExtStatus.success));
    } else {
      emit(state.copyWith(
        status: ExportExtStatus.error,
        errorMessage: result.error?.message ?? 'Export failed',
      ));
    }
  }
}
