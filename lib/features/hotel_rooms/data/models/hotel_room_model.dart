import 'package:airmenuai_partner_app/features/hotel_rooms/domain/entities/hotel_room_entity.dart';

class HotelRoomModel extends HotelRoom {
  const HotelRoomModel({
    required super.id,
    required super.roomNumber,
    required super.status,
    super.occupantName,
    super.ordersCount,
    super.slaScore,
    super.floor,
  });

  factory HotelRoomModel.fromJson(Map<String, dynamic> json) {
    return HotelRoomModel(
      id: json['id'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      status: _parseStatus(json['status']),
      occupantName: json['occupantName'],
      ordersCount: json['ordersCount'] ?? 0,
      slaScore: (json['slaScore'] ?? 0).toDouble(),
      floor: json['floor'] ?? 1,
    );
  }

  static RoomStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'occupied':
        return RoomStatus.occupied;
      case 'cleaning':
        return RoomStatus.cleaning;
      case 'vacant':
      default:
        return RoomStatus.vacant;
    }
  }
}

class RoomOrderModel extends RoomOrder {
  const RoomOrderModel({
    required super.id,
    required super.roomNumber,
    required super.title,
    required super.description,
    required super.status,
    required super.timestamp,
    super.amount,
  });

  factory RoomOrderModel.fromJson(Map<String, dynamic> json) {
    return RoomOrderModel(
      id: json['id'] ?? '',
      roomNumber:
          json['roomNumber'] ??
          '', // Assuming API provides this or valid default
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: _parseOrderState(json['status']),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  static RoomOrderState _parseOrderState(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return RoomOrderState.pending;
      case 'preparing':
        return RoomOrderState.preparing;
      case 'inprogress':
      case 'in-progress':
        return RoomOrderState.inProgress;
      case 'completed':
        return RoomOrderState.completed;
      default:
        return RoomOrderState.none;
    }
  }
}
