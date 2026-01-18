import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/admin_restaurants_repository.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_event.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_state.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/details_header.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/details_tabs.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/overview_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/menu_issues_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/tables_qr_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/inventory_health_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/billing_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/staff_roles_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/integrations_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/onboarding_tab.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailsPage({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RestaurantDetailsBloc(
        repository: AdminRestaurantsRepository(locator<ApiService>()),
        restaurant: restaurant,
      )..add(LoadRestaurantDetails(restaurant.id)),
      child: const _RestaurantDetailsContent(),
    );
  }
}

class _RestaurantDetailsContent extends StatelessWidget {
  const _RestaurantDetailsContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocBuilder<RestaurantDetailsBloc, RestaurantDetailsState>(
        builder: (context, state) {
          if (state is RestaurantDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RestaurantDetailsError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is RestaurantDetailsLoaded) {
            return Column(
              children: [
                // Back Button & Header Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF6B7280),
                        ),
                        label: Text(
                          'Back to Restaurants',
                          style: AirMenuTextStyle.normal.copyWith(
                            color: const Color(0xFF111827),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DetailsHeader(restaurant: state.restaurant),
                    ],
                  ),
                ),

                // Tabs & Content
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: DetailsTabs(
                          selectedIndex: state.selectedTabIndex,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: _buildTabContent(state),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTabContent(RestaurantDetailsLoaded state) {
    switch (state.selectedTabIndex) {
      case 0:
        return OverviewTab(state: state);
      case 1:
        return MenuIssuesTab(state: state);
      case 2:
        return TablesQrTab(state: state);
      case 3:
        return InventoryHealthTab(state: state);
      case 4:
        return const BillingTab();
      case 5:
        return const StaffRolesTab();
      case 6:
        return const IntegrationsTab();
      case 7:
        return const OnboardingTab();
      default:
        return OverviewTab(state: state);
    }
  }
}
