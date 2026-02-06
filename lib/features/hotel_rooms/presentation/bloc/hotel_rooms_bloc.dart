import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/domain/entities/hotel_room_entity.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/domain/repositories/hotel_rooms_repository.dart';
import 'hotel_rooms_event.dart';
import 'hotel_rooms_state.dart';

class HotelRoomsBloc extends Bloc<HotelRoomsEvent, HotelRoomsState> {
  final HotelRoomsRepository _repository;

  HotelRoomsBloc(this._repository) : super(const HotelRoomsState()) {
    on<LoadHotelRooms>(_onLoadHotelRooms);
    on<SelectRoom>(_onSelectRoom);
    on<FilterRooms>(_onFilterRooms);
  }

  Future<void> _onLoadHotelRooms(
    LoadHotelRooms event,
    Emitter<HotelRoomsState> emit,
  ) async {
    emit(state.copyWith(status: HotelRoomsStatus.loading));

    // Parallel execution for loading stats, rooms, and orders
    final results = await Future.wait([
      _repository.getRooms(),
      _repository.getStats(),
      _repository.getRecentOrders('hotel_123'),
    ]);

    final roomsResult = results[0] as DataState<List<HotelRoom>>;
    final statsResult = results[1] as DataState<Map<String, dynamic>>;
    final ordersResult = results[2] as DataState<List<RoomOrder>>;

    if (roomsResult is DataSuccess &&
        statsResult is DataSuccess &&
        ordersResult is DataSuccess) {
      final rooms = roomsResult.data ?? [];
      final orders = ordersResult.data ?? [];
      emit(
        state.copyWith(
          status: HotelRoomsStatus.success,
          rooms: rooms,
          filteredRooms: rooms, // Initially all rooms are shown
          stats: statsResult.data ?? {},
          recentOrders: orders,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: HotelRoomsStatus.failure,
          errorMessage:
              roomsResult.error?.toString() ??
              statsResult.error?.toString() ??
              ordersResult.error?.toString() ??
              "Unknown error",
        ),
      );
    }
  }

  void _onSelectRoom(SelectRoom event, Emitter<HotelRoomsState> emit) {
    if (event.roomId == state.selectedRoomId) {
      // Deselect if already selected (optional behavior, might be useful)
      // emit(state.copyWith(clearSelectedRoom: true));
      // For now just keep it selected or allow explicitly setting null
      if (event.roomId == null) {
        emit(state.copyWith(clearSelectedRoom: true));
      }
    } else {
      emit(
        state.copyWith(
          selectedRoomId: event.roomId,
          clearSelectedRoom: event.roomId == null,
        ),
      );
    }
  }

  void _onFilterRooms(FilterRooms event, Emitter<HotelRoomsState> emit) {
    // 1. Update filter state

    // We construct the new state first to have the latest filter values
    // Note: We need to handle nulls carefully. If event passes null, does it mean "clear" or "no change"?
    // In this implementation, I'll assume explicit null in event payload means "no change" unless we want to clear.
    // However, usually FilterEvents carry the *new* state of filters.
    // Let's assume the UI sends the complete new filter set or we merge.
    // For simplicity, let's update what is passed.

    // Actually, looking at the event `FilterRooms(query: '', floor: null, status: null)` defaults.
    // It's better to store current filters in state and update only changed ones.
    // But typically UI filter bars trigger "Here is the new query", "Here is the new floor".
    // So let's update state based on what's provided.

    // Since `FilterRooms` props are final, we can't easily tell if they were passed or defaulted.
    // Ideally we'd have separate events `SearchQueryChanged`, `FloorFilterChanged` etc.
    // Or `FilterRooms` carries all of them.
    // Let's assume the UI sends the *current* value for all filters every time a filter changes,
    // OR we merge with state.
    // Let's go with merging: if the UI calls FilterRooms, it usually passes only the changed value if we used separate events.
    // But since it's one event, let's assume valid values are passed.

    // Correction: In complex UI, separating events is cleaner. But let's simple merge logic here.
    // I made the state hold the values.

    final updatedQuery = event.query; // If empty string, fine.
    // For floor/status, if they are null, do we clear filter or keep previous?
    // Let's assume if the UI wants to clear it sends specific value or we treat null as "no filter" if that's the intention.
    // Usually `floor: null` means "All Floors".

    final updatedFloor = event.floor;
    final updatedStatus = event.status;

    final filtered = state.rooms.where((room) {
      // Search
      final matchesSearch =
          room.roomNumber.toLowerCase().contains(updatedQuery.toLowerCase()) ||
          (room.occupantName?.toLowerCase().contains(
                updatedQuery.toLowerCase(),
              ) ??
              false);

      // Floor
      final matchesFloor = updatedFloor == null || room.floor == updatedFloor;

      // Status
      // 'All Status' usually means null or 'all'
      final matchesStatus =
          (updatedStatus == null || updatedStatus == 'All Status') ||
          room.status.toString().split('.').last == updatedStatus.toLowerCase();

      return matchesSearch && matchesFloor && matchesStatus;
    }).toList();

    emit(
      state.copyWith(
        searchQuery: updatedQuery,
        filteredFloor: updatedFloor,
        clearFilteredFloor: updatedFloor == null,
        filteredStatus: updatedStatus,
        clearFilteredStatus: updatedStatus == null,
        filteredRooms: filtered,
      ),
    );
  }
}
