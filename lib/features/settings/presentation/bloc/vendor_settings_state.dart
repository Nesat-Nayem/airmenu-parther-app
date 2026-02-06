import 'package:equatable/equatable.dart';

enum VendorSettingsStatus { initial, loading, success, failure }

class VendorSettingsState extends Equatable {
  final VendorSettingsStatus status;
  final int currentTabIndex;
  final Map<String, dynamic> data;
  final String? errorMessage;

  const VendorSettingsState({
    this.status = VendorSettingsStatus.initial,
    this.currentTabIndex = 0,
    this.data = const {},
    this.errorMessage,
  });

  VendorSettingsState copyWith({
    VendorSettingsStatus? status,
    int? currentTabIndex,
    Map<String, dynamic>? data,
    String? errorMessage,
  }) {
    return VendorSettingsState(
      status: status ?? this.status,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentTabIndex, data, errorMessage];
}
