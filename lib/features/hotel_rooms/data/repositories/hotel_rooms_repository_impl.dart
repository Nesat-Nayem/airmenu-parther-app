import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/data_error.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/data/models/hotel_room_model.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/domain/entities/hotel_room_entity.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/domain/repositories/hotel_rooms_repository.dart';

class HotelRoomsRepositoryImpl implements HotelRoomsRepository {
  @override
  Future<DataState<List<HotelRoom>>> getRooms() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      final mockData = [
        {
          'id': '101',
          'roomNumber': '101',
          'status': 'occupied',
          'occupantName': 'John Doe',
          'ordersCount': 3,
          'slaScore': 92,
          'floor': 1,
        },
        {'id': '102', 'roomNumber': '102', 'status': 'vacant', 'floor': 1},
        {
          'id': '103',
          'roomNumber': '103',
          'status': 'occupied',
          'occupantName': 'Jane Smith',
          'ordersCount': 2,
          'slaScore': 95,
          'floor': 1,
        },
        {'id': '104', 'roomNumber': '104', 'status': 'cleaning', 'floor': 1},
        {
          'id': '201',
          'roomNumber': '201',
          'status': 'occupied',
          'occupantName': 'Bob Wilson',
          'ordersCount': 5,
          'slaScore': 78,
          'floor': 2,
        },
        {
          'id': '202',
          'roomNumber': '202',
          'status': 'occupied',
          'occupantName': 'Alice Brown',
          'ordersCount': 1,
          'slaScore': 88,
          'floor': 2,
        },
        {'id': '203', 'roomNumber': '203', 'status': 'vacant', 'floor': 2},
        {
          'id': '204',
          'roomNumber': '204',
          'status': 'occupied',
          'occupantName': 'Mike Davis',
          'ordersCount': 8,
          'slaScore': 96,
          'floor': 2,
        },
        {
          'id': '301',
          'roomNumber': '301',
          'status': 'occupied',
          'occupantName': 'Sarah Lee',
          'ordersCount': 2,
          'slaScore': 85,
          'floor': 3,
        },
        {'id': '302', 'roomNumber': '302', 'status': 'vacant', 'floor': 3},
        {'id': '303', 'roomNumber': '303', 'status': 'cleaning', 'floor': 3},
        {
          'id': '304',
          'roomNumber': '304',
          'status': 'occupied',
          'occupantName': 'Tom Chen',
          'ordersCount': 4,
          'slaScore': 91,
          'floor': 3,
        },
      ];

      final rooms = mockData.map((e) => HotelRoomModel.fromJson(e)).toList();
      return DataSuccess(rooms);
    } catch (e) {
      return DataFailure(DataError(message: e.toString()));
    }
  }

  @override
  Future<DataState<List<RoomOrder>>> getRecentOrders(String hotelId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      final mockOrders = [
        {
          'id': 'o1',
          'roomNumber': '101',
          'title': 'Dinner for 2 - Biryani, Naan, Dessert',
          'description': 'Food',
          'status': 'preparing',
          'timestamp': DateTime.now()
              .subtract(const Duration(minutes: 10))
              .toIso8601String(),
          'amount': 1200.0,
        },
        {
          'id': 'o2',
          'roomNumber': '101',
          'title': '3 Shirts, 2 Trousers',
          'description': 'Laundry',
          'status': 'pending',
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 1))
              .toIso8601String(),
          'amount': 450.0,
        },
        {
          'id': 'o3',
          'roomNumber': '101',
          'title': 'Room Cleaning',
          'description': 'Clean',
          'status': 'completed',
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 4))
              .toIso8601String(),
          'amount': 0.0,
        },
        // Add a few more for other rooms to test filtering
        {
          'id': 'o4',
          'roomNumber': '204',
          'title': 'Lunch Combo',
          'description': 'Food',
          'status': 'completed',
          'timestamp': DateTime.now()
              .subtract(const Duration(minutes: 50))
              .toIso8601String(),
          'amount': 800.0,
        },
        {
          'id': 'o5',
          'roomNumber': '301',
          'title': 'Extra Towels',
          'description': 'Housekeeping',
          'status': 'pending',
          'timestamp': DateTime.now()
              .subtract(const Duration(minutes: 5))
              .toIso8601String(),
          'amount': 0.0,
        },
      ];

      final List<RoomOrder> orders = mockOrders
          .map((e) => RoomOrderModel.fromJson(e))
          .toList();
      return DataSuccess(orders);
    } catch (e) {
      return DataFailure(DataError(message: e.toString()));
    }
  }

  @override
  Future<DataState<Map<String, dynamic>>> getStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const DataSuccess({
      'occupiedRooms': 7,
      'activeOrders': 4,
      'pendingOrders': 5,
      'avgSlaScore': 94,
    });
  }

  @override
  Future<DataState<bool>> updateRoomStatus(
    String roomId,
    RoomStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const DataSuccess(true);
  }
}
