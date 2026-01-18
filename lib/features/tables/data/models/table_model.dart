import 'package:equatable/equatable.dart';

enum TableStatus { vacant, occupied, reserved, cleaning }

class TableModel extends Equatable {
  final String id;
  final String tableNumber;
  final int capacity;
  final String zone; // Local field, not persisted in backend
  final TableStatus status;
  final String qrUrl;
  final String hotelId;

  const TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    this.zone = 'Indoor', // Default since backend missing
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

    if (backendStatus == 'booked') {
      mappedStatus = TableStatus.occupied;
    } else {
      mappedStatus = TableStatus.vacant;
    }

    return TableModel(
      id: json['_id'] as String? ?? '',
      tableNumber: json['tableNumber'] as String? ?? '',
      capacity: json['seatNumber'] as int? ?? 0,
      zone: 'Indoor', // Hardcoded as backend doesn't support zone yet
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
      'hotelId': hotelId,
      // 'zone': zone, // Not supported by backend
      // 'status': status, // Backend creates as 'available' by default
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
