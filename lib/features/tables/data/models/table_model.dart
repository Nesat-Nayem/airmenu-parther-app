import 'package:equatable/equatable.dart';

enum TableStatus { vacant, occupied, reserved, cleaning }

class TableModel extends Equatable {
  final String id;
  final String tableNumber;
  final int capacity;
  final String zone;
  final TableStatus status;
  final String qrUrl;
  final String hotelId;

  const TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    this.zone = 'Indoor',
    this.status = TableStatus.vacant,
    required this.qrUrl,
    required this.hotelId,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    // Map backend status to UI status
    // Backend: 'available' -> UI: vacant
    // Backend: 'booked' -> UI: occupied
    TableStatus mappedStatus;
    final backendStatus = json['status'] as String? ?? 'available';

    switch (backendStatus) {
      case 'booked':
        mappedStatus = TableStatus.occupied;
        break;
      case 'reserved':
        mappedStatus = TableStatus.reserved;
        break;
      case 'cleaning':
        mappedStatus = TableStatus.cleaning;
        break;
      default:
        mappedStatus = TableStatus.vacant;
    }

    // Map backend zone to display value
    final backendZone = json['zone'] as String? ?? 'indoor';
    String mappedZone;
    switch (backendZone.toLowerCase()) {
      case 'outdoor':
        mappedZone = 'Outdoor';
        break;
      case 'private':
        mappedZone = 'Private';
        break;
      default:
        mappedZone = 'Indoor';
    }

    return TableModel(
      id: json['_id'] as String? ?? '',
      tableNumber: json['tableNumber'] as String? ?? '',
      capacity: json['seatNumber'] as int? ?? json['capacity'] as int? ?? 0,
      zone: mappedZone,
      status: mappedStatus,
      qrUrl: json['qrCodeImage'] as String? ?? '',
      hotelId: json['hotelId'] is Map
          ? (json['hotelId']['_id'] as String? ?? '')
          : (json['hotelId'] as String? ?? ''),
    );
  }

  // For sending to Add API
  Map<String, dynamic> toAddJson() {
    return {
      'tableNumber': tableNumber,
      'seatNumber': capacity,
      'capacity': capacity,
      'hotelId': hotelId,
      'zone': zone.toLowerCase(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    tableNumber,
    capacity,
    zone,
    status,
    qrUrl,
    hotelId,
  ];
}
