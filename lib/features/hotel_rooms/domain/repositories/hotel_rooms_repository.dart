import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/domain/entities/hotel_room_entity.dart';

abstract class HotelRoomsRepository {
  Future<DataState<List<HotelRoom>>> getRooms();
  Future<DataState<List<RoomOrder>>> getRecentOrders(String hotelId);
  Future<DataState<Map<String, dynamic>>> getStats();
  Future<DataState<bool>> updateRoomStatus(String roomId, RoomStatus status);
}
