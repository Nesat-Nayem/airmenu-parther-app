import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/admin_restaurants_repository.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'admin_restaurants_event.dart';
import 'admin_restaurants_state.dart';

/// BLoC for managing admin restaurants state
class AdminRestaurantsBloc
    extends Bloc<AdminRestaurantsEvent, AdminRestaurantsState> {
  final AdminRestaurantsRepository _repository;

  AdminRestaurantsBloc(this._repository)
    : super(const AdminRestaurantsInitial()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<RefreshRestaurants>(_onRefreshRestaurants);
    on<SearchRestaurants>(_onSearchRestaurants);
    on<FilterRestaurants>(_onFilterRestaurants);
    on<ClearFilters>(_onClearFilters);
    on<LoadMoreRestaurants>(_onLoadMoreRestaurants);
    on<UpdateRestaurantStatus>(_onUpdateRestaurantStatus);
    on<ChangeSortOrder>(_onChangeSortOrder);
    on<DeleteRestaurant>(_onDeleteRestaurant);
  }

  /// Handle initial load
  Future<void> _onLoadRestaurants(
    LoadRestaurants event,
    Emitter<AdminRestaurantsState> emit,
  ) async {
    emit(const AdminRestaurantsLoading());

    try {
      // Fetch stats and restaurants in parallel
      final statsResult = await _repository.getRestaurantStats();
      final restaurantsResult = await _repository.getRestaurants(
        page: 1,
        pageSize: 20,
      );

      emit(
        AdminRestaurantsLoaded(
          stats: statsResult,
          restaurants: restaurantsResult.restaurants,
          filters: RestaurantFiltersModel(),
          currentPage: 1,
          hasMore: restaurantsResult.hasMore,
          total: restaurantsResult.total,
        ),
      );
    } catch (e) {
      emit(AdminRestaurantsError(message: e.toString()));
    }
  }

  /// Handle refresh
  Future<void> _onRefreshRestaurants(
    RefreshRestaurants event,
    Emitter<AdminRestaurantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminRestaurantsLoaded) {
      emit(
        AdminRestaurantsRefreshing(
          stats: currentState.stats,
          restaurants: currentState.restaurants,
          filters: currentState.filters,
        ),
      );

      try {
        final statsResult = await _repository.getRestaurantStats();
        final restaurantsResult = await _repository.getRestaurants(
          filters: currentState.filters,
          page: 1,
          pageSize: 20,
        );

        emit(
          AdminRestaurantsLoaded(
            stats: statsResult,
            restaurants: restaurantsResult.restaurants,
            filters: currentState.filters,
            currentPage: 1,
            hasMore: restaurantsResult.hasMore,
            total: restaurantsResult.total,
          ),
        );
      } catch (e) {
        emit(
          AdminRestaurantsError(
            message: e.toString(),
            stats: currentState.stats,
            restaurants: currentState.restaurants,
          ),
        );
      }
    }
  }

  /// Handle search
  Future<void> _onSearchRestaurants(
    SearchRestaurants event,
    Emitter<AdminRestaurantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminRestaurantsLoaded) {
      final newFilters = currentState.filters.copyWith(
        searchQuery: event.query.isEmpty ? null : event.query,
      );

      // Use refreshing state instead of loading to keep stats visible
      emit(
        AdminRestaurantsRefreshing(
          stats: currentState.stats,
          restaurants: currentState.restaurants,
          filters: newFilters,
        ),
      );

      try {
        final restaurantsResult = await _repository.getRestaurants(
          filters: newFilters,
          page: 1,
          pageSize: 20,
        );

        emit(
          currentState.copyWith(
            restaurants: restaurantsResult.restaurants,
            filters: newFilters,
            currentPage: 1,
            hasMore: restaurantsResult.hasMore,
            total: restaurantsResult.total,
          ),
        );
      } catch (e) {
        emit(
          AdminRestaurantsError(
            message: e.toString(),
            stats: currentState.stats,
            restaurants: currentState.restaurants,
          ),
        );
      }
    }
  }

  /// Handle filter
  Future<void> _onFilterRestaurants(
    FilterRestaurants event,
    Emitter<AdminRestaurantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminRestaurantsLoaded) {
      emit(
        AdminRestaurantsRefreshing(
          stats: currentState.stats,
          restaurants: currentState.restaurants,
          filters: event.filters,
        ),
      );

      try {
        final restaurantsResult = await _repository.getRestaurants(
          filters: event.filters,
          page: 1,
          pageSize: 20,
        );

        emit(
          currentState.copyWith(
            restaurants: restaurantsResult.restaurants,
            filters: event.filters,
            currentPage: 1,
            hasMore: restaurantsResult.hasMore,
            total: restaurantsResult.total,
          ),
        );
      } catch (e) {
        emit(
          AdminRestaurantsError(
            message: e.toString(),
            stats: currentState.stats,
            restaurants: currentState.restaurants,
          ),
        );
      }
    }
  }

  /// Handle clear filters
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<AdminRestaurantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminRestaurantsLoaded) {
      emit(
        AdminRestaurantsRefreshing(
          stats: currentState.stats,
          restaurants: currentState.restaurants,
          filters: RestaurantFiltersModel(),
        ),
      );

      try {
        final restaurantsResult = await _repository.getRestaurants(
          page: 1,
          pageSize: 20,
        );

        emit(
          currentState.copyWith(
            restaurants: restaurantsResult.restaurants,
            filters: RestaurantFiltersModel(),
            currentPage: 1,
            hasMore: restaurantsResult.hasMore,
            total: restaurantsResult.total,
          ),
        );
      } catch (e) {
        emit(
          AdminRestaurantsError(
            message: e.toString(),
            stats: currentState.stats,
            restaurants: currentState.restaurants,
          ),
        );
      }
    }
  }

  /// Handle load more (pagination)
  Future<void> _onLoadMoreRestaurants(
    LoadMoreRestaurants event,
    Emitter<AdminRestaurantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminRestaurantsLoaded && currentState.hasMore) {
      emit(
        AdminRestaurantsLoadingMore(
          stats: currentState.stats,
          restaurants: currentState.restaurants,
          filters: currentState.filters,
          currentPage: currentState.currentPage,
          total: currentState.total,
        ),
      );

      try {
        final nextPage = currentState.currentPage + 1;
        final restaurantsResult = await _repository.getRestaurants(
          filters: currentState.filters,
          page: nextPage,
          pageSize: 20,
        );

        emit(
          AdminRestaurantsLoaded(
            stats: currentState.stats,
            restaurants: [
              ...currentState.restaurants,
              ...restaurantsResult.restaurants,
            ],
            filters: currentState.filters,
            currentPage: nextPage,
            hasMore: restaurantsResult.hasMore,
            total: restaurantsResult.total,
          ),
        );
      } catch (e) {
        emit(
          AdminRestaurantsError(
            message: e.toString(),
            stats: currentState.stats,
            restaurants: currentState.restaurants,
          ),
        );
      }
    }
  }

  /// Handle update restaurant status
  Future<void> _onUpdateRestaurantStatus(
    UpdateRestaurantStatus event,
    Emitter<AdminRestaurantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminRestaurantsLoaded) {
      try {
        await _repository.updateRestaurantStatus(
          restaurantId: event.restaurantId,
          status: event.status,
        );

        // Refresh the list
        add(const RefreshRestaurants());
      } catch (e) {
        emit(
          AdminRestaurantsError(
            message: 'Failed to update restaurant status: $e',
            stats: currentState.stats,
            restaurants: currentState.restaurants,
          ),
        );
      }
    }
  }

  /// Handle change sort order
  Future<void> _onChangeSortOrder(
    ChangeSortOrder event,
    Emitter<AdminRestaurantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminRestaurantsLoaded) {
      final newFilters = currentState.filters.copyWith(
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );

      emit(const AdminRestaurantsLoading());

      try {
        final restaurantsResult = await _repository.getRestaurants(
          filters: newFilters,
          page: 1,
          pageSize: 20,
        );

        emit(
          currentState.copyWith(
            restaurants: restaurantsResult.restaurants,
            filters: newFilters,
            currentPage: 1,
            hasMore: restaurantsResult.hasMore,
            total: restaurantsResult.total,
          ),
        );
      } catch (e) {
        emit(
          AdminRestaurantsError(
            message: e.toString(),
            stats: currentState.stats,
            restaurants: currentState.restaurants,
          ),
        );
      }
    }
  }

  /// Handle delete restaurant
  Future<void> _onDeleteRestaurant(
    DeleteRestaurant event,
    Emitter<AdminRestaurantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminRestaurantsLoaded) {
      try {
        await _repository.deleteRestaurant(restaurantId: event.restaurantId);

        // Refresh the list after deletion
        add(const RefreshRestaurants());
      } catch (e) {
        emit(
          AdminRestaurantsError(
            message: 'Failed to delete restaurant: $e',
            stats: currentState.stats,
            restaurants: currentState.restaurants,
          ),
        );
      }
    }
  }
}
