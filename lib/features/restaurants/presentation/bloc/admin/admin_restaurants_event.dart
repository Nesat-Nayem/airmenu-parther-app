import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';

/// Base event class for admin restaurants
abstract class AdminRestaurantsEvent extends Equatable {
  const AdminRestaurantsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load initial restaurants data
class LoadRestaurants extends AdminRestaurantsEvent {
  const LoadRestaurants();
}

/// Event to refresh restaurants data
class RefreshRestaurants extends AdminRestaurantsEvent {
  const RefreshRestaurants();
}

/// Event to search restaurants
class SearchRestaurants extends AdminRestaurantsEvent {
  final String query;

  const SearchRestaurants(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to apply filters
class FilterRestaurants extends AdminRestaurantsEvent {
  final RestaurantFiltersModel filters;

  const FilterRestaurants(this.filters);

  @override
  List<Object?> get props => [filters];
}

/// Event to clear all filters
class ClearFilters extends AdminRestaurantsEvent {
  const ClearFilters();
}

/// Event to load more restaurants (pagination)
class LoadMoreRestaurants extends AdminRestaurantsEvent {
  const LoadMoreRestaurants();
}

/// Event to update restaurant status
class UpdateRestaurantStatus extends AdminRestaurantsEvent {
  final String restaurantId;
  final String status;

  const UpdateRestaurantStatus({
    required this.restaurantId,
    required this.status,
  });

  @override
  List<Object?> get props => [restaurantId, status];
}

/// Event to change sort order
class ChangeSortOrder extends AdminRestaurantsEvent {
  final String sortBy;
  final String sortOrder;

  const ChangeSortOrder({required this.sortBy, required this.sortOrder});

  @override
  List<Object?> get props => [sortBy, sortOrder];
}

/// Event to delete a restaurant
class DeleteRestaurant extends AdminRestaurantsEvent {
  final String restaurantId;

  const DeleteRestaurant({required this.restaurantId});

  @override
  List<Object?> get props => [restaurantId];
}
