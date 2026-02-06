import 'package:flutter/material.dart';

class IntegrationStat {
  final String label;
  final String value;
  final String subtext; // e.g., "Across all partners"
  final String comparisonText; // e.g., "vs yesterday"
  final double trend; // positive for up, negative for down
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const IntegrationStat({
    required this.label,
    required this.value,
    this.subtext = '',
    this.comparisonText = '',
    this.trend = 0.0,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class IntegrationPartner {
  final String id;
  final String name; // Shadowfax
  final String type; // Third Party
  final String restaurantsLinked; // 845 restaurants
  final int sla; // 94%
  final String avgTime; // 28 min
  final double successRate; // 96.5%
  final double failureRate; // 3.5%
  final double costPerKm; // ₹8.5
  final String status; // active, degraded
  final String lastSync; // 2 min ago

  const IntegrationPartner({
    required this.id,
    required this.name,
    required this.type,
    required this.restaurantsLinked,
    required this.sla,
    required this.avgTime,
    required this.successRate,
    required this.failureRate,
    required this.costPerKm,
    required this.status,
    required this.lastSync,
  });
}
