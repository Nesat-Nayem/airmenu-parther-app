import 'package:equatable/equatable.dart';

class ComboModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<ComboItemModel> items;
  final double originalPrice;
  final double comboPrice;
  final double savings;
  final String? image;
  final bool isActive;
  final int orderCount;
  final List<String> validDays;
  final String? validTimeStart;
  final String? validTimeEnd;
  final DateTime? validDateStart;
  final DateTime? validDateEnd;
  final int? usageLimit;
  final int usedCount;

  const ComboModel({
    required this.id,
    required this.title,
    required this.description,
    required this.items,
    required this.originalPrice,
    required this.comboPrice,
    required this.savings,
    this.image,
    required this.isActive,
    required this.orderCount,
    required this.validDays,
    this.validTimeStart,
    this.validTimeEnd,
    this.validDateStart,
    this.validDateEnd,
    this.usageLimit,
    this.usedCount = 0,
  });

  factory ComboModel.fromJson(Map<String, dynamic> json) {
    return ComboModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      items:
          (json['items'] as List?)
              ?.map((e) => ComboItemModel.fromJson(e))
              .toList() ??
          [],
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      comboPrice: (json['comboPrice'] as num?)?.toDouble() ?? 0.0,
      savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
      image: json['image'],
      isActive: json['isActive'] ?? true,
      orderCount: json['orderCount'] ?? 0,
      validDays:
          (json['validDays'] as List?)?.map((e) => e.toString()).toList() ??
          const [
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
            'sunday',
          ],
      validTimeStart: json['validTimeStart'],
      validTimeEnd: json['validTimeEnd'],
      validDateStart: json['validDateStart'] != null
          ? DateTime.tryParse(json['validDateStart'])
          : null,
      validDateEnd: json['validDateEnd'] != null
          ? DateTime.tryParse(json['validDateEnd'])
          : null,
      usageLimit: json['usageLimit'],
      usedCount: json['usedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson({String? hotelId}) {
    final map = {
      'title': title,
      'description': description,
      'items': items.map((e) => e.toJson()).toList(),
      'comboPrice': comboPrice,
      'image': image,
      'validDays': validDays,
      'validTimeStart': validTimeStart,
      'validTimeEnd': validTimeEnd,
      'validDateStart': validDateStart?.toIso8601String(),
      'validDateEnd': validDateEnd?.toIso8601String(),
      'usageLimit': usageLimit,
    };

    if (hotelId != null) {
      map['hotelId'] = hotelId;
    }

    return map;
  }

  factory ComboModel.empty() {
    return const ComboModel(
      id: '',
      title: '',
      description: '',
      items: [],
      originalPrice: 0,
      comboPrice: 0,
      savings: 0,
      isActive: true,
      orderCount: 0,
      validDays: [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ],
    );
  }

  ComboModel copyWith({
    String? id,
    String? title,
    String? description,
    List<ComboItemModel>? items,
    double? originalPrice,
    double? comboPrice,
    double? savings,
    String? image,
    bool? isActive,
    int? orderCount,
    List<String>? validDays,
    String? validTimeStart,
    String? validTimeEnd,
    DateTime? validDateStart,
    DateTime? validDateEnd,
    int? usageLimit,
    int? usedCount,
  }) {
    return ComboModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      items: items ?? this.items,
      originalPrice: originalPrice ?? this.originalPrice,
      comboPrice: comboPrice ?? this.comboPrice,
      savings: savings ?? this.savings,
      image: image ?? this.image,
      isActive: isActive ?? this.isActive,
      orderCount: orderCount ?? this.orderCount,
      validDays: validDays ?? this.validDays,
      validTimeStart: validTimeStart ?? this.validTimeStart,
      validTimeEnd: validTimeEnd ?? this.validTimeEnd,
      validDateStart: validDateStart ?? this.validDateStart,
      validDateEnd: validDateEnd ?? this.validDateEnd,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    items,
    originalPrice,
    comboPrice,
    savings,
    image,
    isActive,
    orderCount,
    validDays,
    validTimeStart,
    validTimeEnd,
    validDateStart,
    validDateEnd,
    usageLimit,
    usedCount,
  ];

  String get name => title;
  String get priceDisplay => '₹${comboPrice.toStringAsFixed(0)}';
  String get originalPriceDisplay => '₹${originalPrice.toStringAsFixed(0)}';
  String get savingsDisplay => '₹${savings.toStringAsFixed(0)}';
  String get ordersDisplay => '$orderCount orders';
}

class ComboItemModel extends Equatable {
  final String name;
  final double originalPrice;
  final int quantity;

  const ComboItemModel({
    required this.name,
    required this.originalPrice,
    required this.quantity,
  });

  factory ComboItemModel.fromJson(Map<String, dynamic> json) {
    return ComboItemModel(
      name: json['name'] ?? '',
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'originalPrice': originalPrice, 'quantity': quantity};
  }

  @override
  List<Object?> get props => [name, originalPrice, quantity];
}
