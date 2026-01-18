import 'package:airmenuai_partner_app/core/enums/user_role.dart';
import 'package:airmenuai_partner_app/core/services/role_service.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/views/admin/admin_restaurants_desktop_view.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/views/admin/admin_restaurants_mobile_view.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/views/admin/admin_restaurants_tablet_view.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/keys/airmenu_keys.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class RestaurantsPage extends StatelessWidget {
  const RestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole?>(
      future: RoleService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userRole = snapshot.data;

        // For now, only admin view is implemented
        // TODO: Implement vendor view when needed
        if (userRole == UserRole.admin) {
          return Responsive(
            key: AirMenuKey.restaurantsKey.restaurantsResponsiveScreen,
            mobile: AdminRestaurantsMobileView(),
            tablet: AdminRestaurantsTabletView(),
            desktop: AdminRestaurantsDesktopView(),
          );
        }

        // Vendor view placeholder
        return Center(
          child: Text(
            'Vendor Restaurants View\nComing Soon',
            style: AirMenuTextStyle.headingH3,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
