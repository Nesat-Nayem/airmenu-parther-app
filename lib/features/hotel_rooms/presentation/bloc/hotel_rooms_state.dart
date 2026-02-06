import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/domain/entities/hotel_room_entity.dart';

enum HotelRoomsStatus { initial, loading, success, failure }

class HotelRoomsState extends Equatable {
  final HotelRoomsStatus status;
  final List<HotelRoom> rooms;
  final List<HotelRoom> filteredRooms;
  final Map<String, dynamic> stats;
  final String? errorMessage;
  final String? selectedRoomId;

  // Filter state
  final String searchQuery;
  final int? filteredFloor;
  final String? filteredStatus;
  final List<RoomOrder> recentOrders;

  const HotelRoomsState({
    this.status = HotelRoomsStatus.initial,
    this.rooms = const [],
    this.filteredRooms = const [],
    this.stats = const {},
    this.errorMessage,
    this.selectedRoomId,
    this.searchQuery = '',
    this.filteredFloor,
    this.filteredStatus,
    this.recentOrders = const [],
  });

  HotelRoom? get selectedRoom {
    if (selectedRoomId == null) return null;
    try {
      return rooms.firstWhere((element) => element.id == selectedRoomId);
    } catch (_) {
      return null;
    }
  }

  List<RoomOrder> get selectedRoomOrders {
    final room = selectedRoom;
    if (room == null) return [];
    return recentOrders
        .where((order) => order.roomNumber == room.roomNumber)
        .toList();
  }

  HotelRoomsState copyWith({
    HotelRoomsStatus? status,
    List<HotelRoom>? rooms,
    List<HotelRoom>? filteredRooms,
    Map<String, dynamic>? stats,
    String? errorMessage,
    String? selectedRoomId,
    bool clearSelectedRoom = false,
    String? searchQuery,
    int? filteredFloor,
    bool clearFilteredFloor = false,
    String? filteredStatus,
    bool clearFilteredStatus = false,
    List<RoomOrder>? recentOrders,
  }) {
    return HotelRoomsState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      filteredRooms: filteredRooms ?? this.filteredRooms,
      stats: stats ?? this.stats,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedRoomId: clearSelectedRoom
          ? null
          : (selectedRoomId ?? this.selectedRoomId),
      searchQuery: searchQuery ?? this.searchQuery,
      filteredFloor: clearFilteredFloor
          ? null
          : (filteredFloor ?? this.filteredFloor),
      filteredStatus: clearFilteredStatus
          ? null
          : (filteredStatus ?? this.filteredStatus),
      recentOrders: recentOrders ?? this.recentOrders,
    );
  }

  @override
  List<Object?> get props => [
    status,
    rooms,
    filteredRooms,
    stats,
    errorMessage,
    selectedRoomId,
    searchQuery,
    filteredFloor,
    filteredStatus,
    recentOrders,
  ];
}
