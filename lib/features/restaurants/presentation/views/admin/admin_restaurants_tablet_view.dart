import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/views/admin/admin_restaurants_desktop_view.dart';

/// Tablet view for admin restaurants page
/// Uses desktop view with adjusted padding for tablet screens
class AdminRestaurantsTabletView extends StatelessWidget {
  const AdminRestaurantsTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    // For tablet, we can reuse the desktop view as it's responsive enough
    return const AdminRestaurantsDesktopView();
  }
}
