import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/admin_restaurants_repository.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/admin/admin_restaurants_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/admin/admin_restaurants_event.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/admin/admin_restaurants_state.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/admin/restaurant_stats_cards.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/admin/restaurant_list_item.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/admin/restaurant_search_bar.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/admin/restaurants_shimmer.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

/// Desktop admin restaurants — Lovable Restaurants Overview look/feel.
/// All bloc/search/filter/pagination/navigation behavior preserved.
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

  static const _canvas = Color(0xFFFCFBF9);
  static const _foreground = Color(0xFF2A3038);
  static const _muted = Color(0xFF7A8494);
  static const _idleBorder = Color(0xFFECE8E6);
  static const _accent = Color(0xFFC52031);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminRestaurantsBloc, AdminRestaurantsState>(
      builder: (context, state) {
        if (state is AdminRestaurantsLoading) {
          return const ColoredBox(
            color: _canvas,
            child: RestaurantsShimmer(),
          );
        }

        if (state is AdminRestaurantsError) {
          return ColoredBox(
            color: _canvas,
            child: _buildError(context, state.message),
          );
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

          final hasMore =
              state is AdminRestaurantsLoaded ? state.hasMore : false;

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

        return const ColoredBox(
          color: _canvas,
          child: Center(child: RestaurantsShimmer()),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required RestaurantStatsModel stats,
    required List<RestaurantModel> restaurants,
    required RestaurantFiltersModel filters,
    required bool hasMore,
    required bool isRefreshing,
    required bool isLoadingMore,
  }) {
    return ColoredBox(
      color: _canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toolbar: search + filter | Add (matches Lovable order)
                  _buildToolbar(context, filters),
                  const SizedBox(height: 20),
                  RestaurantStatsCards(stats: stats),
                  const SizedBox(height: 24),
                  if (isRefreshing)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: _accent),
                      ),
                    )
                  else if (restaurants.isEmpty)
                    _buildEmptyState()
                  else
                    Column(
                      children: [
                        for (var i = 0; i < restaurants.length; i++)
                          RestaurantListItem(
                            restaurant: restaurants[i],
                            onView: () {
                              context
                                  .push(
                                    '/restaurants/details',
                                    extra: restaurants[i],
                                  )
                                  .then((_) {
                                if (context.mounted) {
                                  context.read<AdminRestaurantsBloc>().add(
                                        const RefreshRestaurants(),
                                      );
                                }
                              });
                            },
                          ),
                        if (isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(color: _accent),
                            ),
                          ),
                        if (hasMore && !isLoadingMore)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: Center(
                              child: OutlinedButton(
                                onPressed: () {
                                  context.read<AdminRestaurantsBloc>().add(
                                        const LoadMoreRestaurants(),
                                      );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _foreground,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(color: _idleBorder),
                                ),
                                child: Text(
                                  'Load More',
                                  style: GoogleFonts.sora(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
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

  Widget _buildToolbar(BuildContext context, RestaurantFiltersModel filters) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: RestaurantSearchBar(
                    initialQuery: filters.searchQuery,
                    onSearch: (query) {
                      context
                          .read<AdminRestaurantsBloc>()
                          .add(SearchRestaurants(query));
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _FilterButton(
                filters: filters,
                onApply: (next) {
                  context
                      .read<AdminRestaurantsBloc>()
                      .add(FilterRestaurants(next));
                },
                onClear: () {
                  context
                      .read<AdminRestaurantsBloc>()
                      .add(const ClearFilters());
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _GradientPillButton(
          label: 'Add Restaurant',
          icon: Icons.add,
          onPressed: () {
            context.push(AppRoutes.createRestaurant.path).then((value) {
              if (value == true && context.mounted) {
                context
                    .read<AdminRestaurantsBloc>()
                    .add(const LoadRestaurants());
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F1EF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.restaurant_outlined,
                size: 36,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No restaurants found',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _muted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.sora(
                fontSize: 13,
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
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _muted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.sora(
                fontSize: 13,
                color: const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _GradientPillButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: () {
                context
                    .read<AdminRestaurantsBloc>()
                    .add(const LoadRestaurants());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientPillButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const _GradientPillButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  static const _accent = Color(0xFFC52031);
  static const _accentEnd = Color(0xFFEA580C);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_accent, _accentEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final RestaurantFiltersModel filters;
  final ValueChanged<RestaurantFiltersModel> onApply;
  final VoidCallback onClear;

  const _FilterButton({
    required this.filters,
    required this.onApply,
    required this.onClear,
  });

  static const _idleBorder = Color(0xFFECE8E6);
  static const _muted = Color(0xFF7A8494);
  static const _foreground = Color(0xFF2A3038);
  static const _accent = Color(0xFFC52031);

  @override
  Widget build(BuildContext context) {
    final active = filters.hasActiveFilters;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openFilterDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: active
                ? _accent.withValues(alpha: 0.08)
                : const Color(0xFFF7F5F3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? _accent.withValues(alpha: 0.35)
                  : _idleBorder,
            ),
          ),
          child: Icon(
            Icons.tune_rounded,
            size: 20,
            color: active ? _accent : _muted,
          ),
        ),
      ),
    );
  }

  Future<void> _openFilterDialog(BuildContext context) async {
    var sortBy = filters.sortBy ?? 'createdAt';
    var sortOrder = filters.sortOrder ?? 'desc';
    bool? isActive = filters.isActive;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Filters',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _foreground,
                ),
              ),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: isActive == null,
                          onSelected: (_) => setLocal(() => isActive = null),
                        ),
                        ChoiceChip(
                          label: const Text('Active'),
                          selected: isActive == true,
                          onSelected: (_) => setLocal(() => isActive = true),
                        ),
                        ChoiceChip(
                          label: const Text('Inactive'),
                          selected: isActive == false,
                          onSelected: (_) => setLocal(() => isActive = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sort by',
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      key: ValueKey('sortBy-$sortBy'),
                      initialValue: sortBy,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'createdAt',
                          child: Text('Created date'),
                        ),
                        DropdownMenuItem(
                          value: 'name',
                          child: Text('Name'),
                        ),
                        DropdownMenuItem(
                          value: 'rating',
                          child: Text('Rating'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setLocal(() => sortBy = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('sortOrder-$sortOrder'),
                      initialValue: sortOrder,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'desc',
                          child: Text('Descending'),
                        ),
                        DropdownMenuItem(
                          value: 'asc',
                          child: Text('Ascending'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setLocal(() => sortOrder = v);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onClear();
                  },
                  child: Text(
                    'Clear',
                    style: GoogleFonts.sora(color: _muted),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Build fresh model so null isActive ("All") is applied
                    onApply(
                      RestaurantFiltersModel(
                        searchQuery: filters.searchQuery,
                        cuisine: filters.cuisine,
                        isActive: isActive,
                        rating: filters.rating,
                        sortBy: sortBy,
                        sortOrder: sortOrder,
                      ),
                    );
                  },
                  child: Text(
                    'Apply',
                    style: GoogleFonts.sora(
                      color: _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
