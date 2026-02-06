import 'package:flutter_bloc/flutter_bloc.dart';
import 'vendor_settings_event.dart';
import 'vendor_settings_state.dart';

class VendorSettingsBloc
    extends Bloc<VendorSettingsEvent, VendorSettingsState> {
  VendorSettingsBloc() : super(const VendorSettingsState()) {
    on<LoadVendorSettings>(_onLoadSettings);
    on<ChangeSettingsTab>(_onChangeTab);
    on<ToggleSetting>(_onToggleSetting);
    on<UpdateTiming>(_onUpdateTiming);
  }

  Future<void> _onLoadSettings(
    LoadVendorSettings event,
    Emitter<VendorSettingsState> emit,
  ) async {
    emit(state.copyWith(status: VendorSettingsStatus.loading));
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1000));

      // Mock Data based on screenshots
      final mockData = {
        'restaurantName': 'Spice Garden',
        'phone': '+91 98765 43210',
        'email': 'contact@spicegarden.com',
        'category': 'Fine Dining',
        'address': '123 MG Road, Bangalore',
        'gstin': '29ABCDE1234F1ZH',
        'fssai': '12345678901234',
        'timings': {
          'Monday': {'enabled': true, 'start': '11:00 AM', 'end': '11:00 PM'},
          'Tuesday': {'enabled': true, 'start': '11:00 AM', 'end': '11:00 PM'},
          'Wednesday': {
            'enabled': true,
            'start': '11:00 AM',
            'end': '11:00 PM',
          },
          'Thursday': {'enabled': true, 'start': '11:00 AM', 'end': '11:00 PM'},
          'Friday': {'enabled': true, 'start': '11:00 AM', 'end': '11:00 PM'},
          'Saturday': {'enabled': true, 'start': '11:00 AM', 'end': '11:00 PM'},
          'Sunday': {'enabled': true, 'start': '11:00 AM', 'end': '11:00 PM'},
        },
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

      emit(
        state.copyWith(status: VendorSettingsStatus.success, data: mockData),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VendorSettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
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
    // Deep copy handling for nested maps would usually go here
    // For now simplistic update on notification toggles
    // In a real app, use distinct deep copy or immutable structures
    final currentData = Map<String, dynamic>.from(state.data);

    // Logic to find and update the setting
    // This is placeholder logic

    emit(state.copyWith(data: currentData));
  }

  void _onUpdateTiming(UpdateTiming event, Emitter<VendorSettingsState> emit) {
    if (state.data.isEmpty) return;

    final currentData = Map<String, dynamic>.from(state.data);
    final timings = Map<String, dynamic>.from(
      currentData['timings'] as Map<String, dynamic>? ?? {},
    );

    // Ensure day exists in timings
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
}
