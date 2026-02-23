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
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/menu_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/menu/menu_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/menu_repository.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/tables_qr_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/inventory_health_tab.dart';
// import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/billing_tab.dart';
// import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/staff_roles_tab.dart';
// import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/integrations_tab.dart';
// import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/onboarding_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/buffets_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/gallery_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/reviews_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/offers_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/about_tab.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/kitchen_tab.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailsPage({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RestaurantDetailsBloc(
            repository: AdminRestaurantsRepository(locator<ApiService>()),
            restaurant: restaurant,
          )..add(LoadRestaurantDetails(restaurant.id)),
        ),
        BlocProvider(
          create: (context) => MenuBloc(MenuRepository(locator<ApiService>())),
        ),
      ],
      child: _RestaurantDetailsContent(hotelId: restaurant.id),
    );
  }
}

class _RestaurantDetailsContent extends StatelessWidget {
  final String hotelId;
  const _RestaurantDetailsContent({required this.hotelId});

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
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
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
                    
                    // Header with Hero Image
                    DetailsHeader(
                      restaurant: state.restaurant,
                      onEdit: () {
                        // TODO: Navigate to edit restaurant
                      },
                      onDelete: () {
                        // TODO: Show delete confirmation
                      },
                    ),
                    const SizedBox(height: 24),

                    // Tabs
                    SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DetailsTabs(
                          selectedIndex: state.selectedTabIndex,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Tab Content
                    _buildTabContent(context, state),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, RestaurantDetailsLoaded state) {
    switch (state.selectedTabIndex) {
      case 0:
        return OverviewTab(state: state);
      case 1:
        return MenuTab(hotelId: hotelId);
      case 2:
        return TablesQrTab(hotelId: hotelId);
      case 3:
        return InventoryHealthTab(state: state);
      // case 4:
      //   return const BillingTab();
      // case 5:
      //   return const StaffRolesTab();
      // case 6:
      //   return const IntegrationsTab();
      // case 7:
      //   return const OnboardingTab();
      case 4:
        return BuffetsTab(hotelId: hotelId);
      case 5:
        return GalleryTab(
          hotelId: hotelId, 
          hotelName: state.restaurant.name,
          galleryImages: state.restaurant.galleryImages,
          onRefresh: () => context.read<RestaurantDetailsBloc>().add(LoadRestaurantDetails(hotelId)),
        );
      case 6:
        return ReviewsTab(hotelId: hotelId);
      case 7:
        return OffersTab(hotelId: hotelId);
      case 8:
        return AboutTab(hotelId: hotelId);
      case 9:
        return KitchenTab(hotelId: hotelId);
      default:
        return OverviewTab(state: state);
    }
  }
}
