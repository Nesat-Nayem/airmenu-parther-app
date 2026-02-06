import 'package:flutter/material.dart';

enum ConsumptionLevel {
  high,
  medium,
  low;

  Color get color {
    switch (this) {
      case ConsumptionLevel.high:
        return const Color(0xFFDC2626); // Primary/Red
      case ConsumptionLevel.medium:
        return const Color(0xFFF59E0B); // Amber
      case ConsumptionLevel.low:
        return const Color(0xFF10B981); // Green
    }
  }

  String get label => name[0].toUpperCase() + name.substring(1);
}

enum StockStatus {
  critical,
  low,
  healthy;

  Color get color {
    switch (this) {
      case StockStatus.critical:
        return const Color(0xFFDC2626);
      case StockStatus.low:
        return const Color(0xFFF59E0B);
      case StockStatus.healthy:
        return const Color(0xFF10B981);
    }
  }

  String get label => name[0].toUpperCase() + name.substring(1);
}

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final double currentStock;
  final double minStock;
  final double maxStock;
  final double costPrice;
  final String unit;
  final StockStatus status;
  final ConsumptionLevel consumption;
  final String vendor;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.costPrice,
    required this.unit,
    required this.status,
    required this.consumption,
    required this.vendor,
  });

  double get stockPercentage => (currentStock / maxStock).clamp(0.0, 1.0);

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? currentStock,
    double? minStock,
    double? maxStock,
    double? costPrice,
    String? unit,
    StockStatus? status,
    ConsumptionLevel? consumption,
    String? vendor,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      costPrice: costPrice ?? this.costPrice,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      consumption: consumption ?? this.consumption,
      vendor: vendor ?? this.vendor,
    );
  }
}

enum PurchaseOrderStatus {
  pending,
  ordered,
  received;

  Color get color {
    switch (this) {
      case PurchaseOrderStatus.pending:
        return const Color(0xFFF59E0B);
      case PurchaseOrderStatus.ordered:
        return const Color(0xFF3B82F6);
      case PurchaseOrderStatus.received:
        return const Color(0xFF10B981);
    }
  }

  String get label => name[0].toUpperCase() + name.substring(1);
}

class PurchaseOrder {
  final String id;
  final String poNumber;
  final String vendorName;
  final double amount;
  final PurchaseOrderStatus status;
  final DateTime date;

  const PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.vendorName,
    required this.amount,
    required this.status,
    required this.date,
  });

  PurchaseOrder copyWith({
    String? id,
    String? poNumber,
    String? vendorName,
    double? amount,
    PurchaseOrderStatus? status,
    DateTime? date,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      vendorName: vendorName ?? this.vendorName,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }
}

class InventoryAnalytics {
  final double totalConsumption;
  final double totalCost;
  final double totalWastage;
  final double efficiencyScore;
  final List<ChartDataPoint> consumptionTrend;

  const InventoryAnalytics({
    required this.totalConsumption,
    required this.totalCost,
    required this.totalWastage,
    required this.efficiencyScore,
    required this.consumptionTrend,
  });
}

class ChartDataPoint {
  final String label;
  final double value;

  const ChartDataPoint(this.label, this.value);
}
