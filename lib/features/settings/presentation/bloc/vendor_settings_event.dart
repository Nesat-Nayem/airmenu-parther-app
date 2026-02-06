import 'package:equatable/equatable.dart';

abstract class VendorSettingsEvent extends Equatable {
  const VendorSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadVendorSettings extends VendorSettingsEvent {
  const LoadVendorSettings();
}

class ChangeSettingsTab extends VendorSettingsEvent {
  final int tabIndex;

  const ChangeSettingsTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class ToggleSetting extends VendorSettingsEvent {
  final String settingId;
  final bool value;

  const ToggleSetting(this.settingId, this.value);

  @override
  List<Object?> get props => [settingId, value];
}

class UpdateTiming extends VendorSettingsEvent {
  final String day;
  final String? startTime;
  final String? endTime;
  final bool? isEnabled;

  const UpdateTiming({
    required this.day,
    this.startTime,
    this.endTime,
    this.isEnabled,
  });

  @override
  List<Object?> get props => [day, startTime, endTime, isEnabled];
}
