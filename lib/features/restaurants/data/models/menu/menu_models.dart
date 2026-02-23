/// Menu-related models for restaurant menu management

class FoodItemOption {
  final String label;
  final double price;

  FoodItemOption({
    required this.label,
    required this.price,
  });

  factory FoodItemOption.fromJson(Map<String, dynamic> json) {
    return FoodItemOption(
      label: json['label'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'price': price,
      };
}

class FoodItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final String? image;
  final List<String> itemType;
  final List<String> attributes;
  final List<FoodItemOption> options;
  final String? sortdesc;
  final String? offer;
  final String? station;
  final int? basePrepTimeMinutes;
  final double? complexityFactor;
  final int? maxPerSlot;
  final bool isKitchenDisabled;
  final bool? isVeg;
  final bool? isNonVeg;
  final bool? isEgg;
  final bool? spicy;

  FoodItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.price,
    this.image,
    this.itemType = const [],
    this.attributes = const [],
    this.options = const [],
    this.sortdesc,
    this.offer,
    this.station,
    this.basePrepTimeMinutes,
    this.complexityFactor,
    this.maxPerSlot,
    this.isKitchenDisabled = false,
    this.isVeg,
    this.isNonVeg,
    this.isEgg,
    this.spicy,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      image: json['image'] as String?,
      itemType: (json['itemType'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => FoodItemOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sortdesc: json['sortdesc'] as String?,
      offer: json['offer'] as String?,
      station: json['station'] as String?,
      basePrepTimeMinutes: json['basePrepTimeMinutes'] as int?,
      complexityFactor: (json['complexityFactor'] as num?)?.toDouble(),
      maxPerSlot: json['maxPerSlot'] as int?,
      isKitchenDisabled: json['isKitchenDisabled'] as bool? ?? false,
      isVeg: json['isVeg'] as bool?,
      isNonVeg: json['isNonVeg'] as bool?,
      isEgg: json['isEgg'] as bool?,
      spicy: json['spicy'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        if (image != null) 'image': image,
        'itemType': itemType,
        'attributes': attributes,
        'options': options.map((e) => e.toJson()).toList(),
        if (sortdesc != null) 'sortdesc': sortdesc,
        if (offer != null) 'offer': offer,
        if (station != null) 'station': station,
        if (basePrepTimeMinutes != null)
          'basePrepTimeMinutes': basePrepTimeMinutes,
        if (complexityFactor != null) 'complexityFactor': complexityFactor,
        if (maxPerSlot != null) 'maxPerSlot': maxPerSlot,
        'isKitchenDisabled': isKitchenDisabled,
        if (isVeg != null) 'isVeg': isVeg,
        if (isNonVeg != null) 'isNonVeg': isNonVeg,
        if (isEgg != null) 'isEgg': isEgg,
        if (spicy != null) 'spicy': spicy,
      };

  FoodItem copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? image,
    List<String>? itemType,
    List<String>? attributes,
    List<FoodItemOption>? options,
    String? sortdesc,
    String? offer,
    String? station,
    int? basePrepTimeMinutes,
    double? complexityFactor,
    int? maxPerSlot,
    bool? isKitchenDisabled,
    bool? isVeg,
    bool? isNonVeg,
    bool? isEgg,
    bool? spicy,
  }) {
    return FoodItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      itemType: itemType ?? this.itemType,
      attributes: attributes ?? this.attributes,
      options: options ?? this.options,
      sortdesc: sortdesc ?? this.sortdesc,
      offer: offer ?? this.offer,
      station: station ?? this.station,
      basePrepTimeMinutes: basePrepTimeMinutes ?? this.basePrepTimeMinutes,
      complexityFactor: complexityFactor ?? this.complexityFactor,
      maxPerSlot: maxPerSlot ?? this.maxPerSlot,
      isKitchenDisabled: isKitchenDisabled ?? this.isKitchenDisabled,
      isVeg: isVeg ?? this.isVeg,
      isNonVeg: isNonVeg ?? this.isNonVeg,
      isEgg: isEgg ?? this.isEgg,
      spicy: spicy ?? this.spicy,
    );
  }
}

class MenuCategory {
  final String name;
  final String image;
  final List<FoodItem> items;

  MenuCategory({
    required this.name,
    required this.image,
    this.items = const [],
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': image,
        'items': items.map((e) => e.toJson()).toList(),
      };

  MenuCategory copyWith({
    String? name,
    String? image,
    List<FoodItem>? items,
  }) {
    return MenuCategory(
      name: name ?? this.name,
      image: image ?? this.image,
      items: items ?? this.items,
    );
  }
}

class MenuSettings {
  final List<String> itemTypes;
  final List<String> attributes;

  MenuSettings({
    this.itemTypes = const [],
    this.attributes = const [],
  });

  factory MenuSettings.fromJson(Map<String, dynamic> json) {
    return MenuSettings(
      itemTypes: (json['itemTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'itemTypes': itemTypes,
        'attributes': attributes,
      };

  MenuSettings copyWith({
    List<String>? itemTypes,
    List<String>? attributes,
  }) {
    return MenuSettings(
      itemTypes: itemTypes ?? this.itemTypes,
      attributes: attributes ?? this.attributes,
    );
  }
}

class ExtractedMenuItem {
  final String title;
  final double price;
  final String description;
  final bool isVeg;
  final bool isNonVeg;
  final bool isEgg;
  final bool spicy;

  ExtractedMenuItem({
    required this.title,
    required this.price,
    this.description = '',
    this.isVeg = false,
    this.isNonVeg = false,
    this.isEgg = false,
    this.spicy = false,
  });

  factory ExtractedMenuItem.fromJson(Map<String, dynamic> json) {
    return ExtractedMenuItem(
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      isVeg: json['isVeg'] as bool? ?? false,
      isNonVeg: json['isNonVeg'] as bool? ?? false,
      isEgg: json['isEgg'] as bool? ?? false,
      spicy: json['spicy'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'price': price,
        'description': description,
        'isVeg': isVeg,
        'isNonVeg': isNonVeg,
        'isEgg': isEgg,
        'spicy': spicy,
      };
}

class ExtractedCategory {
  final String name;
  final List<ExtractedMenuItem> items;

  ExtractedCategory({
    required this.name,
    this.items = const [],
  });

  factory ExtractedCategory.fromJson(Map<String, dynamic> json) {
    return ExtractedCategory(
      name: json['name'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ExtractedMenuItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class ExtractMenuResponse {
  final List<ExtractedCategory> categories;
  final int totalCategories;
  final int totalItems;

  ExtractMenuResponse({
    this.categories = const [],
    this.totalCategories = 0,
    this.totalItems = 0,
  });

  factory ExtractMenuResponse.fromJson(Map<String, dynamic> json) {
    return ExtractMenuResponse(
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => ExtractedCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCategories: json['totalCategories'] as int? ?? 0,
      totalItems: json['totalItems'] as int? ?? 0,
    );
  }
}

class ImportMenuResponse {
  final int categoriesAdded;
  final int itemsAdded;
  final int totalCategories;

  ImportMenuResponse({
    this.categoriesAdded = 0,
    this.itemsAdded = 0,
    this.totalCategories = 0,
  });

  factory ImportMenuResponse.fromJson(Map<String, dynamic> json) {
    return ImportMenuResponse(
      categoriesAdded: json['categoriesAdded'] as int? ?? 0,
      itemsAdded: json['itemsAdded'] as int? ?? 0,
      totalCategories: json['totalCategories'] as int? ?? 0,
    );
  }
}

class KitchenStation {
  final String code;
  final String name;

  KitchenStation({
    required this.code,
    required this.name,
  });

  factory KitchenStation.fromJson(Map<String, dynamic> json) {
    return KitchenStation(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  static List<KitchenStation> defaultStations = [
    KitchenStation(code: 'tandoor', name: 'Tandoor'),
    KitchenStation(code: 'main_course', name: 'Main Course'),
    KitchenStation(code: 'starters', name: 'Starters'),
    KitchenStation(code: 'desserts', name: 'Desserts'),
    KitchenStation(code: 'beverages', name: 'Beverages'),
    KitchenStation(code: 'grill', name: 'Grill'),
    KitchenStation(code: 'fry', name: 'Fry Station'),
    KitchenStation(code: 'salads', name: 'Salads'),
  ];
}

class ComplexityOption {
  final double value;
  final String label;

  ComplexityOption({
    required this.value,
    required this.label,
  });

  static List<ComplexityOption> options = [
    ComplexityOption(value: 0.8, label: 'Simple (0.8x)'),
    ComplexityOption(value: 1.0, label: 'Medium (1.0x)'),
    ComplexityOption(value: 1.3, label: 'Complex (1.3x)'),
    ComplexityOption(value: 1.5, label: 'Very Complex (1.5x)'),
  ];
}
