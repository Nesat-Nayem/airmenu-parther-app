import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/table_model.dart';
import '../../data/models/zone_model.dart';
import '../../data/repositories/table_repository.dart';
import '../../data/repositories/zone_repository.dart';

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

class UpdateTable extends TablesEvent {
  final TableModel table;
  const UpdateTable(this.table);
  @override
  List<Object?> get props => [table];
}

class DeleteTable extends TablesEvent {
  final String id;
  const DeleteTable(this.id);
  @override
  List<Object?> get props => [id];
}

// Zone Events
class LoadZones extends TablesEvent {}

class CreateZone extends TablesEvent {
  final String name;
  final String description;
  const CreateZone({required this.name, this.description = ''});
  @override
  List<Object?> get props => [name, description];
}

class UpdateZone extends TablesEvent {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  const UpdateZone({
    required this.id,
    required this.name,
    this.description = '',
    this.isActive = true,
  });
  @override
  List<Object?> get props => [id, name, description, isActive];
}

class DeleteZone extends TablesEvent {
  final String id;
  const DeleteZone(this.id);
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

  // Zones
  final List<ZoneModel> zones;
  final bool isLoadingZones;
  final String? zoneError;

  const TablesState({
    this.allTables = const [],
    this.filteredTables = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.zoneFilter,
    this.statusFilter,
    this.zones = const [],
    this.isLoadingZones = false,
    this.zoneError,
  });

  TablesState copyWith({
    List<TableModel>? allTables,
    List<TableModel>? filteredTables,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? zoneFilter,
    TableStatus? statusFilter,
    List<ZoneModel>? zones,
    bool? isLoadingZones,
    String? zoneError,
  }) {
    return TablesState(
      allTables: allTables ?? this.allTables,
      filteredTables: filteredTables ?? this.filteredTables,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      zoneFilter: zoneFilter ?? this.zoneFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      zones: zones ?? this.zones,
      isLoadingZones: isLoadingZones ?? this.isLoadingZones,
      zoneError: zoneError,
    );
  }

  List<String> get zoneNames => zones.map((z) => z.name).toList();

  @override
  List<Object?> get props => [
    allTables,
    filteredTables,
    isLoading,
    error,
    searchQuery,
    zoneFilter,
    statusFilter,
    zones,
    isLoadingZones,
    zoneError,
  ];
}

class TablesBloc extends Bloc<TablesEvent, TablesState> {
  final TableRepository repository;
  final ZoneRepository zoneRepository;

  TablesBloc({required this.repository, required this.zoneRepository})
      : super(const TablesState()) {
    on<LoadTables>(_onLoadTables);
    on<FilterTables>(_onFilterTables);
    on<AddTable>(_onAddTable);
    on<UpdateTable>(_onUpdateTable);
    on<DeleteTable>(_onDeleteTable);
    on<LoadZones>(_onLoadZones);
    on<CreateZone>(_onCreateZone);
    on<UpdateZone>(_onUpdateZone);
    on<DeleteZone>(_onDeleteZone);
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

  Future<void> _onUpdateTable(
    UpdateTable event,
    Emitter<TablesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final updated = await repository.updateTable(
        id: event.table.id,
        hotelId: event.table.hotelId,
        tableNumber: event.table.tableNumber,
        seatNumber: event.table.capacity,
        capacity: event.table.capacity,
        zone: event.table.zone.toLowerCase(),
      );
      final updatedList = state.allTables.map((t) {
        return t.id == updated.id ? updated : t;
      }).toList();

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

  Future<void> _onLoadZones(LoadZones event, Emitter<TablesState> emit) async {
    emit(state.copyWith(isLoadingZones: true));
    try {
      final zones = await zoneRepository.getZones();
      emit(state.copyWith(zones: zones, isLoadingZones: false));
    } catch (e) {
      emit(state.copyWith(isLoadingZones: false, zoneError: e.toString()));
    }
  }

  Future<void> _onCreateZone(CreateZone event, Emitter<TablesState> emit) async {
    emit(state.copyWith(isLoadingZones: true));
    try {
      final zone = await zoneRepository.createZone(
        name: event.name,
        description: event.description,
      );
      emit(state.copyWith(
        zones: [...state.zones, zone],
        isLoadingZones: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingZones: false, zoneError: e.toString()));
    }
  }

  Future<void> _onUpdateZone(UpdateZone event, Emitter<TablesState> emit) async {
    emit(state.copyWith(isLoadingZones: true));
    try {
      final updated = await zoneRepository.updateZone(
        id: event.id,
        name: event.name,
        description: event.description,
        isActive: event.isActive,
      );
      final updatedZones = state.zones.map((z) => z.id == updated.id ? updated : z).toList();
      emit(state.copyWith(zones: updatedZones, isLoadingZones: false));
    } catch (e) {
      emit(state.copyWith(isLoadingZones: false, zoneError: e.toString()));
    }
  }

  Future<void> _onDeleteZone(DeleteZone event, Emitter<TablesState> emit) async {
    emit(state.copyWith(isLoadingZones: true));
    try {
      await zoneRepository.deleteZone(event.id);
      final updatedZones = state.zones.where((z) => z.id != event.id).toList();
      emit(state.copyWith(zones: updatedZones, isLoadingZones: false));
    } catch (e) {
      emit(state.copyWith(isLoadingZones: false, zoneError: e.toString()));
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
        if (table.zone.toLowerCase() != zone.toLowerCase()) return false;
      }

      if (status != null) {
        if (table.status != status) return false;
      }

      return true;
    }).toList();
  }
}
