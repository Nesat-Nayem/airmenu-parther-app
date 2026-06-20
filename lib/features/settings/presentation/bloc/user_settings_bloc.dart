import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item.dart';
import 'package:airmenuai_partner_app/core/services/vendor_nav_menu_flags_service.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
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

    try {
      await locator<VendorNavMenuFlagsService>().load(force: true);
    } catch (_) {}

    final mockStats = {
      'adminUsers': 24,
      'rolesDefined': 8,
      'featureFlags': vendorNavMenuFeatureFlags.length,
      'configurations': 156,
    };

    emit(
      state.copyWith(
        status: UserSettingsStatus.success,
        stats: mockStats,
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
