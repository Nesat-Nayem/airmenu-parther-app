import 'package:flutter/material.dart';
import '../models/theatre_models.dart';

abstract class TheatreRepository {
  Future<List<TheatreStat>> getStats();
  Future<List<Theatre>> getTheatres();
  Future<TheatreDetail> getTheatreDetail(String id);
}

class TheatreRepositoryImpl implements TheatreRepository {
  @override
  Future<List<TheatreStat>> getStats() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      const TheatreStat(
        label: 'Active Theatres',
        value: '45',
        subtext: 'Across all cities',
        comparisonText: 'vs yesterday',
        trend: 3.0,
        icon: Icons.movie_filter_outlined, // Film strip icon
        iconColor: Color(0xFFDC2626), // Red-ish
        iconBgColor: Color(0xFFFEE2E2), // Light Red
      ),
      const TheatreStat(
        label: 'Seats Configured',
        value: '54,200',
        subtext: 'Total capacity',
        comparisonText: '',
        trend: 0, // No trend shown in screenshot for this one
        icon: Icons.chair_outlined, // Armchair icon
        iconColor: Color(0xFFDC2626),
        iconBgColor: Color(0xFFFEE2E2),
      ),
      const TheatreStat(
        label: 'Orders Today',
        value: '2,340',
        subtext: '₹4.2L revenue',
        comparisonText: 'vs yesterday',
        trend: 18.0,
        icon: Icons.shopping_bag_outlined,
        iconColor: Color(0xFFDC2626),
        iconBgColor: Color(0xFFFEE2E2),
      ),
      const TheatreStat(
        label: 'Avg SLA',
        value: '91%',
        subtext: 'This week',
        comparisonText: 'vs yesterday',
        trend: 2.0,
        icon: Icons.schedule,
        iconColor: Color(0xFFDC2626),
        iconBgColor: Color(0xFFFEE2E2),
      ),
    ];
  }

  @override
  Future<List<Theatre>> getTheatres() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    return [
      const Theatre(
        id: '1',
        name: 'PVR Phoenix',
        screens: 8,
        city: 'Bangalore',
        restaurant: 'PVR Food Court',
        seats: 1200,
        intervals: '24/day',
        orders: 456,
        revenue: 89500,
        peakTime: '7:30 PM',
        sla: 94,
      ),
      const Theatre(
        id: '2',
        name: 'INOX Garuda Mall',
        screens: 6,
        city: 'Bangalore',
        restaurant: 'INOX Cafe',
        seats: 900,
        intervals: '18/day',
        orders: 312,
        revenue: 62400,
        peakTime: '8:00 PM',
        sla: 91,
      ),
      const Theatre(
        id: '3',
        name: 'Cinepolis Nexus',
        screens: 10,
        city: 'Mumbai',
        restaurant: 'Cinepolis Diner',
        seats: 1500,
        intervals: '30/day',
        orders: 578,
        revenue: 112000,
        peakTime: '9:00 PM',
        sla: 86,
      ),
      const Theatre(
        id: '4',
        name: 'PVR Forum',
        screens: 11,
        city: 'Bangalore',
        restaurant: 'PVR Gold',
        seats: 1100,
        intervals: '26/day',
        orders: 420,
        revenue: 95000,
        peakTime: '6:45 PM',
        sla: 92,
      ),
    ];
  }

  @override
  Future<TheatreDetail> getTheatreDetail(String id) async {
    await Future.delayed(
      const Duration(milliseconds: 600),
    ); // Slightly faster for better UX

    // Find basic info from the mock list
    final allTheatres = await getTheatres();
    final theatre = allTheatres.firstWhere(
      (t) => t.id == id,
      orElse: () => allTheatres.first,
    );

    // Generate pseudo-random or specific data based on the theatre
    // In a real app this comes from API.

    return TheatreDetail(
      id: theatre.id,
      name: theatre.name,
      status: 'active',
      city: theatre.city,
      screens: theatre.screens,
      totalSeats: theatre.seats,
      intervalsPerDay: int.tryParse(theatre.intervals.split('/').first) ?? 24,
      ordersToday: theatre.orders,
      avgOrderValue: (theatre.revenue / theatre.orders).roundToDouble(),
      topSellingItems: [
        const TopSellingItem(
          name: 'Caramel Popcorn Large',
          orders: 234,
          trend: 12.0,
        ),
        const TopSellingItem(name: 'Pepsi Combo', orders: 189, trend: 8.0),
        const TopSellingItem(
          name: 'Nachos with Cheese',
          orders: 156,
          trend: -3.0,
        ),
        const TopSellingItem(
          name: 'Butter Popcorn Medium',
          orders: 145,
          trend: 5.0,
        ),
      ],
      intervals: [
        const TheatreInterval(
          time: '7:00 PM',
          screen: 'Screen 1',
          movie: 'Pushpa 2',
          orders: 45,
          pending: 12,
          ads: 2,
          status: 'Prebooking On',
          hasAds: true,
        ),
        const TheatreInterval(
          time: '7:30 PM',
          screen: 'Screen 2',
          movie: 'Avatar 3',
          orders: 38,
          pending: 8,
          ads: 3,
          status: 'Prebooking On',
          hasAds: true,
        ),
        const TheatreInterval(
          time: '8:00 PM',
          screen: 'Screen 3',
          movie: 'Stree 2',
          orders: 0,
          pending: 0,
          ads: 1,
          status: 'Off',
          hasAds: true,
        ),
        const TheatreInterval(
          time: '8:30 PM',
          screen: 'Screen 1',
          movie: 'KGF 3',
          orders: 52,
          pending: 15,
          ads: 2,
          status: 'Prebooking On',
          hasAds: true,
        ),
      ],
      orderAnalytics: [
        const AnalyticsOrder(time: '2:00 PM', orders: 40),
        const AnalyticsOrder(time: '4:30 PM', orders: 80),
        const AnalyticsOrder(time: '5:30 PM', orders: 110),
        const AnalyticsOrder(time: '7:00 PM', orders: 150),
        const AnalyticsOrder(time: '7:30 PM', orders: 200),
        const AnalyticsOrder(time: '8:30 PM', orders: 230),
        const AnalyticsOrder(time: '9:00 PM', orders: 260),
        const AnalyticsOrder(time: '10:00 PM', orders: 190),
        const AnalyticsOrder(time: '10:30 PM', orders: 130),
      ],
      bestSellingSkus: [
        const AnalyticsSku(name: 'Caramel Popcorn Large', value: 46800),
        const AnalyticsSku(name: 'Pepsi Combo', value: 28350),
        const AnalyticsSku(name: 'Nachos with Cheese', value: 31200),
        const AnalyticsSku(name: 'Butter Popcorn Medium', value: 21750),
        const AnalyticsSku(name: 'Hot Dog Classic', value: 14700),
      ],
    );
  }
}
