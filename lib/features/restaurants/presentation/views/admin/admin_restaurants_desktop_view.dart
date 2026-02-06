import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/admin_restaurants_repository.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/admin/admin_restaurants_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/admin/admin_restaurants_event.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/admin/admin_restaurants_state.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/admin/restaurant_stats_cards.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/admin/restaurant_list_item.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/admin/restaurant_search_bar.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/admin/restaurants_shimmer.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

/// Desktop view for admin restaurants page
class AdminRestaurantsDesktopView extends StatelessWidget {
  const AdminRestaurantsDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminRestaurantsBloc(
        AdminRestaurantsRepository(locator<ApiService>()),
      )..add(const LoadRestaurants()),
      child: const _AdminRestaurantsDesktopContent(),
    );
  }
}

class _AdminRestaurantsDesktopContent extends StatelessWidget {
  const _AdminRestaurantsDesktopContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminRestaurantsBloc, AdminRestaurantsState>(
      builder: (context, state) {
        if (state is AdminRestaurantsLoading) {
          return const RestaurantsShimmer();
        }

        if (state is AdminRestaurantsError) {
          return _buildError(context, state.message);
        }

        if (state is AdminRestaurantsLoaded ||
            state is AdminRestaurantsRefreshing ||
            state is AdminRestaurantsLoadingMore) {
          final stats = state is AdminRestaurantsLoaded
              ? state.stats
              : state is AdminRestaurantsRefreshing
              ? state.stats
              : (state as AdminRestaurantsLoadingMore).stats;

          final restaurants = state is AdminRestaurantsLoaded
              ? state.restaurants
              : state is AdminRestaurantsRefreshing
              ? state.restaurants
              : (state as AdminRestaurantsLoadingMore).restaurants;

          final filters = state is AdminRestaurantsLoaded
              ? state.filters
              : state is AdminRestaurantsRefreshing
              ? state.filters
              : (state as AdminRestaurantsLoadingMore).filters;

          final hasMore = state is AdminRestaurantsLoaded
              ? state.hasMore
              : false;

          return _buildContent(
            context,
            stats: stats,
            restaurants: restaurants,
            filters: filters,
            hasMore: hasMore,
            isRefreshing: state is AdminRestaurantsRefreshing,
            isLoadingMore: state is AdminRestaurantsLoadingMore,
          );
        }

        return const Center(child: RestaurantsShimmer());
      },
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required stats,
    required restaurants,
    required filters,
    required bool hasMore,
    required bool isRefreshing,
    required bool isLoadingMore,
  }) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards
                  RestaurantStatsCards(stats: stats),
                  const SizedBox(height: 24),

                  // Search and filter
                  Row(
                    children: [
                      Expanded(
                        child: RestaurantSearchBar(
                          initialQuery: filters.searchQuery,
                          onSearch: (query) {
                            context.read<AdminRestaurantsBloc>().add(
                              SearchRestaurants(query),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push(AppRoutes.createRestaurant.path).then((
                            value,
                          ) {
                            if (value == true) {
                              context.read<AdminRestaurantsBloc>().add(
                                const LoadRestaurants(),
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Restaurant'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC52031),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Restaurant list
                  if (isRefreshing)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (restaurants.isEmpty)
                    _buildEmptyState()
                  else
                    Column(
                      children: [
                        ...restaurants.map((restaurant) {
                          return RestaurantListItem(
                            restaurant: restaurant,
                            onView: () {
                              context.push(
                                '/restaurants/details',
                                extra: restaurant,
                              );
                            },
                          );
                        }),
                        if (isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (hasMore && !isLoadingMore)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: OutlinedButton(
                                onPressed: () {
                                  context.read<AdminRestaurantsBloc>().add(
                                    const LoadMoreRestaurants(),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Text(
                                  'Load More',
                                  style: AirMenuTextStyle.normal.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No restaurants found',
              style: AirMenuTextStyle.headingH4.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading restaurants',
              style: AirMenuTextStyle.headingH4.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<AdminRestaurantsBloc>().add(
                  const LoadRestaurants(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC52031),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
