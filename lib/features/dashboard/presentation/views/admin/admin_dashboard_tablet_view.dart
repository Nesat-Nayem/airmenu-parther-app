import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/views/admin/admin_dashboard_desktop_view.dart';

class AdminDashboardTabletView extends StatelessWidget {
  const AdminDashboardTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    // User requested to keep tablet and desktop view same.
    // AdminDashboardDesktopView handles scrolling and layout.
    return const AdminDashboardDesktopView();
  }
}
