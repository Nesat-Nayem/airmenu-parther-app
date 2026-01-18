import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';

/// Base state class for admin restaurants
abstract class AdminRestaurantsState extends Equatable {
  const AdminRestaurantsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminRestaurantsInitial extends AdminRestaurantsState {
  const AdminRestaurantsInitial();
}

/// Loading state
class AdminRestaurantsLoading extends AdminRestaurantsState {
  const AdminRestaurantsLoading();
}

/// Loaded state with data
class AdminRestaurantsLoaded extends AdminRestaurantsState {
  final RestaurantStatsModel stats;
  final List<RestaurantModel> restaurants;
  final RestaurantFiltersModel filters;
  final int currentPage;
  final bool hasMore;
  final int total;

  const AdminRestaurantsLoaded({
    required this.stats,
    required this.restaurants,
    required this.filters,
    required this.currentPage,
    required this.hasMore,
    required this.total,
  });

  @override
  List<Object?> get props => [
    stats,
    restaurants,
    filters,
    currentPage,
    hasMore,
    total,
  ];

  AdminRestaurantsLoaded copyWith({
    RestaurantStatsModel? stats,
    List<RestaurantModel>? restaurants,
    RestaurantFiltersModel? filters,
    int? currentPage,
    bool? hasMore,
    int? total,
  }) {
    return AdminRestaurantsLoaded(
      stats: stats ?? this.stats,
      restaurants: restaurants ?? this.restaurants,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
    );
  }
}

/// Loading more state (for pagination)
class AdminRestaurantsLoadingMore extends AdminRestaurantsState {
  final RestaurantStatsModel stats;
  final List<RestaurantModel> restaurants;
  final RestaurantFiltersModel filters;
  final int currentPage;
  final int total;

  const AdminRestaurantsLoadingMore({
    required this.stats,
    required this.restaurants,
    required this.filters,
    required this.currentPage,
    required this.total,
  });

  @override
  List<Object?> get props => [stats, restaurants, filters, currentPage, total];
}

/// Error state
class AdminRestaurantsError extends AdminRestaurantsState {
  final String message;
  final RestaurantStatsModel? stats;
  final List<RestaurantModel>? restaurants;

  const AdminRestaurantsError({
    required this.message,
    this.stats,
    this.restaurants,
  });

  @override
  List<Object?> get props => [message, stats, restaurants];
}

/// Refreshing state
class AdminRestaurantsRefreshing extends AdminRestaurantsState {
  final RestaurantStatsModel stats;
  final List<RestaurantModel> restaurants;
  final RestaurantFiltersModel filters;

  const AdminRestaurantsRefreshing({
    required this.stats,
    required this.restaurants,
    required this.filters,
  });

  @override
  List<Object?> get props => [stats, restaurants, filters];
}
