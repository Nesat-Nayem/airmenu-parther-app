import 'package:flutter/material.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

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

enum ConsumptionLevel {
  high,
  medium,
  low;

  Color get color {
    switch (this) {
      case ConsumptionLevel.high:
        return const Color(0xFFDC2626);
      case ConsumptionLevel.medium:
        return const Color(0xFFF59E0B);
      case ConsumptionLevel.low:
        return const Color(0xFF10B981);
    }
  }

  String get label => name[0].toUpperCase() + name.substring(1);
}

// ─── Raw Material (maps to /inventory/materials) ──────────────────────────────
class InventoryItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double currentStock;
  final double openingStock;
  final double reorderLevel;
  final double minStock;
  final String unit;
  final String hotelId;

  const InventoryItem({
    required this.id,
    required this.name,
    this.sku = '',
    this.category = '',
    required this.currentStock,
    this.openingStock = 0,
    this.reorderLevel = 0,
    this.minStock = 0,
    required this.unit,
    this.hotelId = '',
  });

  StockStatus get status {
    if (currentStock <= 0) return StockStatus.critical;
    if (reorderLevel > 0 && currentStock <= reorderLevel) return StockStatus.low;
    return StockStatus.healthy;
  }

  // Legacy compat: maxStock used for progress bar — treat reorderLevel * 3 or openingStock
  double get maxStock => openingStock > 0 ? openingStock : (reorderLevel * 3).clamp(1, double.infinity);

  double get stockPercentage => (currentStock / maxStock).clamp(0.0, 1.0);

  // Legacy compat kept for UI
  ConsumptionLevel get consumption {
    if (status == StockStatus.critical) return ConsumptionLevel.high;
    if (status == StockStatus.low) return ConsumptionLevel.medium;
    return ConsumptionLevel.low;
  }

  String get vendor => '';
  double get costPrice => 0;

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      category: json['category'] ?? '',
      currentStock: (json['currentStock'] ?? 0).toDouble(),
      openingStock: (json['openingStock'] ?? 0).toDouble(),
      reorderLevel: (json['reorderLevel'] ?? 0).toDouble(),
      minStock: (json['minStock'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'pcs',
      hotelId: (json['hotelId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toCreateJson() => {
    'name': name,
    if (sku.isNotEmpty) 'sku': sku,
    if (category.isNotEmpty) 'category': category,
    'unit': unit,
    'openingStock': openingStock,
    'reorderLevel': reorderLevel,
    'minStock': minStock,
  };

  Map<String, dynamic> toUpdateJson() => {
    'name': name,
    if (sku.isNotEmpty) 'sku': sku,
    if (category.isNotEmpty) 'category': category,
    'unit': unit,
    'currentStock': currentStock,
    'reorderLevel': reorderLevel,
    'minStock': minStock,
  };

  InventoryItem copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? currentStock,
    double? openingStock,
    double? reorderLevel,
    double? minStock,
    String? unit,
    String? hotelId,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      openingStock: openingStock ?? this.openingStock,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      hotelId: hotelId ?? this.hotelId,
    );
  }
}

// ─── Inventory Transaction ─────────────────────────────────────────────────────
class InventoryTransaction {
  final String id;
  final String materialId;
  final String materialName;
  final String type; // purchase | adjustment | consume | wastage | return
  final double quantity;
  final double unitCost;
  final double totalCost;
  final String note;
  final DateTime createdAt;

  const InventoryTransaction({
    required this.id,
    required this.materialId,
    this.materialName = '',
    required this.type,
    required this.quantity,
    this.unitCost = 0,
    this.totalCost = 0,
    this.note = '',
    required this.createdAt,
  });

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    return InventoryTransaction(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      materialId: (json['materialId'] ?? '').toString(),
      materialName: json['materialName'] ?? '',
      type: json['type'] ?? 'adjustment',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unitCost: (json['unitCost'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      note: json['note'] ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    try {
      return DateTime.parse(val.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}

// ─── Recipe Ingredient ─────────────────────────────────────────────────────────
class RecipeIngredientModel {
  final String materialId;
  final String materialName;
  final double quantity;

  const RecipeIngredientModel({
    required this.materialId,
    this.materialName = '',
    required this.quantity,
  });

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      materialId: (json['materialId'] ?? '').toString(),
      materialName: json['materialName'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'materialId': materialId,
    'quantity': quantity,
  };
}

// ─── Recipe ────────────────────────────────────────────────────────────────────
class RecipeModel {
  final String id;
  final String menuItemId;
  final String variant;
  final double yieldQty;
  final List<RecipeIngredientModel> ingredients;

  const RecipeModel({
    required this.id,
    required this.menuItemId,
    this.variant = 'default',
    this.yieldQty = 1,
    this.ingredients = const [],
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      menuItemId: json['menuItemId'] ?? '',
      variant: json['variant'] ?? 'default',
      yieldQty: (json['yield'] ?? 1).toDouble(),
      ingredients: (json['ingredients'] as List? ?? [])
          .map((e) => RecipeIngredientModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─── Overview Report Series ────────────────────────────────────────────────────
class OverviewSeriesPoint {
  final String dateKey;
  final String type;
  final double totalQty;
  final double totalCost;

  const OverviewSeriesPoint({
    required this.dateKey,
    required this.type,
    required this.totalQty,
    required this.totalCost,
  });

  factory OverviewSeriesPoint.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] as Map<String, dynamic>? ?? {};
    return OverviewSeriesPoint(
      dateKey: id['dateKey']?.toString() ?? '',
      type: id['type']?.toString() ?? '',
      totalQty: (json['totalQty'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
    );
  }
}

// ─── Analytics (derived from overview report) ─────────────────────────────────
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

  factory InventoryAnalytics.fromSeries(List<OverviewSeriesPoint> series) {
    double consume = 0, wastage = 0, cost = 0;
    final Map<String, double> byDate = {};
    for (final s in series) {
      cost += s.totalCost;
      if (s.type == 'consume') {
        consume += s.totalQty;
        byDate[s.dateKey] = (byDate[s.dateKey] ?? 0) + s.totalQty;
      }
      if (s.type == 'wastage') wastage += s.totalQty;
    }
    final efficiency = consume > 0 ? (1 - (wastage / consume)).clamp(0.0, 1.0) : 1.0;
    final trend = byDate.entries
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return InventoryAnalytics(
      totalConsumption: consume,
      totalCost: cost,
      totalWastage: wastage,
      efficiencyScore: efficiency,
      consumptionTrend: trend.map((e) => ChartDataPoint(e.key, e.value)).toList(),
    );
  }

  static const empty = InventoryAnalytics(
    totalConsumption: 0,
    totalCost: 0,
    totalWastage: 0,
    efficiencyScore: 1,
    consumptionTrend: [],
  );
}

class ChartDataPoint {
  final String label;
  final double value;

  const ChartDataPoint(this.label, this.value);
}

// ─── Purchase Order (kept for UI compat, not from backend) ────────────────────
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
}

// ─── Vendor ───────────────────────────────────────────────────────────────────
class VendorModel {
  final String id;
  final String companyName;
  final String contactPerson;
  final String phone;
  final String whatsapp;
  final String email;
  final String address;
  final String gstNumber;
  final String paymentTerms;
  final List<String> supplies;
  final String notes;

  const VendorModel({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.phone,
    this.whatsapp = '',
    this.email = '',
    this.address = '',
    this.gstNumber = '',
    this.paymentTerms = '',
    this.supplies = const [],
    this.notes = '',
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      companyName: json['companyName'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      phone: json['phone'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      gstNumber: json['gstNumber'] ?? '',
      paymentTerms: json['paymentTerms'] ?? '',
      supplies: List<String>.from(json['supplies'] ?? []),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'contactPerson': contactPerson,
    'phone': phone,
    'whatsapp': whatsapp,
    'email': email,
    'address': address,
    'gstNumber': gstNumber,
    'paymentTerms': paymentTerms,
    'supplies': supplies,
    'notes': notes,
  };
}

// ─── Location ─────────────────────────────────────────────────────────────────
class LocationModel {
  final String id;
  final String name;
  final String type;
  final String address;
  final String manager;
  final String phone;

  const LocationModel({
    required this.id,
    required this.name,
    this.type = 'Kitchen',
    this.address = '',
    this.manager = '',
    this.phone = '',
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? 'Kitchen',
      address: json['address'] ?? '',
      manager: json['manager'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'address': address,
    'manager': manager,
    'phone': phone,
  };
}

// ─── Stock Transfer ───────────────────────────────────────────────────────────
class StockTransferModel {
  final String id;
  final String materialId;
  final String materialName;
  final double quantity;
  final String unit;
  final String fromLocationId;
  final String fromLocationName;
  final String toLocationId;
  final String toLocationName;
  final String status; // pending | in_transit | completed | cancelled
  final String note;
  final DateTime createdAt;

  const StockTransferModel({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.quantity,
    this.unit = '',
    required this.fromLocationId,
    required this.fromLocationName,
    required this.toLocationId,
    required this.toLocationName,
    this.status = 'pending',
    this.note = '',
    required this.createdAt,
  });

  factory StockTransferModel.fromJson(Map<String, dynamic> json) {
    return StockTransferModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      materialId: (json['materialId'] ?? '').toString(),
      materialName: json['materialName'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      fromLocationId: (json['fromLocationId'] ?? '').toString(),
      fromLocationName: json['fromLocationName'] ?? '',
      toLocationId: (json['toLocationId'] ?? '').toString(),
      toLocationName: json['toLocationName'] ?? '',
      status: json['status'] ?? 'pending',
      note: json['note'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}

// ─── Price Comparison ─────────────────────────────────────────────────────────
class PriceComparisonItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double currentPrice;
  final String currentVendor;
  final int vendorsAvailable;
  final double potentialSavings;

  const PriceComparisonItem({
    required this.id,
    required this.name,
    this.category = '',
    this.unit = '',
    this.currentPrice = 0,
    this.currentVendor = '',
    this.vendorsAvailable = 0,
    this.potentialSavings = 0,
  });

  factory PriceComparisonItem.fromJson(Map<String, dynamic> json) {
    return PriceComparisonItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      unit: json['unit'] ?? '',
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      currentVendor: json['currentVendor'] ?? '',
      vendorsAvailable: (json['vendorsAvailable'] ?? 0) as int,
      potentialSavings: (json['potentialSavings'] ?? 0).toDouble(),
    );
  }
}

class VendorPriceEntry {
  final String vendorName;
  final double avgUnitCost;
  final int transactionCount;
  final bool isBestPrice;

  const VendorPriceEntry({
    required this.vendorName,
    required this.avgUnitCost,
    this.transactionCount = 0,
    this.isBestPrice = false,
  });

  factory VendorPriceEntry.fromJson(Map<String, dynamic> json, {bool isBestPrice = false}) {
    return VendorPriceEntry(
      vendorName: json['vendorName'] ?? '',
      avgUnitCost: (json['avgUnitCost'] ?? 0).toDouble(),
      transactionCount: (json['transactionCount'] ?? 0) as int,
      isBestPrice: isBestPrice,
    );
  }
}

class PriceComparisonDetail {
  final PriceComparisonItem material;
  final List<VendorPriceEntry> vendorPrices;
  final double potentialMonthlySavings;
  final List<PriceComparisonItem> allItems;

  const PriceComparisonDetail({
    required this.material,
    required this.vendorPrices,
    required this.potentialMonthlySavings,
    required this.allItems,
  });

  factory PriceComparisonDetail.fromJson(Map<String, dynamic> json) {
    final rawPrices = (json['vendorPrices'] as List? ?? []);
    final prices = rawPrices.asMap().entries.map((e) =>
        VendorPriceEntry.fromJson(e.value, isBestPrice: e.key == 0)).toList();
    return PriceComparisonDetail(
      material: PriceComparisonItem.fromJson(json['material'] as Map<String, dynamic>? ?? {}),
      vendorPrices: prices,
      potentialMonthlySavings: (json['potentialMonthlySavings'] ?? 0).toDouble(),
      allItems: (json['items'] as List? ?? []).map((e) => PriceComparisonItem.fromJson(e)).toList(),
    );
  }
}

// ─── Forecasting ──────────────────────────────────────────────────────────────
class ForecastItem {
  final String id;
  final String name;
  final String unit;
  final double currentStock;
  final double avgDailyUse;
  final int daysLeft;
  final String reorderDate;
  final String status; // critical | warning | healthy
  final int confidence;

  const ForecastItem({
    required this.id,
    required this.name,
    this.unit = '',
    required this.currentStock,
    required this.avgDailyUse,
    required this.daysLeft,
    this.reorderDate = '',
    this.status = 'healthy',
    this.confidence = 0,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      currentStock: (json['currentStock'] ?? 0).toDouble(),
      avgDailyUse: (json['avgDailyUse'] ?? 0).toDouble(),
      daysLeft: (json['daysLeft'] ?? 999) as int,
      reorderDate: json['reorderDate'] ?? '',
      status: json['status'] ?? 'healthy',
      confidence: (json['confidence'] ?? 0) as int,
    );
  }
}

class ForecastingData {
  final List<ForecastItem> forecasts;
  final int criticalCount;
  final int warningCount;
  final int healthyCount;
  final int avgConfidence;
  final List<String> urgentItems;

  const ForecastingData({
    required this.forecasts,
    required this.criticalCount,
    required this.warningCount,
    required this.healthyCount,
    required this.avgConfidence,
    required this.urgentItems,
  });

  factory ForecastingData.fromJson(Map<String, dynamic> json) {
    final kpi = json['kpi'] as Map<String, dynamic>? ?? {};
    return ForecastingData(
      forecasts: (json['forecasts'] as List? ?? []).map((e) => ForecastItem.fromJson(e)).toList(),
      criticalCount: (kpi['critical'] ?? 0) as int,
      warningCount: (kpi['warning'] ?? 0) as int,
      healthyCount: (kpi['healthy'] ?? 0) as int,
      avgConfidence: (kpi['avgConfidence'] ?? 0) as int,
      urgentItems: List<String>.from(json['urgentItems'] ?? []),
    );
  }

  static const empty = ForecastingData(
    forecasts: [],
    criticalCount: 0,
    warningCount: 0,
    healthyCount: 0,
    avgConfidence: 0,
    urgentItems: [],
  );
}
