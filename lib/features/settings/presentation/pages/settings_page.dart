import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/services/role_service.dart';
import 'package:airmenuai_partner_app/core/enums/user_role.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';

// Admin Views
import '../views/admin/user_settings_desktop_view.dart';
import '../views/admin/user_settings_tablet_view.dart';
import '../views/admin/user_settings_mobile_view.dart';
import '../bloc/user_settings_bloc.dart';
import '../bloc/user_settings_event.dart';

// Vendor Views
import '../views/vendor/vendor_settings_desktop_view.dart';
import '../views/vendor/vendor_settings_tablet_view.dart';
import '../views/vendor/vendor_settings_mobile_view.dart';
import '../bloc/vendor_settings_bloc.dart';
import '../bloc/vendor_settings_event.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole?>(
      future: RoleService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userRole = snapshot.data;
        final isVendor = userRole == UserRole.vendor;

        return Responsive(
          key: const ValueKey('settings_responsive'),

          mobile: isVendor
              ? BlocProvider(
                  create: (context) =>
                      VendorSettingsBloc()..add(const LoadVendorSettings()),
                  child: const VendorSettingsMobileView(),
                )
              : BlocProvider(
                  create: (context) =>
                      UserSettingsBloc()..add(const LoadUserSettings()),
                  child: const UserSettingsMobileView(),
                ),

          tablet: isVendor
              ? BlocProvider(
                  create: (context) =>
                      VendorSettingsBloc()..add(const LoadVendorSettings()),
                  child: const VendorSettingsTabletView(),
                )
              : BlocProvider(
                  create: (context) =>
                      UserSettingsBloc()..add(const LoadUserSettings()),
                  child: const UserSettingsTabletView(),
                ),

          desktop: isVendor
              ? BlocProvider(
                  create: (context) =>
                      VendorSettingsBloc()..add(const LoadVendorSettings()),
                  child: const VendorSettingsDesktopView(),
                )
              : BlocProvider(
                  create: (context) =>
                      UserSettingsBloc()..add(const LoadUserSettings()),
                  child: const UserSettingsDesktopView(),
                ),
        );
      },
    );
  }
}
