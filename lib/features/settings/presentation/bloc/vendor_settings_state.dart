import 'package:equatable/equatable.dart';

enum VendorSettingsStatus { initial, loading, success, failure }

class VendorSettingsState extends Equatable {
  final VendorSettingsStatus status;
  final int currentTabIndex;
  final Map<String, dynamic> data;
  final String? errorMessage;
  final String? hotelId;
  final bool isSaving;
  final String? successMessage;
  final List<Map<String, dynamic>> locationSuggestions;
  final bool isSearchingLocation;
  final bool isUploadingImage;

  const VendorSettingsState({
    this.status = VendorSettingsStatus.initial,
    this.currentTabIndex = 0,
    this.data = const {},
    this.errorMessage,
    this.hotelId,
    this.isSaving = false,
    this.successMessage,
    this.locationSuggestions = const [],
    this.isSearchingLocation = false,
    this.isUploadingImage = false,
  });

  VendorSettingsState copyWith({
    VendorSettingsStatus? status,
    int? currentTabIndex,
    Map<String, dynamic>? data,
    String? errorMessage,
    String? hotelId,
    bool? isSaving,
    String? successMessage,
    List<Map<String, dynamic>>? locationSuggestions,
    bool? isSearchingLocation,
    bool? isUploadingImage,
  }) {
    return VendorSettingsState(
      status: status ?? this.status,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      data: data ?? this.data,
      errorMessage: errorMessage,
      hotelId: hotelId ?? this.hotelId,
      isSaving: isSaving ?? this.isSaving,
      successMessage: successMessage,
      locationSuggestions: locationSuggestions ?? this.locationSuggestions,
      isSearchingLocation: isSearchingLocation ?? this.isSearchingLocation,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
    );
  }

  @override
  List<Object?> get props => [status, currentTabIndex, data, errorMessage, hotelId, isSaving, successMessage, locationSuggestions, isSearchingLocation, isUploadingImage];
}
