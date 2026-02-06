import 'package:flutter/material.dart';
import '../models/hotel_models.dart';

abstract class HotelRepository {
  Future<List<HotelStat>> getStats();
  Future<List<Hotel>> getHotels();
  Future<HotelDetail> getHotelDetail(String id);
}

class HotelRepositoryImpl implements HotelRepository {
  @override
  Future<List<HotelStat>> getStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const HotelStat(
        label: 'Active Hotels',
        value: '28',
        subtext: '12 cities',
        comparisonText: '',
        trend: 0,
        icon: Icons.apartment_rounded,
        iconColor: Color(0xFFDC2626), // Red-ish to match screenshot
        iconBgColor: Color(0xFFFEE2E2),
      ),
      const HotelStat(
        label: 'Rooms Integrated',
        value: '1,245',
        subtext: 'Out of 1,500 total',
        comparisonText: '',
        trend: 0,
        icon: Icons.bed_rounded,
        iconColor: Color(0xFFDC2626),
        iconBgColor: Color(0xFFFEE2E2),
      ),
      const HotelStat(
        label: 'Room Service Orders',
        value: '456',
        subtext: 'vs yesterday',
        comparisonText: '',
        trend: 8.0,
        icon: Icons.restaurant_rounded,
        iconColor: Color(0xFFDC2626),
        iconBgColor: Color(0xFFFEE2E2),
      ),
      const HotelStat(
        label: 'Laundry Requests',
        value: '89',
        subtext: '23 pending',
        comparisonText: '',
        trend: 0,
        icon: Icons.dry_cleaning_rounded,
        iconColor: Color(0xFFDC2626),
        iconBgColor: Color(0xFFFEE2E2),
      ),
    ];
  }

  @override
  Future<List<Hotel>> getHotels() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      const Hotel(
        id: '1',
        name: 'Taj Bangalore',
        address: 'Bangalore',
        rooms: '198/245',
        totalRooms: 245,
        occupiedRooms: 198,
        roomServiceOrders: 156,
        laundryRequests: 34,
        sla: 96,
      ),
      const Hotel(
        id: '2',
        name: 'Marriott Mumbai',
        address: 'Mumbai',
        rooms: '278/320',
        totalRooms: 320,
        occupiedRooms: 278,
        roomServiceOrders: 234,
        laundryRequests: 56,
        sla: 92,
      ),
      const Hotel(
        id: '3',
        name: 'ITC Grand Chola',
        address: 'Chennai',
        rooms: '345/400',
        totalRooms: 400,
        occupiedRooms: 345,
        roomServiceOrders: 289,
        laundryRequests: 78,
        sla: 94,
      ),
      const Hotel(
        id: '4',
        name: 'Oberoi Delhi',
        address: 'Delhi',
        rooms: '156/280',
        totalRooms: 280,
        occupiedRooms: 156,
        roomServiceOrders: 78,
        laundryRequests: 23,
        sla: 88,
      ),
    ];
  }

  @override
  Future<HotelDetail> getHotelDetail(String id) async {
    await Future.delayed(
      const Duration(milliseconds: 600),
    ); // Simulate detail load

    // Look up hotel basic info to get correct name/address/totalRooms
    final hotels = await getHotels();
    final hotel = hotels.firstWhere((h) => h.id == id, orElse: () => hotels[0]);

    // Mock Room List (could vary slightly based on hotel ID if needed, but randomized for variety)
    final rooms = [
      RoomSummary(
        roomNumber: 'Room 405',
        floor: 'Floor 4',
        orders: id == '1' ? 3 : 1,
        status: 'occupied',
      ),
      RoomSummary(
        roomNumber: 'Room 712',
        floor: 'Floor 7',
        orders: id == '2' ? 5 : 1,
        status: 'occupied',
      ),
      const RoomSummary(
        roomNumber: 'Room 203',
        floor: 'Floor 2',
        orders: 0,
        status: 'vacant',
      ),
      RoomSummary(
        roomNumber: 'Room 518',
        floor: 'Floor 5',
        orders: id == '3' ? 8 : 5,
        status: 'occupied',
      ),
      const RoomSummary(
        roomNumber: 'Room 901',
        floor: 'Floor 9',
        orders: 2,
        status: 'cleaning',
      ),
    ];

    // Mock Trend (vary data slightly based on ID)
    final trend = [
      OrderTrendPoint(day: 'Mon', orders: 160 + (int.parse(id) * 10)),
      OrderTrendPoint(day: 'Tue', orders: 190 - (int.parse(id) * 5)),
      OrderTrendPoint(day: 'Wed', orders: 180 + (int.parse(id) * 15)),
      OrderTrendPoint(day: 'Thu', orders: 240 + (int.parse(id) * 5)),
      OrderTrendPoint(day: 'Fri', orders: 280),
      OrderTrendPoint(day: 'Sat', orders: 320 - (int.parse(id) * 20)),
      OrderTrendPoint(day: 'Sun', orders: 250),
    ];

    return HotelDetail(
      id: id,
      name: hotel.name,
      address: hotel.address,
      floors: '${8 + int.parse(id)} floors', // Varies by ID
      totalRooms: '${hotel.totalRooms} rooms',
      rooms: rooms,
      orderTrend: trend,
    );
  }
}
