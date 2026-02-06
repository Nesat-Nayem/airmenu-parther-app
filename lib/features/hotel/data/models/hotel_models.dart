import 'package:flutter/material.dart';

class HotelStat {
  final String label;
  final String value;
  final String subtext;
  final String comparisonText;
  final double trend;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const HotelStat({
    required this.label,
    required this.value,
    required this.subtext,
    required this.comparisonText,
    required this.trend,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class Hotel {
  final String id;
  final String name;
  final String address;
  final String rooms; // e.g., "198/245"
  final int totalRooms; // 245
  final int occupiedRooms; // 198
  final int roomServiceOrders;
  final int laundryRequests;
  final int sla;

  const Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.rooms,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.roomServiceOrders,
    required this.laundryRequests,
    required this.sla,
  });
}

class RoomSummary {
  final String roomNumber;
  final String floor;
  final int orders;
  final String status; // occupied, vacant, cleaning

  const RoomSummary({
    required this.roomNumber,
    required this.floor,
    required this.orders,
    required this.status,
  });
}

class OrderTrendPoint {
  final String day;
  final int orders;

  const OrderTrendPoint({required this.day, required this.orders});
}

class HotelDetail {
  final String id;
  final String name;
  final String address;
  final String floors; // "12 floors"
  final String totalRooms; // "245 rooms"
  final List<RoomSummary> rooms;
  final List<OrderTrendPoint> orderTrend;

  const HotelDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.floors,
    required this.totalRooms,
    required this.rooms,
    required this.orderTrend,
  });
}
