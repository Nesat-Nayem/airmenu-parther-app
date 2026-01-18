import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/table_model.dart';
import '../../data/repositories/table_repository.dart';

// Events
abstract class TablesEvent extends Equatable {
  const TablesEvent();
  @override
  List<Object?> get props => [];
}

class LoadTables extends TablesEvent {}

class FilterTables extends TablesEvent {
  final String searchQuery;
  final String? zoneFilter;
  final TableStatus? statusFilter;

  const FilterTables({
    this.searchQuery = '',
    this.zoneFilter,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [searchQuery, zoneFilter, statusFilter];
}

class AddTable extends TablesEvent {
  final TableModel table;
  const AddTable(this.table);
  @override
  List<Object?> get props => [table];
}

class DeleteTable extends TablesEvent {
  final String id;
  const DeleteTable(this.id);
  @override
  List<Object?> get props => [id];
}

// State
class TablesState extends Equatable {
  final List<TableModel> allTables;
  final List<TableModel> filteredTables;
  final bool isLoading;
  final String? error;

  // Current filters
  final String searchQuery;
  final String? zoneFilter;
  final TableStatus? statusFilter;

  const TablesState({
    this.allTables = const [],
    this.filteredTables = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.zoneFilter,
    this.statusFilter,
  });

  TablesState copyWith({
    List<TableModel>? allTables,
    List<TableModel>? filteredTables,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? zoneFilter,
    TableStatus? statusFilter,
  }) {
    return TablesState(
      allTables: allTables ?? this.allTables,
      filteredTables: filteredTables ?? this.filteredTables,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Clear error on new state unless explicitly provided
      searchQuery: searchQuery ?? this.searchQuery,
      zoneFilter: zoneFilter ?? this.zoneFilter,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [
    allTables,
    filteredTables,
    isLoading,
    error,
    searchQuery,
    zoneFilter,
    statusFilter,
  ];
}

class TablesBloc extends Bloc<TablesEvent, TablesState> {
  final TableRepository repository;

  TablesBloc({required this.repository}) : super(const TablesState()) {
    on<LoadTables>(_onLoadTables);
    on<FilterTables>(_onFilterTables);
    on<AddTable>(_onAddTable);
    on<DeleteTable>(_onDeleteTable);
  }

  Future<void> _onLoadTables(
    LoadTables event,
    Emitter<TablesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final tables = await repository.getTables();
      // Apply current filters to the new data
      final filtered = _applyFilters(
        tables,
        state.searchQuery,
        state.zoneFilter,
        state.statusFilter,
      );

      emit(
        state.copyWith(
          allTables: tables,
          filteredTables: filtered,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onFilterTables(FilterTables event, Emitter<TablesState> emit) {
    final filtered = _applyFilters(
      state.allTables,
      event.searchQuery,
      event.zoneFilter,
      event.statusFilter,
    );

    emit(
      state.copyWith(
        filteredTables: filtered,
        searchQuery: event.searchQuery,
        zoneFilter: event.zoneFilter,
        statusFilter: event.statusFilter,
      ),
    );
  }

  Future<void> _onAddTable(AddTable event, Emitter<TablesState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final newTable = await repository.addTable(event.table);
      final updatedList = [newTable, ...state.allTables]; // Add to top

      final filtered = _applyFilters(
        updatedList,
        state.searchQuery,
        state.zoneFilter,
        state.statusFilter,
      );

      emit(
        state.copyWith(
          allTables: updatedList,
          filteredTables: filtered,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteTable(
    DeleteTable event,
    Emitter<TablesState> emit,
  ) async {
    // Optimistic update
    final backupAll = state.allTables;
    final updatedList = state.allTables.where((t) => t.id != event.id).toList();
    final filtered = _applyFilters(
      updatedList,
      state.searchQuery,
      state.zoneFilter,
      state.statusFilter,
    );

    emit(state.copyWith(allTables: updatedList, filteredTables: filtered));

    try {
      await repository.deleteTable(event.id);
    } catch (e) {
      // Revert if failed
      final revertedFiltered = _applyFilters(
        backupAll,
        state.searchQuery,
        state.zoneFilter,
        state.statusFilter,
      );
      emit(
        state.copyWith(
          allTables: backupAll,
          filteredTables: revertedFiltered,
          error: e.toString(),
        ),
      );
    }
  }

  List<TableModel> _applyFilters(
    List<TableModel> tables,
    String query,
    String? zone,
    TableStatus? status,
  ) {
    return tables.where((table) {
      if (query.isNotEmpty) {
        if (!table.tableNumber.toLowerCase().contains(query.toLowerCase())) {
          return false;
        }
      }

      if (zone != null && zone != 'All Zones') {
        if (table.zone != zone) return false;
      }

      if (status != null) {
        if (table.status != status) return false;
      }

      return true;
    }).toList();
  }
}
