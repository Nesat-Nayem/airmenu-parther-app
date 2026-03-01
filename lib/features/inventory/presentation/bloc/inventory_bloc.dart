import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ─── Events ────────────────────────────────────────────────────────────────────

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadInventory extends InventoryEvent {}

class RefreshInventory extends InventoryEvent {}

class UpdateSearchQuery extends InventoryEvent {
  final String query;
  const UpdateSearchQuery(this.query);
  @override
  List<Object?> get props => [query];
}

class UpdateCategoryFilter extends InventoryEvent {
  final String category;
  const UpdateCategoryFilter(this.category);
  @override
  List<Object?> get props => [category];
}

class UpdateStatusFilter extends InventoryEvent {
  final String status;
  const UpdateStatusFilter(this.status);
  @override
  List<Object?> get props => [status];
}

class ToggleCompactView extends InventoryEvent {}

class ToggleAnalytics extends InventoryEvent {}

// Material CRUD
class AddMaterial extends InventoryEvent {
  final Map<String, dynamic> data;
  const AddMaterial(this.data);
  @override
  List<Object?> get props => [data];
}

class EditMaterial extends InventoryEvent {
  final String id;
  final Map<String, dynamic> data;
  const EditMaterial(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteMaterial extends InventoryEvent {
  final String id;
  const DeleteMaterial(this.id);
  @override
  List<Object?> get props => [id];
}

// Transaction
class CreateTransaction extends InventoryEvent {
  final Map<String, dynamic> data;
  const CreateTransaction(this.data);
  @override
  List<Object?> get props => [data];
}

// Recipes
class LoadRecipes extends InventoryEvent {}

class AddRecipe extends InventoryEvent {
  final Map<String, dynamic> data;
  const AddRecipe(this.data);
  @override
  List<Object?> get props => [data];
}

class EditRecipe extends InventoryEvent {
  final String id;
  final Map<String, dynamic> data;
  const EditRecipe(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteRecipe extends InventoryEvent {
  final String id;
  const DeleteRecipe(this.id);
  @override
  List<Object?> get props => [id];
}

// ─── State ─────────────────────────────────────────────────────────────────────

class InventoryState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final List<InventoryItem> items;
  final List<RecipeModel> recipes;
  final InventoryAnalytics analytics;
  final String searchQuery;
  final String categoryFilter;
  final String statusFilter;
  final bool isCompactView;
  final bool showAnalytics;
  final String? errorMessage;
  final String? successMessage;

  const InventoryState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.items = const [],
    this.recipes = const [],
    this.analytics = InventoryAnalytics.empty,
    this.searchQuery = '',
    this.categoryFilter = 'All',
    this.statusFilter = 'All',
    this.isCompactView = false,
    this.showAnalytics = false,
    this.errorMessage,
    this.successMessage,
  });

  // ── Derived stats ────────────────────────────────────────────────────────────

  int get totalItems => items.length;
  int get lowStockCount => items.where((i) => i.status == StockStatus.low || i.status == StockStatus.critical).length;
  int get criticalCount => items.where((i) => i.status == StockStatus.critical).length;

  List<String> get categories {
    final cats = items.map((i) => i.category).where((c) => c.isNotEmpty).toSet().toList()..sort();
    return cats;
  }

  List<InventoryItem> get filteredItems {
    var filtered = items;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((item) =>
          item.name.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.sku.toLowerCase().contains(q)).toList();
    }
    if (categoryFilter != 'All') {
      filtered = filtered.where((item) => item.category == categoryFilter).toList();
    }
    if (statusFilter != 'All') {
      filtered = filtered.where((item) {
        switch (statusFilter) {
          case 'Critical': return item.status == StockStatus.critical;
          case 'Low': return item.status == StockStatus.low;
          case 'Healthy': return item.status == StockStatus.healthy;
          default: return true;
        }
      }).toList();
    }
    return filtered;
  }

  InventoryState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    List<InventoryItem>? items,
    List<RecipeModel>? recipes,
    InventoryAnalytics? analytics,
    String? searchQuery,
    String? categoryFilter,
    String? statusFilter,
    bool? isCompactView,
    bool? showAnalytics,
    String? errorMessage,
    String? successMessage,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      items: items ?? this.items,
      recipes: recipes ?? this.recipes,
      analytics: analytics ?? this.analytics,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      isCompactView: isCompactView ?? this.isCompactView,
      showAnalytics: showAnalytics ?? this.showAnalytics,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading, isActionLoading, items, recipes, analytics,
    searchQuery, categoryFilter, statusFilter,
    isCompactView, showAnalytics, errorMessage, successMessage,
  ];
}

// ─── Bloc ──────────────────────────────────────────────────────────────────────

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _repo;

  InventoryBloc(this._repo) : super(const InventoryState()) {
    on<LoadInventory>(_onLoad);
    on<RefreshInventory>((_, emit) => _onLoad(LoadInventory(), emit));
    on<UpdateSearchQuery>((e, emit) => emit(state.copyWith(searchQuery: e.query)));
    on<UpdateCategoryFilter>((e, emit) => emit(state.copyWith(categoryFilter: e.category)));
    on<UpdateStatusFilter>((e, emit) => emit(state.copyWith(statusFilter: e.status)));
    on<ToggleCompactView>((_, emit) => emit(state.copyWith(isCompactView: !state.isCompactView)));
    on<ToggleAnalytics>((_, emit) => emit(state.copyWith(showAnalytics: !state.showAnalytics)));
    on<AddMaterial>(_onAddMaterial);
    on<EditMaterial>(_onEditMaterial);
    on<DeleteMaterial>(_onDeleteMaterial);
    on<CreateTransaction>(_onCreateTransaction);
    on<LoadRecipes>(_onLoadRecipes);
    on<AddRecipe>(_onAddRecipe);
    on<EditRecipe>(_onEditRecipe);
    on<DeleteRecipe>(_onDeleteRecipe);
  }

  Future<void> _onLoad(LoadInventory event, Emitter<InventoryState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final materialsRes = await _repo.getMaterials();
    final analyticsRes = await _repo.getOverviewReport();

    if (materialsRes is DataSuccess<List<InventoryItem>>) {
      final analytics = analyticsRes is DataSuccess<InventoryAnalytics>
          ? analyticsRes.data!
          : InventoryAnalytics.empty;
      emit(state.copyWith(
        isLoading: false,
        items: materialsRes.data!,
        analytics: analytics,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: materialsRes.error?.message ?? 'Failed to load inventory',
      ));
    }
  }

  Future<void> _onAddMaterial(AddMaterial event, Emitter<InventoryState> emit) async {
    emit(state.copyWith(isActionLoading: true, errorMessage: null, successMessage: null));
    final res = await _repo.createMaterial(event.data);
    if (res is DataSuccess<InventoryItem>) {
      final updated = [res.data!, ...state.items];
      emit(state.copyWith(isActionLoading: false, items: updated, successMessage: 'Material added'));
    } else {
      emit(state.copyWith(isActionLoading: false, errorMessage: res.error?.message ?? 'Failed to add material'));
    }
  }

  Future<void> _onEditMaterial(EditMaterial event, Emitter<InventoryState> emit) async {
    emit(state.copyWith(isActionLoading: true, errorMessage: null, successMessage: null));
    final res = await _repo.updateMaterial(event.id, event.data);
    if (res is DataSuccess<InventoryItem>) {
      final updated = state.items.map((i) => i.id == event.id ? res.data! : i).toList();
      emit(state.copyWith(isActionLoading: false, items: updated, successMessage: 'Material updated'));
    } else {
      emit(state.copyWith(isActionLoading: false, errorMessage: res.error?.message ?? 'Failed to update material'));
    }
  }

  Future<void> _onDeleteMaterial(DeleteMaterial event, Emitter<InventoryState> emit) async {
    emit(state.copyWith(isActionLoading: true, errorMessage: null, successMessage: null));
    final res = await _repo.deleteMaterial(event.id);
    if (res is DataSuccess<bool>) {
      final updated = state.items.where((i) => i.id != event.id).toList();
      emit(state.copyWith(isActionLoading: false, items: updated, successMessage: 'Material deleted'));
    } else {
      emit(state.copyWith(isActionLoading: false, errorMessage: res.error?.message ?? 'Failed to delete material'));
    }
  }

  Future<void> _onCreateTransaction(CreateTransaction event, Emitter<InventoryState> emit) async {
    emit(state.copyWith(isActionLoading: true, errorMessage: null, successMessage: null));
    final res = await _repo.createTransaction(event.data);
    if (res is DataSuccess<bool>) {
      // Reload materials to reflect updated stock
      final materialsRes = await _repo.getMaterials();
      if (materialsRes is DataSuccess<List<InventoryItem>>) {
        emit(state.copyWith(isActionLoading: false, items: materialsRes.data!, successMessage: 'Stock updated'));
      } else {
        emit(state.copyWith(isActionLoading: false, successMessage: 'Stock updated'));
      }
    } else {
      emit(state.copyWith(isActionLoading: false, errorMessage: res.error?.message ?? 'Failed to update stock'));
    }
  }

  Future<void> _onLoadRecipes(LoadRecipes event, Emitter<InventoryState> emit) async {
    final res = await _repo.getRecipes();
    if (res is DataSuccess<List<RecipeModel>>) {
      emit(state.copyWith(recipes: res.data!));
    }
  }

  Future<void> _onAddRecipe(AddRecipe event, Emitter<InventoryState> emit) async {
    emit(state.copyWith(isActionLoading: true, errorMessage: null, successMessage: null));
    final res = await _repo.createRecipe(event.data);
    if (res is DataSuccess<RecipeModel>) {
      emit(state.copyWith(isActionLoading: false, recipes: [res.data!, ...state.recipes], successMessage: 'Recipe saved'));
    } else {
      emit(state.copyWith(isActionLoading: false, errorMessage: res.error?.message ?? 'Failed to save recipe'));
    }
  }

  Future<void> _onEditRecipe(EditRecipe event, Emitter<InventoryState> emit) async {
    emit(state.copyWith(isActionLoading: true, errorMessage: null, successMessage: null));
    final res = await _repo.updateRecipe(event.id, event.data);
    if (res is DataSuccess<RecipeModel>) {
      final updated = state.recipes.map((r) => r.id == event.id ? res.data! : r).toList();
      emit(state.copyWith(isActionLoading: false, recipes: updated, successMessage: 'Recipe updated'));
    } else {
      emit(state.copyWith(isActionLoading: false, errorMessage: res.error?.message ?? 'Failed to update recipe'));
    }
  }

  Future<void> _onDeleteRecipe(DeleteRecipe event, Emitter<InventoryState> emit) async {
    emit(state.copyWith(isActionLoading: true, errorMessage: null, successMessage: null));
    final res = await _repo.deleteRecipe(event.id);
    if (res is DataSuccess<bool>) {
      final updated = state.recipes.where((r) => r.id != event.id).toList();
      emit(state.copyWith(isActionLoading: false, recipes: updated, successMessage: 'Recipe deleted'));
    } else {
      emit(state.copyWith(isActionLoading: false, errorMessage: res.error?.message ?? 'Failed to delete recipe'));
    }
  }
}
