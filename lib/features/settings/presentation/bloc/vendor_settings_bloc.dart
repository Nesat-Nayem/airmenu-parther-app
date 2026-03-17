import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'vendor_settings_event.dart';
import 'vendor_settings_state.dart';

class VendorSettingsBloc
    extends Bloc<VendorSettingsEvent, VendorSettingsState> {
  VendorSettingsBloc() : super(const VendorSettingsState()) {
    on<LoadVendorSettings>(_onLoadSettings);
    on<ChangeSettingsTab>(_onChangeTab);
    on<ToggleSetting>(_onToggleSetting);
    on<UpdateTiming>(_onUpdateTiming);
    on<UpdateRestaurantField>(_onUpdateField);
    on<SaveRestaurantInfo>(_onSaveRestaurantInfo);
    on<SaveTimings>(_onSaveTimings);
    on<UploadMainImage>(_onUploadMainImage);
    on<SearchLocation>(_onSearchLocation);
    on<ClearLocationSuggestions>(_onClearLocationSuggestions);
    on<SelectLocationSuggestion>(_onSelectLocationSuggestion);
  }

  ApiService get _api => locator<ApiService>();

  /// Parse a full hotel JSON object into the state data map
  Map<String, dynamic> _parseHotelData(Map<String, dynamic> hotel) {
    // Parse weeklyTimings from backend format:
    // [{ day: 'Monday', hours: '9:00 AM - 10:00 PM' }, ...]
    final Map<String, dynamic> timings = {};
    final weeklyTimings = hotel['weeklyTimings'] as List<dynamic>? ?? [];
    for (final t in weeklyTimings) {
      final day = (t['day'] ?? '').toString();
      if (day.isEmpty) continue;
      final hours = (t['hours'] ?? '').toString();
      final parts = hours.split(' - ');
      final start = parts.isNotEmpty ? parts[0].trim() : '9:00 AM';
      final end = parts.length > 1 ? parts[1].trim() : '10:00 PM';
      final isClosed = hours.toLowerCase() == 'closed';
      timings[day] = {
        'enabled': !isClosed,
        'start': isClosed ? '9:00 AM' : start,
        'end': isClosed ? '10:00 PM' : end,
      };
    }

    // Parse price: "₹100 - ₹500" or "Above ₹100" or "Under ₹500" → minPrice/maxPrice
    String minPrice = '';
    String maxPrice = '';
    final priceString = (hotel['price'] ?? '').toString();
    if (priceString.contains(' - ')) {
      final parts = priceString.split(' - ').map((s) => s.replaceAll(RegExp(r'[^0-9]'), '')).toList();
      minPrice = parts[0];
      maxPrice = parts.length > 1 ? parts[1] : '';
    } else if (priceString.startsWith('Under')) {
      maxPrice = priceString.replaceAll(RegExp(r'[^0-9]'), '');
    } else if (priceString.startsWith('Above')) {
      minPrice = priceString.replaceAll(RegExp(r'[^0-9]'), '');
    } else {
      final singlePrice = priceString.replaceAll(RegExp(r'[^0-9]'), '');
      if (singlePrice.isNotEmpty) {
        minPrice = singlePrice;
        maxPrice = singlePrice;
      }
    }

    return {
      'restaurantName': hotel['name'] ?? '',
      'cuisine': hotel['cuisine'] ?? hotel['category'] ?? '',
      'address': hotel['location'] ?? hotel['address'] ?? '',
      'distance': (hotel['distance'] ?? '').toString(),
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'rating': (hotel['rating'] ?? '').toString(),
      'description': hotel['description'] ?? '',
      'gstin': hotel['gstin'] ?? '',
      'fssai': hotel['fssai'] ?? '',
      'cgstRate': (hotel['cgstRate'] ?? 0).toString(),
      'sgstRate': (hotel['sgstRate'] ?? 0).toString(),
      'serviceCharge': (hotel['serviceCharge'] ?? 0).toString(),
      'mainImage': hotel['mainImage'] ?? '',
      'timings': timings.isNotEmpty ? timings : _defaultTimings(),
      'notifications': {
        'newOrder': true,
        'kitchenReady': true,
        'lowStock': false,
        'feedback': false,
        'staffLogin': false,
        'deliveryUpdates': true,
      },
      'delivery': {
        'radius': '10',
        'minOrder': '200',
        'baseFee': '30',
        'freeAbove': '500',
        'avgTime': '30-45 mins',
        'partner': 'Internal Fleet',
        'enabled': true,
        'peakSurge': false,
      },
    };
  }

  Future<void> _onLoadSettings(
    LoadVendorSettings event,
    Emitter<VendorSettingsState> emit,
  ) async {
    emit(state.copyWith(status: VendorSettingsStatus.loading));
    try {
      // Step 1: GET /hotels/vendor/my-hotels to get the hotel ID
      final listResponse = await _api.invoke(
        urlPath: '/hotels/vendor/my-hotels',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (listResponse is! DataSuccess) {
        emit(state.copyWith(
          status: VendorSettingsStatus.failure,
          errorMessage: 'Failed to load restaurant settings',
        ));
        return;
      }

      final body = listResponse.data as Map<String, dynamic>;
      dynamic hotelsData = body['data'];
      Map<String, dynamic>? hotelSummary;

      if (hotelsData is List && hotelsData.isNotEmpty) {
        hotelSummary = Map<String, dynamic>.from(hotelsData[0] as Map);
      } else if (hotelsData is Map<String, dynamic>) {
        hotelSummary = hotelsData;
      }

      if (hotelSummary == null) {
        emit(state.copyWith(
          status: VendorSettingsStatus.failure,
          errorMessage: 'No restaurant found for your account',
        ));
        return;
      }

      final hotelId = (hotelSummary['_id'] ?? '').toString();
      if (hotelId.isEmpty) {
        emit(state.copyWith(
          status: VendorSettingsStatus.failure,
          errorMessage: 'Invalid restaurant ID',
        ));
        return;
      }

      // Step 2: GET /hotels/:id to get FULL hotel data (incl. weeklyTimings, cgst, sgst, etc.)
      final fullResponse = await _api.invoke(
        urlPath: '/hotels/$hotelId',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (fullResponse is DataSuccess) {
        final fullBody = fullResponse.data as Map<String, dynamic>;
        final hotel = fullBody['data'] as Map<String, dynamic>? ?? fullBody;
        final data = _parseHotelData(Map<String, dynamic>.from(hotel));

        emit(state.copyWith(
          status: VendorSettingsStatus.success,
          data: data,
          hotelId: hotelId,
        ));
      } else {
        emit(state.copyWith(
          status: VendorSettingsStatus.failure,
          errorMessage: 'Failed to load full restaurant details',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VendorSettingsStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void _onChangeTab(
    ChangeSettingsTab event,
    Emitter<VendorSettingsState> emit,
  ) {
    emit(state.copyWith(currentTabIndex: event.tabIndex));
  }

  void _onToggleSetting(
    ToggleSetting event,
    Emitter<VendorSettingsState> emit,
  ) {
    final currentData = Map<String, dynamic>.from(state.data);
    final notifications = Map<String, dynamic>.from(
      currentData['notifications'] as Map<String, dynamic>? ?? {},
    );
    notifications[event.settingId] = event.value;
    currentData['notifications'] = notifications;
    emit(state.copyWith(data: currentData));
  }

  void _onUpdateField(
    UpdateRestaurantField event,
    Emitter<VendorSettingsState> emit,
  ) {
    final currentData = Map<String, dynamic>.from(state.data);
    currentData[event.key] = event.value;
    emit(state.copyWith(data: currentData));
  }

  Future<void> _onSaveRestaurantInfo(
    SaveRestaurantInfo event,
    Emitter<VendorSettingsState> emit,
  ) async {
    final hotelId = state.hotelId;
    if (hotelId == null || hotelId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Restaurant ID not found'));
      return;
    }

    emit(state.copyWith(isSaving: true, errorMessage: null, successMessage: null));
    try {
      final d = state.data;

      // Build price string in the same format as Next.js panel:
      // "₹minPrice - ₹maxPrice" or "Above ₹minPrice" or "Under ₹maxPrice"
      final minPriceVal = (d['minPrice'] ?? '').toString().trim();
      final maxPriceVal = (d['maxPrice'] ?? '').toString().trim();
      String? priceString;
      if (minPriceVal.isNotEmpty && maxPriceVal.isNotEmpty) {
        priceString = '₹$minPriceVal - ₹$maxPriceVal';
      } else if (minPriceVal.isNotEmpty) {
        priceString = 'Above ₹$minPriceVal';
      } else if (maxPriceVal.isNotEmpty) {
        priceString = 'Under ₹$maxPriceVal';
      }

      final body = <String, dynamic>{
        'name': d['restaurantName'] ?? '',
        'cuisine': d['cuisine'] ?? '',
        'location': d['address'] ?? '',
        'distance': d['distance'] ?? '',
        'description': d['description'] ?? '',
        'cgstRate': double.tryParse((d['cgstRate'] ?? '0').toString()) ?? 0,
        'sgstRate': double.tryParse((d['sgstRate'] ?? '0').toString()) ?? 0,
        'serviceCharge': double.tryParse((d['serviceCharge'] ?? '0').toString()) ?? 0,
      };

      // Include price if we have any price value
      if (priceString != null) {
        body['price'] = priceString;
      }

      // Only include rating if non-empty
      if ((d['rating'] ?? '').toString().isNotEmpty) {
        body['rating'] = double.tryParse(d['rating'].toString()) ?? 0.0;
      }

      // Also include weeklyTimings so all data is sent together
      final timings = d['timings'] as Map<String, dynamic>? ?? {};
      if (timings.isNotEmpty) {
        final weeklyTimings = timings.entries.map((entry) {
          final dayData = entry.value as Map<String, dynamic>;
          final isEnabled = dayData['enabled'] as bool? ?? true;
          final hours = isEnabled
              ? '${dayData['start'] ?? '9:00 AM'} - ${dayData['end'] ?? '10:00 PM'}'
              : 'Closed';
          return {'day': entry.key, 'hours': hours};
        }).toList();
        body['weeklyTimings'] = weeklyTimings;
      }

      final response = await _api.invoke(
        urlPath: '/hotels/$hotelId',
        type: RequestType.put,
        params: body,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        // Use the PUT response data directly to update state
        // The PUT response contains the full updated hotel object
        final responseBody = response.data as Map<String, dynamic>;
        final updatedHotel = responseBody['data'] as Map<String, dynamic>? ?? responseBody;
        final data = _parseHotelData(Map<String, dynamic>.from(updatedHotel));

        emit(state.copyWith(
          isSaving: false,
          successMessage: 'Restaurant info saved successfully',
          data: data,
        ));
      } else {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to save restaurant info',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSaveTimings(
    SaveTimings event,
    Emitter<VendorSettingsState> emit,
  ) async {
    final hotelId = state.hotelId;
    if (hotelId == null || hotelId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Restaurant ID not found'));
      return;
    }

    emit(state.copyWith(isSaving: true, errorMessage: null, successMessage: null));
    try {
      final timings = state.data['timings'] as Map<String, dynamic>? ?? {};
      // Convert timings map back to weeklyTimings array format
      final weeklyTimings = timings.entries.map((entry) {
        final dayData = entry.value as Map<String, dynamic>;
        final isEnabled = dayData['enabled'] as bool? ?? true;
        final hours = isEnabled
            ? '${dayData['start'] ?? '9:00 AM'} - ${dayData['end'] ?? '10:00 PM'}'
            : 'Closed';
        return {'day': entry.key, 'hours': hours};
      }).toList();

      final response = await _api.invoke(
        urlPath: '/hotels/$hotelId',
        type: RequestType.put,
        params: {'weeklyTimings': weeklyTimings},
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        // Use the PUT response data directly to update state
        final responseBody = response.data as Map<String, dynamic>;
        final updatedHotel = responseBody['data'] as Map<String, dynamic>? ?? responseBody;
        final data = _parseHotelData(Map<String, dynamic>.from(updatedHotel));

        emit(state.copyWith(
          isSaving: false,
          successMessage: 'Timings saved successfully',
          data: data,
        ));
      } else {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to save timings',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void _onUpdateTiming(UpdateTiming event, Emitter<VendorSettingsState> emit) {
    if (state.data.isEmpty) return;

    final currentData = Map<String, dynamic>.from(state.data);
    final timings = Map<String, dynamic>.from(
      currentData['timings'] as Map<String, dynamic>? ?? {},
    );

    if (!timings.containsKey(event.day)) {
      timings[event.day] = <String, dynamic>{};
    }

    final dayData = Map<String, dynamic>.from(
      timings[event.day] as Map<String, dynamic>,
    );

    if (event.startTime != null) dayData['start'] = event.startTime;
    if (event.endTime != null) dayData['end'] = event.endTime;
    if (event.isEnabled != null) dayData['enabled'] = event.isEnabled;

    timings[event.day] = dayData;
    currentData['timings'] = timings;

    emit(state.copyWith(data: currentData));
  }

  Future<void> _onUploadMainImage(
    UploadMainImage event,
    Emitter<VendorSettingsState> emit,
  ) async {
    final hotelId = state.hotelId;
    if (hotelId == null || hotelId.isEmpty) return;

    emit(state.copyWith(isUploadingImage: true, errorMessage: null, successMessage: null));
    try {
      final response = await _api.invokeMultipart(
        urlPath: '/hotels/$hotelId',
        type: RequestType.put,
        fields: <String, String>{},
        files: <String, String>{'mainImage': event.filePath},
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final responseBody = response.data as Map<String, dynamic>;
        final updatedHotel = responseBody['data'] as Map<String, dynamic>? ?? responseBody;
        final data = _parseHotelData(Map<String, dynamic>.from(updatedHotel));

        emit(state.copyWith(
          isUploadingImage: false,
          successMessage: 'Image updated successfully',
          data: data,
        ));
      } else {
        emit(state.copyWith(
          isUploadingImage: false,
          errorMessage: 'Failed to upload image',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isUploadingImage: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSearchLocation(
    SearchLocation event,
    Emitter<VendorSettingsState> emit,
  ) async {
    if (event.query.length < 3) {
      emit(state.copyWith(locationSuggestions: [], isSearchingLocation: false));
      return;
    }

    emit(state.copyWith(isSearchingLocation: true));
    try {
      final response = await _api.invoke(
        urlPath: '/places/autocomplete?input=${Uri.encodeComponent(event.query)}',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final body = response.data as Map<String, dynamic>;
        final predictions = (body['data']?['predictions'] as List<dynamic>?) ?? [];
        final suggestions = predictions
            .map((p) => Map<String, dynamic>.from(p as Map))
            .toList();
        emit(state.copyWith(
          locationSuggestions: suggestions,
          isSearchingLocation: false,
        ));
      } else {
        emit(state.copyWith(locationSuggestions: [], isSearchingLocation: false));
      }
    } catch (_) {
      emit(state.copyWith(locationSuggestions: [], isSearchingLocation: false));
    }
  }

  void _onClearLocationSuggestions(
    ClearLocationSuggestions event,
    Emitter<VendorSettingsState> emit,
  ) {
    emit(state.copyWith(locationSuggestions: []));
  }

  void _onSelectLocationSuggestion(
    SelectLocationSuggestion event,
    Emitter<VendorSettingsState> emit,
  ) {
    final currentData = Map<String, dynamic>.from(state.data);
    currentData['address'] = event.description;
    emit(state.copyWith(data: currentData, locationSuggestions: []));
  }

  Map<String, dynamic> _defaultTimings() {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return {
      for (final day in days)
        day: {'enabled': true, 'start': '9:00 AM', 'end': '10:00 PM'},
    };
  }
}
