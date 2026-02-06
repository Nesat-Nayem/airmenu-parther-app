import 'package:equatable/equatable.dart';

enum RoomStatus { occupied, vacant, cleaning }

enum RoomOrderState { pending, preparing, inProgress, completed, none }

class HotelRoom extends Equatable {
  final String id;
  final String roomNumber;
  final RoomStatus status;
  final String? occupantName;
  final int ordersCount;
  final double slaScore; // 0.0 to 100.0
  final int floor;

  const HotelRoom({
    required this.id,
    required this.roomNumber,
    required this.status,
    this.occupantName,
    this.ordersCount = 0,
    this.slaScore = 0,
    this.floor = 1,
  });

  @override
  List<Object?> get props => [
    id,
    roomNumber,
    status,
    occupantName,
    ordersCount,
    slaScore,
    floor,
  ];
}

class RoomOrder extends Equatable {
  final String id;
  final String roomNumber;
  final String title;
  final String description;
  final RoomOrderState status;
  final DateTime timestamp;
  final double amount;

  const RoomOrder({
    required this.id,
    required this.roomNumber,
    required this.title,
    required this.description,
    required this.status,
    required this.timestamp,
    this.amount = 0.0,
  });

  @override
  List<Object?> get props => [
    id,
    roomNumber,
    title,
    description,
    status,
    timestamp,
    amount,
  ];
}
