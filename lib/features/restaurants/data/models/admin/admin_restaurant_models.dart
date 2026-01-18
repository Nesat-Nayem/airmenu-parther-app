import 'package:flutter/material.dart';

/// Model for individual restaurant (hotel)
class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final String distance;
  final String cuisine;
  final String price;
  final double rating;
  final String mainImage;
  final String offer;
  final String createdAt;
  final String updatedAt;
  final String? address;
  final String? phone;
  final String? email;
  final List<String>? cuisines;
  final double? latitude;
  final double? longitude;
  final bool? isActive;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.distance,
    required this.cuisine,
    required this.price,
    required this.rating,
    required this.mainImage,
    required this.offer,
    required this.createdAt,
    required this.updatedAt,
    this.address,
    this.phone,
    this.email,
    this.cuisines,
    this.latitude,
    this.longitude,
    this.isActive,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? json['address'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      cuisine: json['cuisine'] as String? ?? '',
      price: json['price'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      mainImage: (json['mainImage'] as String? ?? '').trim(),
      offer: json['offer'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      cuisines: (json['cuisines'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'location': location,
      'distance': distance,
      'cuisine': cuisine,
      'price': price,
      'rating': rating,
      'mainImage': mainImage,
      'offer': offer,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (cuisines != null) 'cuisines': cuisines,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isActive != null) 'isActive': isActive,
    };
  }

  /// Get rating color based on rating value
  Color get ratingColor {
    if (rating >= 4.5) {
      return const Color(0xFF10B981);
    } else if (rating >= 3.5) {
      return const Color(0xFFF59E0B);
    } else if (rating >= 2.0) {
      return const Color(0xFFEF4444);
    } else {
      return const Color(0xFF6B7280);
    }
  }

  /// Get cuisine badge color
  Color get cuisineColor {
    final cuisineLower = cuisine.toLowerCase();
    if (cuisineLower.contains('indian')) {
      return const Color(0xFFEF4444);
    } else if (cuisineLower.contains('chinese')) {
      return const Color(0xFFF59E0B);
    } else if (cuisineLower.contains('fast food')) {
      return const Color(0xFF8B5CF6);
    } else if (cuisineLower.contains('non-veg')) {
      return const Color(0xFFDC2626);
    } else {
      return const Color(0xFF3B82F6);
    }
  }

  /// Get first letter for avatar
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'R';

  String get shortLocation {
    final parts = location.split(',');
    return parts.isNotEmpty ? parts[0].trim() : location;
  }

  String? get primaryCuisine => cuisine;
  String get contactNumber => phone ?? 'N/A';
  String get contactEmail => email ?? 'N/A';
}

/// Model for restaurant stats
class RestaurantStatsModel {
  final int total;
  final int active;
  final int pending;
  final int suspended;

  RestaurantStatsModel({
    required this.total,
    required this.active,
    required this.pending,
    required this.suspended,
  });

  factory RestaurantStatsModel.fromJson(Map<String, dynamic> json) {
    return RestaurantStatsModel(
      total: json['total'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      suspended: json['suspended'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'pending': pending,
      'suspended': suspended,
    };
  }

  /// Convert stats to stat cards data
  List<StatCardData> toStatCards() {
    return [
      StatCardData(
        label: 'Total Restaurants',
        value: total.toString(),
        icon: Icons.restaurant,
        color: const Color(0xFF3B82F6),
      ),
      StatCardData(
        label: 'Active',
        value: active.toString(),
        icon: Icons.check_circle,
        color: const Color(0xFF10B981),
      ),
      StatCardData(
        label: 'Pending',
        value: pending.toString(),
        icon: Icons.pending,
        color: const Color(0xFFF59E0B),
      ),
      StatCardData(
        label: 'Suspended',
        value: suspended.toString(),
        icon: Icons.block,
        color: const Color(0xFFEF4444),
      ),
    ];
  }
}

/// Model for stat card data
class StatCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

/// Model for restaurant filters
class RestaurantFiltersModel {
  final String? searchQuery;
  final String? cuisine;
  final bool? isActive;
  final double? rating;
  final String? sortBy;
  final String? sortOrder;

  RestaurantFiltersModel({
    this.searchQuery,
    this.cuisine,
    this.isActive,
    this.rating,
    this.sortBy,
    this.sortOrder,
  });

  factory RestaurantFiltersModel.fromJson(Map<String, dynamic> json) {
    return RestaurantFiltersModel(
      searchQuery: json['search'] as String?,
      cuisine: json['cuisine'] as String?,
      isActive: json['isActive'] as bool?,
      rating: (json['rating'] as num?)?.toDouble(),
      sortBy: json['sortBy'] as String?,
      sortOrder: json['sortOrder'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      map['search'] = searchQuery;
    }
    if (cuisine != null && cuisine!.isNotEmpty) {
      map['cuisine'] = cuisine;
    }
    if (isActive != null) {
      map['isActive'] = isActive.toString();
    }
    if (rating != null) {
      map['rating'] = rating.toString();
    }
    if (sortBy != null) map['sortBy'] = sortBy;
    if (sortOrder != null) map['sortOrder'] = sortOrder;
    return map;
  }

  RestaurantFiltersModel copyWith({
    String? searchQuery,
    String? cuisine,
    bool? isActive,
    double? rating,
    String? sortBy,
    String? sortOrder,
  }) {
    return RestaurantFiltersModel(
      searchQuery: searchQuery ?? this.searchQuery,
      cuisine: cuisine ?? this.cuisine,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool get hasActiveFilters {
    return (searchQuery != null && searchQuery!.isNotEmpty) ||
        (cuisine != null && cuisine!.isNotEmpty) ||
        isActive != null ||
        rating != null;
  }
}

/// Model for restaurant list response
class RestaurantListResponseModel {
  final List<RestaurantModel> restaurants;
  final int total;
  final int page;
  final int limit;
  final int pages;
  final bool hasMore;

  RestaurantListResponseModel({
    required this.restaurants,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    required this.hasMore,
  });

  factory RestaurantListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    final restaurants = data
        .map((item) => RestaurantModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final page = pagination['page'] as int? ?? 1;
    final pages = pagination['pages'] as int? ?? 1;

    return RestaurantListResponseModel(
      restaurants: restaurants,
      total: pagination['total'] as int? ?? 0,
      page: page,
      limit: pagination['limit'] as int? ?? 10,
      pages: pages,
      hasMore: page < pages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': restaurants.map((r) => r.toJson()).toList(),
      'pagination': {
        'total': total,
        'page': page,
        'limit': limit,
        'pages': pages,
      },
    };
  }
}

/// Model for creating/updating restaurant
class RestaurantFormModel {
  final String name;
  final String? description;
  final String address;
  final String? phone;
  final String? email;
  final String? mainImagePath;
  final List<String>? cuisines;
  final double? latitude;
  final double? longitude;

  RestaurantFormModel({
    required this.name,
    this.description,
    required this.address,
    this.phone,
    this.email,
    this.mainImagePath,
    this.cuisines,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty)
        'description': description,
      'address': address,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (cuisines != null && cuisines!.isNotEmpty) 'cuisines': cuisines,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
