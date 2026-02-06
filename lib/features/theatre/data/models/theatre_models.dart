import 'package:flutter/material.dart';

class TheatreStat {
  final String label;
  final String value;
  final String subtext;
  final String comparisonText;
  final double trend; // Percentage (e.g., 3.0 for +3%)
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const TheatreStat({
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

class Theatre {
  final String id;
  final String name;
  final int screens;
  final String city;
  final String restaurant;
  final int seats;
  final String intervals; // e.g., "24/day"
  final int orders;
  final double revenue;
  final String peakTime;
  final int sla; // Percentage

  const Theatre({
    required this.id,
    required this.name,
    required this.screens,
    required this.city,
    required this.restaurant,
    required this.seats,
    required this.intervals,
    required this.orders,
    required this.revenue,
    required this.peakTime,
    required this.sla,
  });
}

class TopSellingItem {
  final String name;
  final int orders;
  final double trend; // e.g. 12.0 for +12%

  const TopSellingItem({
    required this.name,
    required this.orders,
    required this.trend,
  });
}

class TheatreDetail {
  final String id;
  final String name;
  final String status; // active
  final String city;
  final int screens;
  final int totalSeats;
  final int intervalsPerDay;
  final int ordersToday;
  final double avgOrderValue;
  final List<TopSellingItem> topSellingItems;
  final List<TheatreInterval> intervals;
  final List<AnalyticsOrder> orderAnalytics;
  final List<AnalyticsSku> bestSellingSkus;

  const TheatreDetail({
    required this.id,
    required this.name,
    required this.status,
    required this.city,
    required this.screens,
    required this.totalSeats,
    required this.intervalsPerDay,
    required this.ordersToday,
    required this.avgOrderValue,
    required this.topSellingItems,
    this.intervals = const [],
    this.orderAnalytics = const [],
    this.bestSellingSkus = const [],
  });
}

class TheatreInterval {
  final String time;
  final String screen;
  final String movie;
  final int orders;
  final int pending;
  final int ads;
  final String status; // 'Prebooking On', 'Off'
  final bool hasAds;

  const TheatreInterval({
    required this.time,
    required this.screen,
    required this.movie,
    required this.orders,
    required this.pending,
    required this.ads,
    required this.status,
    required this.hasAds,
  });
}

class AnalyticsOrder {
  final String time;
  final int orders;

  const AnalyticsOrder({required this.time, required this.orders});
}

class AnalyticsSku {
  final String name;
  final int value;

  const AnalyticsSku({required this.name, required this.value});
}
