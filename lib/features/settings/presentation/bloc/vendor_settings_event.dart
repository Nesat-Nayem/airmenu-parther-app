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

class UpdateRestaurantField extends VendorSettingsEvent {
  final String key;
  final dynamic value;

  const UpdateRestaurantField({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

class SaveRestaurantInfo extends VendorSettingsEvent {
  const SaveRestaurantInfo();
}

class SaveTimings extends VendorSettingsEvent {
  const SaveTimings();
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

class UploadMainImage extends VendorSettingsEvent {
  final String filePath;
  const UploadMainImage({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class SearchLocation extends VendorSettingsEvent {
  final String query;
  const SearchLocation({required this.query});

  @override
  List<Object?> get props => [query];
}

class ClearLocationSuggestions extends VendorSettingsEvent {
  const ClearLocationSuggestions();
}

class SelectLocationSuggestion extends VendorSettingsEvent {
  final String description;
  const SelectLocationSuggestion({required this.description});

  @override
  List<Object?> get props => [description];
}
