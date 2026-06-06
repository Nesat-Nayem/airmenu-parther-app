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
  // Backed by nullable storage so legacy/stale instances (e.g. after a hot
  // reload) or a null from the API never throw a type error. Read them through
  // the [vendorId] / [vendorName] getters which coalesce to ''.
  final String? _vendorId;
  final String? _vendorName;

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
    String? vendorId,
    String? vendorName,
  })  : _vendorId = vendorId,
        _vendorName = vendorName;

  String get vendorId => _vendorId ?? '';
  String get vendorName => _vendorName ?? '';

  // Stock status is driven by the minimum-stock threshold: at or below minimum
  // stock is treated as critical, with a small warning band just above it.
  StockStatus get status {
    if (currentStock <= 0) return StockStatus.critical;
    if (minStock > 0) {
      if (currentStock <= minStock) return StockStatus.critical;
      if (currentStock <= minStock * 1.5) return StockStatus.low;
    }
    return StockStatus.healthy;
  }

  // maxStock is only used to scale the progress bar. With stock now driven by
  // POs, derive a sensible ceiling from the minimum-stock threshold.
  double get maxStock {
    if (minStock > 0) return (minStock * 2).clamp(1, double.infinity);
    if (currentStock > 0) return currentStock;
    return 1;
  }

  double get stockPercentage => (currentStock / maxStock).clamp(0.0, 1.0);

  // Legacy compat kept for UI
  ConsumptionLevel get consumption {
    if (status == StockStatus.critical) return ConsumptionLevel.high;
    if (status == StockStatus.low) return ConsumptionLevel.medium;
    return ConsumptionLevel.low;
  }

  String get vendor => vendorName;
  double get costPrice => 0;

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    // vendorId may be a populated object ({_id, companyName}) or a raw id string.
    final rawVendor = json['vendorId'];
    String vId = '';
    String vName = '';
    if (rawVendor is Map) {
      vId = (rawVendor['_id'] ?? '').toString();
      vName = (rawVendor['companyName'] ?? '').toString();
    } else if (rawVendor != null) {
      vId = rawVendor.toString();
    }
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
      vendorId: vId,
      vendorName: vName,
    );
  }

  // Stock is now populated via received purchase orders, so creation no longer
  // sends an opening/current stock or a vendor association.
  Map<String, dynamic> toCreateJson() => {
    'name': name,
    if (sku.isNotEmpty) 'sku': sku,
    if (category.isNotEmpty) 'category': category,
    'unit': unit,
    'minStock': minStock,
  };

  Map<String, dynamic> toUpdateJson() => {
    'name': name,
    if (sku.isNotEmpty) 'sku': sku,
    if (category.isNotEmpty) 'category': category,
    'unit': unit,
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
    String? vendorId,
    String? vendorName,
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
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
    );
  }
}

// ─── Inventory Transaction ─────────────────────────────────────────────────────
class InventoryTransaction {
  final String id;
  final String materialId;
  final String materialName;
  final String materialUnit;
  final String type; // purchase | adjustment | consume | wastage | return
  final String? direction; // in | out — set for adjustments and inferred for other types
  final double quantity;
  final double unitCost;
  final double totalCost;
  final String note;
  final DateTime createdAt;

  const InventoryTransaction({
    required this.id,
    required this.materialId,
    this.materialName = '',
    this.materialUnit = '',
    required this.type,
    this.direction,
    required this.quantity,
    this.unitCost = 0,
    this.totalCost = 0,
    this.note = '',
    required this.createdAt,
  });

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    // materialId may be a populated object ({_id, name, unit}) or a raw id.
    final rawMat = json['materialId'];
    String matId = '';
    String matName = (json['materialName'] ?? '').toString();
    String matUnit = (json['materialUnit'] ?? '').toString();
    if (rawMat is Map) {
      matId = (rawMat['_id'] ?? '').toString();
      if (matName.isEmpty) matName = (rawMat['name'] ?? '').toString();
      if (matUnit.isEmpty) matUnit = (rawMat['unit'] ?? '').toString();
    } else if (rawMat != null) {
      matId = rawMat.toString();
    }
    return InventoryTransaction(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      materialId: matId,
      materialName: matName,
      materialUnit: matUnit,
      type: json['type'] ?? 'adjustment',
      direction: json['direction']?.toString(),
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
  final String materialUnit;
  final double quantity;

  const RecipeIngredientModel({
    required this.materialId,
    this.materialName = '',
    this.materialUnit = '',
    required this.quantity,
  });

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      materialId: (json['materialId'] ?? '').toString(),
      materialName: (json['materialName'] ?? '').toString(),
      materialUnit: (json['materialUnit'] ?? '').toString(),
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
  final String menuItemName;
  final String variant;
  final double yieldQty;
  final List<RecipeIngredientModel> ingredients;

  const RecipeModel({
    required this.id,
    required this.menuItemId,
    this.menuItemName = '',
    this.variant = 'default',
    this.yieldQty = 1,
    this.ingredients = const [],
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      menuItemId: (json['menuItemId'] ?? '').toString(),
      menuItemName: (json['menuItemName'] ?? '').toString(),
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

// ─── Purchase Order ───────────────────────────────────────────────────────────
enum PurchaseOrderStatus {
  pending,
  received,
  cancelled;

  Color get color {
    switch (this) {
      case PurchaseOrderStatus.pending:
        return const Color(0xFFF59E0B);
      case PurchaseOrderStatus.received:
        return const Color(0xFF10B981);
      case PurchaseOrderStatus.cancelled:
        return const Color(0xFF6B7280);
    }
  }

  String get label => name[0].toUpperCase() + name.substring(1);

  static PurchaseOrderStatus fromString(String? s) {
    switch (s) {
      case 'received':
        return PurchaseOrderStatus.received;
      case 'cancelled':
        return PurchaseOrderStatus.cancelled;
      default:
        return PurchaseOrderStatus.pending;
    }
  }
}

class PurchaseOrderItem {
  final String materialId;
  final String materialName;
  final String unit;
  final double quantity;
  final double unitPrice;
  final double lineTotal;

  const PurchaseOrderItem({
    required this.materialId,
    this.materialName = '',
    this.unit = '',
    this.quantity = 0,
    this.unitPrice = 0,
    this.lineTotal = 0,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    final rawMat = json['materialId'];
    final matId = rawMat is Map ? (rawMat['_id'] ?? '').toString() : (rawMat ?? '').toString();
    final qty = (json['quantity'] ?? 0).toDouble();
    final price = (json['unitPrice'] ?? 0).toDouble();
    return PurchaseOrderItem(
      materialId: matId,
      materialName: (json['materialName'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      quantity: qty,
      unitPrice: price,
      lineTotal: (json['lineTotal'] ?? (qty * price)).toDouble(),
    );
  }
}

class PurchaseOrder {
  final String id;
  final String vendorId;
  final String vendorName;
  final List<PurchaseOrderItem> items;
  final PurchaseOrderStatus status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? expectedDelivery;
  final DateTime? receivedAt;
  final String notes;

  const PurchaseOrder({
    required this.id,
    this.vendorId = '',
    this.vendorName = '',
    this.items = const [],
    this.status = PurchaseOrderStatus.pending,
    this.totalAmount = 0,
    required this.createdAt,
    this.expectedDelivery,
    this.receivedAt,
    this.notes = '',
  });

  int get itemCount => items.length;
  double get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);

  static DateTime? _tryDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    final rawVendor = json['vendorId'];
    final vId = rawVendor is Map ? (rawVendor['_id'] ?? '').toString() : (rawVendor ?? '').toString();
    return PurchaseOrder(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      vendorId: vId,
      vendorName: (json['vendorName'] ?? '').toString(),
      items: (json['items'] as List? ?? [])
          .map((e) => PurchaseOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: PurchaseOrderStatus.fromString(json['status']?.toString()),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt: _tryDate(json['createdAt']) ?? DateTime.now(),
      expectedDelivery: _tryDate(json['expectedDelivery']),
      receivedAt: _tryDate(json['receivedAt']),
      notes: (json['notes'] ?? '').toString(),
    );
  }
}

// ─── Vendor Supplied Item (material + the vendor's price) ─────────────────────
class SuppliedItem {
  final String materialId;
  final String materialName;
  final double price;

  const SuppliedItem({
    required this.materialId,
    this.materialName = '',
    this.price = 0,
  });

  factory SuppliedItem.fromJson(Map<String, dynamic> json) {
    final rawMat = json['materialId'];
    final matId = rawMat is Map ? (rawMat['_id'] ?? '').toString() : (rawMat ?? '').toString();
    return SuppliedItem(
      materialId: matId,
      materialName: (json['materialName'] ?? '').toString(),
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'materialId': materialId,
    'materialName': materialName,
    'price': price,
  };

  SuppliedItem copyWith({String? materialId, String? materialName, double? price}) {
    return SuppliedItem(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      price: price ?? this.price,
    );
  }
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
  final List<SuppliedItem> suppliedItems;
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
    this.suppliedItems = const [],
    this.notes = '',
  });

  // Convenience for legacy UI that only needs the supplied material names.
  List<String> get supplies => suppliedItems.map((e) => e.materialName).where((n) => n.isNotEmpty).toList();

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    // Prefer the new priced `suppliedItems`; fall back to the legacy list of
    // plain material-name strings so older vendor records keep working.
    final rawSupplied = json['suppliedItems'];
    List<SuppliedItem> supplied;
    if (rawSupplied is List && rawSupplied.isNotEmpty) {
      supplied = rawSupplied.map((e) => SuppliedItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      supplied = List<String>.from(json['supplies'] ?? [])
          .map((name) => SuppliedItem(materialId: '', materialName: name))
          .toList();
    }
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
      suppliedItems: supplied,
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
    'suppliedItems': suppliedItems.map((e) => e.toJson()).toList(),
    // Keep the legacy `supplies` name list populated for backward compatibility.
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
