import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PriceComparisonExtStatus { initial, loading, loaded, error }

class PriceComparisonExtState extends Equatable {
  final List<PriceComparisonItem> items;
  final PriceComparisonDetail? selectedDetail;
  final String selectedItemId;
  final PriceComparisonExtStatus status;
  final String errorMessage;
  final double totalPotentialSavings;
  final String searchQuery;
  final String categoryFilter;

  const PriceComparisonExtState({
    this.items = const [],
    this.selectedDetail,
    this.selectedItemId = '',
    this.status = PriceComparisonExtStatus.initial,
    this.errorMessage = '',
    this.totalPotentialSavings = 0,
    this.searchQuery = '',
    this.categoryFilter = 'All',
  });

  // Distinct, non-empty material categories present in the loaded data — drives
  // the dynamic category filter.
  List<String> get categories {
    final cats = items.map((i) => i.category).where((c) => c.isNotEmpty).toSet().toList()..sort();
    return cats;
  }

  // Items after applying the category filter and the name search box.
  List<PriceComparisonItem> get filteredItems {
    var list = items;
    if (categoryFilter != 'All') {
      list = list.where((i) => i.category == categoryFilter).toList();
    }
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((i) => i.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  PriceComparisonExtState copyWith({
    List<PriceComparisonItem>? items,
    PriceComparisonDetail? selectedDetail,
    String? selectedItemId,
    PriceComparisonExtStatus? status,
    String? errorMessage,
    double? totalPotentialSavings,
    String? searchQuery,
    String? categoryFilter,
  }) {
    return PriceComparisonExtState(
      items: items ?? this.items,
      selectedDetail: selectedDetail ?? this.selectedDetail,
      selectedItemId: selectedItemId ?? this.selectedItemId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      totalPotentialSavings: totalPotentialSavings ?? this.totalPotentialSavings,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }

  @override
  List<Object?> get props => [
        items,
        selectedDetail,
        selectedItemId,
        status,
        errorMessage,
        totalPotentialSavings,
        searchQuery,
        categoryFilter,
      ];
}

class PriceComparisonExtCubit extends Cubit<PriceComparisonExtState> {
  final InventoryRepository _repo;

  PriceComparisonExtCubit(this._repo) : super(const PriceComparisonExtState());

  Future<void> loadSummary() async {
    emit(state.copyWith(status: PriceComparisonExtStatus.loading));
    final result = await _repo.getPriceComparisonSummary();
    if (result is DataSuccess<List<PriceComparisonItem>>) {
      final items = result.data!;
      final savings = items.fold<double>(0, (s, i) => s + i.potentialSavings);
      final firstId = items.isNotEmpty ? items.first.id : '';
      emit(state.copyWith(
        items: items,
        totalPotentialSavings: savings,
        status: PriceComparisonExtStatus.loaded,
        selectedItemId: firstId,
      ));
      if (firstId.isNotEmpty) selectItem(firstId);
    } else {
      emit(state.copyWith(status: PriceComparisonExtStatus.error, errorMessage: 'Failed to load price comparison'));
    }
  }

  Future<void> selectItem(String materialId) async {
    emit(state.copyWith(selectedItemId: materialId));
    final result = await _repo.getPriceComparisonForMaterial(materialId);
    if (result is DataSuccess<PriceComparisonDetail>) {
      emit(state.copyWith(selectedDetail: result.data));
    }
  }

  void setSearchQuery(String query) => emit(state.copyWith(searchQuery: query));

  void setCategoryFilter(String category) => emit(state.copyWith(categoryFilter: category));
}
