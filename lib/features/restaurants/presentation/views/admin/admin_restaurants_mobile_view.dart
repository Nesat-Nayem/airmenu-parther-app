import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/admin_restaurants_repository.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/admin/admin_restaurants_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/admin/admin_restaurants_event.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/admin/admin_restaurants_state.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/admin/restaurant_list_item.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/admin/restaurant_search_bar.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

/// Mobile view for admin restaurants page
class AdminRestaurantsMobileView extends StatelessWidget {
  const AdminRestaurantsMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminRestaurantsBloc(
        AdminRestaurantsRepository(locator<ApiService>()),
      )..add(const LoadRestaurants()),
      child: const _AdminRestaurantsMobileContent(),
    );
  }
}

class _AdminRestaurantsMobileContent extends StatelessWidget {
  const _AdminRestaurantsMobileContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminRestaurantsBloc, AdminRestaurantsState>(
      builder: (context, state) {
        if (state is AdminRestaurantsLoading) {
          return const CircularProgressIndicator();
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

        return const Center(child: CircularProgressIndicator());
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.restaurant,
                      color: Color(0xFFC52031),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Restaurants',
                      style: AirMenuTextStyle.headingH3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<AdminRestaurantsBloc>().add(
                  const RefreshRestaurants(),
                );
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats cards (stacked on mobile)
                    _buildMobileStatsCards(stats),
                    const SizedBox(height: 16),

                    // Search and filter
                    RestaurantSearchBar(
                      initialQuery: filters.searchQuery,
                      onSearch: (query) {
                        context.read<AdminRestaurantsBloc>().add(
                          SearchRestaurants(query),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

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
                            child: const Text('Load More'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatsCards(RestaurantStatsModel stats) {
    final statCards = stats.toStatCards();
    return Column(
      children: statCards.map((card) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(card.icon, size: 24, color: card.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.label,
                      style: AirMenuTextStyle.small.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.value,
                      style: AirMenuTextStyle.headingH3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No restaurants found',
              style: AirMenuTextStyle.headingH4.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your search or filters',
              style: AirMenuTextStyle.small.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
              'Error loading restaurants',
              style: AirMenuTextStyle.headingH4.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AirMenuTextStyle.small.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AdminRestaurantsBloc>().add(
                  const LoadRestaurants(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC52031),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
