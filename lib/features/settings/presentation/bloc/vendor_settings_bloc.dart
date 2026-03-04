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
  }

  ApiService get _api => locator<ApiService>();

  Future<void> _onLoadSettings(
    LoadVendorSettings event,
    Emitter<VendorSettingsState> emit,
  ) async {
    emit(state.copyWith(status: VendorSettingsStatus.loading));
    try {
      // GET /hotels/vendor/my-hotels - returns vendor's own hotels
      final response = await _api.invoke(
        urlPath: '/hotels/vendor/my-hotels',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final body = response.data as Map<String, dynamic>;
        // API returns { success: true, data: [...] } or { success: true, data: {...} }
        dynamic hotelsData = body['data'];
        Map<String, dynamic>? hotel;

        if (hotelsData is List && hotelsData.isNotEmpty) {
          hotel = Map<String, dynamic>.from(hotelsData[0] as Map);
        } else if (hotelsData is Map<String, dynamic>) {
          hotel = hotelsData;
        }

        if (hotel == null) {
          emit(state.copyWith(
            status: VendorSettingsStatus.failure,
            errorMessage: 'No restaurant found for your account',
          ));
          return;
        }

        final hotelId = (hotel['_id'] ?? '').toString();

        // Parse weeklyTimings from backend format:
        // [{ day: 'Monday', hours: '9:00 AM - 10:00 PM' }, ...]
        final Map<String, dynamic> timings = {};
        final weeklyTimings = hotel['weeklyTimings'] as List<dynamic>? ?? [];
        for (final t in weeklyTimings) {
          final day = (t['day'] ?? '').toString();
          if (day.isEmpty) continue;
          final hours = (t['hours'] ?? '').toString();
          // Parse "9:00 AM - 10:00 PM" → start/end
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

        // Parse priceRange: "100 - 500" → minPrice/maxPrice
        String minPrice = '';
        String maxPrice = '';
        final priceRange = hotel['priceRange']?.toString() ?? '';
        if (priceRange.contains('-')) {
          final parts = priceRange.split('-').map((s) => s.trim()).toList();
          minPrice = parts[0];
          maxPrice = parts.length > 1 ? parts[1] : '';
        } else if (hotel['minPrice'] != null) {
          minPrice = hotel['minPrice'].toString();
          maxPrice = (hotel['maxPrice'] ?? '').toString();
        }

        final data = {
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

        emit(state.copyWith(
          status: VendorSettingsStatus.success,
          data: data,
          hotelId: hotelId,
        ));
      } else {
        emit(state.copyWith(
          status: VendorSettingsStatus.failure,
          errorMessage: 'Failed to load restaurant settings',
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
      final body = <String, dynamic>{
        'name': d['restaurantName'] ?? '',
        'cuisine': d['cuisine'] ?? '',
        'location': d['address'] ?? '',
        'distance': d['distance'] ?? '',
        'description': d['description'] ?? '',
        'gstin': d['gstin'] ?? '',
        'fssai': d['fssai'] ?? '',
        'cgstRate': double.tryParse((d['cgstRate'] ?? '0').toString()) ?? 0,
        'sgstRate': double.tryParse((d['sgstRate'] ?? '0').toString()) ?? 0,
        'serviceCharge': double.tryParse((d['serviceCharge'] ?? '0').toString()) ?? 0,
      };
      // Only include price/rating if non-empty
      if ((d['minPrice'] ?? '').toString().isNotEmpty) {
        body['minPrice'] = int.tryParse(d['minPrice'].toString()) ?? 0;
      }
      if ((d['maxPrice'] ?? '').toString().isNotEmpty) {
        body['maxPrice'] = int.tryParse(d['maxPrice'].toString()) ?? 0;
      }
      if ((d['rating'] ?? '').toString().isNotEmpty) {
        body['rating'] = double.tryParse(d['rating'].toString()) ?? 0.0;
      }

      final response = await _api.invoke(
        urlPath: '/hotels/$hotelId',
        type: RequestType.put,
        params: body,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        emit(state.copyWith(
          isSaving: false,
          successMessage: 'Restaurant info saved successfully',
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
        emit(state.copyWith(
          isSaving: false,
          successMessage: 'Timings saved successfully',
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
