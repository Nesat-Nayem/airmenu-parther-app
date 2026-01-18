import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/staff_management/data/models/staff_model.dart';
import 'package:airmenuai_partner_app/features/staff_management/domain/repositories/staff_repository_interface.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRepository _repository;

  StaffBloc({required StaffRepository repository})
    : _repository = repository,
      super(const StaffInitial()) {
    on<LoadStaff>(_onLoadStaff);
    on<RefreshStaff>(_onRefreshStaff);
    on<SearchStaff>(_onSearchStaff);
    on<FilterByRole>(_onFilterByRole);
    on<AddStaff>(_onAddStaff);
    on<UpdateStaff>(_onUpdateStaff);
    on<ToggleStaffStatus>(_onToggleStaffStatus);
    on<DeleteStaff>(_onDeleteStaff);
  }

  Future<void> _onLoadStaff(LoadStaff event, Emitter<StaffState> emit) async {
    emit(const StaffLoading());

    final result = await _repository.getAllStaff();

    result.fold((failure) => emit(StaffError(failure.message)), (staffList) {
      final stats = StaffStats.fromStaffList(staffList);
      emit(
        StaffLoaded(
          allStaff: staffList,
          filteredStaff: staffList,
          stats: stats,
        ),
      );
    });
  }

  Future<void> _onRefreshStaff(
    RefreshStaff event,
    Emitter<StaffState> emit,
  ) async {
    if (state is StaffLoaded) {
      final currentState = state as StaffLoaded;
      emit(currentState.copyWith(isRefreshing: true));

      final result = await _repository.getAllStaff();

      result.fold(
        (failure) => emit(currentState.copyWith(isRefreshing: false)),
        (staffList) {
          final stats = StaffStats.fromStaffList(staffList);
          final filtered = _applyFilters(
            staffList,
            currentState.searchQuery,
            currentState.selectedRole,
          );
          emit(
            StaffLoaded(
              allStaff: staffList,
              filteredStaff: filtered,
              stats: stats,
              searchQuery: currentState.searchQuery,
              selectedRole: currentState.selectedRole,
              isRefreshing: false,
            ),
          );
        },
      );
    } else {
      add(const LoadStaff());
    }
  }

  void _onSearchStaff(SearchStaff event, Emitter<StaffState> emit) {
    if (state is StaffLoaded) {
      final currentState = state as StaffLoaded;
      final filtered = _applyFilters(
        currentState.allStaff,
        event.query,
        currentState.selectedRole,
      );
      emit(
        currentState.copyWith(
          filteredStaff: filtered,
          searchQuery: event.query,
        ),
      );
    }
  }

  void _onFilterByRole(FilterByRole event, Emitter<StaffState> emit) {
    if (state is StaffLoaded) {
      final currentState = state as StaffLoaded;
      final filtered = _applyFilters(
        currentState.allStaff,
        currentState.searchQuery,
        event.role,
      );
      emit(
        StaffLoaded(
          allStaff: currentState.allStaff,
          filteredStaff: filtered,
          stats: currentState.stats,
          searchQuery: currentState.searchQuery,
          selectedRole: event.role,
          loadingIds: currentState.loadingIds,
        ),
      );
    }
  }

  Future<void> _onAddStaff(AddStaff event, Emitter<StaffState> emit) async {
    final result = await _repository.createStaff(
      name: event.name,
      email: event.email,
      password: event.password,
      phone: event.phone,
      hotelId: event.hotelId,
      staffRole: event.staffRole,
      shift: event.shift,
      permissions: event.permissions,
    );

    result.fold((failure) => emit(StaffActionFailure(failure.message)), (
      staff,
    ) {
      emit(const StaffActionSuccess('Staff member added successfully'));
      add(const RefreshStaff());
    });
  }

  Future<void> _onUpdateStaff(
    UpdateStaff event,
    Emitter<StaffState> emit,
  ) async {
    if (state is StaffLoaded) {
      final currentState = state as StaffLoaded;
      emit(
        currentState.copyWith(
          loadingIds: {...currentState.loadingIds, event.id},
        ),
      );
    }

    final result = await _repository.updateStaff(
      id: event.id,
      name: event.name,
      email: event.email,
      phone: event.phone,
      status: event.status,
      staffRole: event.staffRole,
      shift: event.shift,
      permissions: event.permissions,
    );

    result.fold(
      (failure) {
        if (state is StaffLoaded) {
          final currentState = state as StaffLoaded;
          emit(
            currentState.copyWith(
              loadingIds: {...currentState.loadingIds}..remove(event.id),
            ),
          );
        }
        emit(StaffActionFailure(failure.message));
      },
      (staff) {
        emit(const StaffActionSuccess('Staff member updated successfully'));
        add(const RefreshStaff());
      },
    );
  }

  Future<void> _onToggleStaffStatus(
    ToggleStaffStatus event,
    Emitter<StaffState> emit,
  ) async {
    if (state is StaffLoaded) {
      final currentState = state as StaffLoaded;
      emit(
        currentState.copyWith(
          loadingIds: {...currentState.loadingIds, event.id},
        ),
      );

      final staff = currentState.allStaff.firstWhere((s) => s.id == event.id);
      final newStatus = staff.isActive ? 'inactive' : 'active';

      final result = await _repository.updateStaff(
        id: event.id,
        status: newStatus,
      );

      result.fold(
        (failure) {
          emit(
            currentState.copyWith(
              loadingIds: {...currentState.loadingIds}..remove(event.id),
            ),
          );
          emit(StaffActionFailure(failure.message));
        },
        (updatedStaff) {
          emit(
            StaffActionSuccess(
              newStatus == 'active'
                  ? 'Staff member enabled'
                  : 'Staff member disabled',
            ),
          );
          add(const RefreshStaff());
        },
      );
    }
  }

  Future<void> _onDeleteStaff(
    DeleteStaff event,
    Emitter<StaffState> emit,
  ) async {
    if (state is StaffLoaded) {
      final currentState = state as StaffLoaded;
      emit(
        currentState.copyWith(
          loadingIds: {...currentState.loadingIds, event.id},
        ),
      );
    }

    final result = await _repository.deleteStaff(event.id);

    result.fold(
      (failure) {
        if (state is StaffLoaded) {
          final currentState = state as StaffLoaded;
          emit(
            currentState.copyWith(
              loadingIds: {...currentState.loadingIds}..remove(event.id),
            ),
          );
        }
        emit(StaffActionFailure(failure.message));
      },
      (_) {
        emit(const StaffActionSuccess('Staff member deleted successfully'));
        add(const RefreshStaff());
      },
    );
  }

  List<StaffModel> _applyFilters(
    List<StaffModel> staff,
    String searchQuery,
    String? role,
  ) {
    var filtered = staff;

    // Apply role filter
    if (role != null && role.isNotEmpty && role != 'All') {
      filtered = filtered.where((s) {
        final staffRole = s.staffRole?.toLowerCase() ?? '';
        return staffRole == role.toLowerCase();
      }).toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(query) ||
            s.email.toLowerCase().contains(query) ||
            s.phone.contains(query);
      }).toList();
    }

    return filtered;
  }
}
