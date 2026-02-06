import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_settings_event.dart';
import 'user_settings_state.dart';

class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  UserSettingsBloc() : super(const UserSettingsState()) {
    on<LoadUserSettings>(_onLoadUserSettings);
    on<ChangeSettingsTab>(_onChangeSettingsTab);
    on<ToggleFeatureFlag>(_onToggleFeatureFlag);
  }

  Future<void> _onLoadUserSettings(
    LoadUserSettings event,
    Emitter<UserSettingsState> emit,
  ) async {
    emit(state.copyWith(status: UserSettingsStatus.loading));

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock Data
    final mockStats = {
      'adminUsers': 24,
      'rolesDefined': 8,
      'featureFlags': 32,
      'configurations': 156,
    };

    // TODO: Replace with real repository calls
    emit(
      state.copyWith(
        status: UserSettingsStatus.success,
        stats: mockStats,
        // Add other mocked lists here later
      ),
    );
  }

  void _onChangeSettingsTab(
    ChangeSettingsTab event,
    Emitter<UserSettingsState> emit,
  ) {
    emit(state.copyWith(currentTabIndex: event.tabIndex));
  }

  void _onToggleFeatureFlag(
    ToggleFeatureFlag event,
    Emitter<UserSettingsState> emit,
  ) {
    // TODO: Implement toggle logic
  }
}
