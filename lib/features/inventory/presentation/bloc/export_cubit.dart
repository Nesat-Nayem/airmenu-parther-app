import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ExportFormat { excel, pdf }

enum ExportDataType { inventoryItems, purchaseOrders, analytics }

enum ExportStatus { initial, loading, success }

class ExportState extends Equatable {
  final ExportFormat selectedFormat;
  final List<ExportDataType> selectedDataTypes;
  final ExportStatus status;

  const ExportState({
    this.selectedFormat = ExportFormat.excel,
    this.selectedDataTypes = const [
      ExportDataType.inventoryItems,
      ExportDataType.purchaseOrders,
    ],
    this.status = ExportStatus.initial,
  });

  ExportState copyWith({
    ExportFormat? selectedFormat,
    List<ExportDataType>? selectedDataTypes,
    ExportStatus? status,
  }) {
    return ExportState(
      selectedFormat: selectedFormat ?? this.selectedFormat,
      selectedDataTypes: selectedDataTypes ?? this.selectedDataTypes,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [selectedFormat, selectedDataTypes, status];
}

class ExportCubit extends Cubit<ExportState> {
  ExportCubit() : super(const ExportState());

  void selectFormat(ExportFormat format) {
    if (state.status == ExportStatus.loading) return;
    emit(state.copyWith(selectedFormat: format));
  }

  void toggleDataType(ExportDataType type) {
    if (state.status == ExportStatus.loading) return;
    final current = List<ExportDataType>.from(state.selectedDataTypes);
    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }
    emit(state.copyWith(selectedDataTypes: current));
  }

  Future<void> exportData() async {
    if (state.status == ExportStatus.loading) return;

    emit(state.copyWith(status: ExportStatus.loading));

    // Simulate API/Generation delay
    await Future.delayed(const Duration(seconds: 2));

    emit(state.copyWith(status: ExportStatus.success));
  }
}
