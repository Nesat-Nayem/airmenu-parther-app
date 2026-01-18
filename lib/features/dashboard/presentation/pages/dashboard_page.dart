import 'package:airmenuai_partner_app/core/enums/user_role.dart';
import 'package:airmenuai_partner_app/core/services/role_service.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/views/admin/admin_dashboard_desktop_view.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/views/admin/admin_dashboard_mobile_view.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/views/admin/admin_dashboard_tablet_view.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/views/vendor/vendor_dashboard_desktop_view.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/views/vendor/vendor_dashboard_mobile_view.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/views/vendor/vendor_dashboard_tablet_view.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/keys/airmenu_keys.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole?>(
      future: RoleService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userRole = snapshot.data;

        return Responsive(
          key: AirMenuKey.dashboardKey.dashboardResponsiveScreen,
          mobile: userRole == UserRole.admin
              ? AdminDashboardMobileView()
              : VendorDashboardMobileView(),
          tablet: userRole == UserRole.admin
              ? AdminDashboardTabletView()
              : VendorDashboardTabletView(),
          desktop: userRole == UserRole.admin
              ? AdminDashboardDesktopView()
              : VendorDashboardDesktopView(),
        );
      },
    );
  }
}
