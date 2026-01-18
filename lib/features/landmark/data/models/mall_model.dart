import 'package:equatable/equatable.dart';

/// Coordinates model for GeoJSON Point
class CoordinatesModel extends Equatable {
  final String type;
  final List<double> coordinates;
  final String? address;

  const CoordinatesModel({
    this.type = 'Point',
    this.coordinates = const [],
    this.address,
  });

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) {
    return CoordinatesModel(
      type: json['type'] as String? ?? 'Point',
      coordinates:
          (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates, 'address': address};
  }

  @override
  List<Object?> get props => [type, coordinates, address];
}

/// Mall model matching the backend schema
class MallModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String location;
  final CoordinatesModel? coordinates;
  final String mainImage;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MallModel({
    required this.id,
    required this.name,
    this.description = '',
    this.location = '',
    this.coordinates,
    this.mainImage = '',
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory MallModel.fromJson(Map<String, dynamic> json) {
    return MallModel(
      id: json['_id'] as String? ?? '', // Maps _id from Mongo
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      coordinates: json['coordinates'] != null
          ? CoordinatesModel.fromJson(
              json['coordinates'] as Map<String, dynamic>,
            )
          : null,
      mainImage: json['mainImage'] as String? ?? '',
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Get latitude from coordinates
  double? get latitude {
    if (coordinates != null && coordinates!.coordinates.length >= 2) {
      return coordinates!.coordinates[1]; // GeoJSON: [lng, lat]
    }
    return null;
  }

  /// Get longitude from coordinates
  double? get longitude {
    if (coordinates != null && coordinates!.coordinates.length >= 2) {
      return coordinates!.coordinates[0]; // GeoJSON: [lng, lat]
    }
    return null;
  }

  /// Get display address
  String get displayAddress {
    if (coordinates?.address != null && coordinates!.address!.isNotEmpty) {
      return coordinates!.address!;
    }
    return location;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    location,
    coordinates,
    mainImage,
    isDeleted,
    createdAt,
    updatedAt,
  ];
}

/// Request model for creating a mall
class CreateMallRequest {
  final String name;
  final String? description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? address;

  const CreateMallRequest({
    required this.name,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}

/// Request model for updating a mall
class UpdateMallRequest {
  final String? name;
  final String? description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? address;

  const UpdateMallRequest({
    this.name,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.address,
  });
}

/// Response model for paginated malls list
class MallsListResponse {
  final List<MallModel> malls;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const MallsListResponse({
    required this.malls,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MallsListResponse.fromJson(Map<String, dynamic> json) {
    // API Response structure:
    // { success: true, statusCode: 200, message: "...", data: [...], pagination: {...} }
    // 'data' is a direct array of malls, 'pagination' is at root level

    // Get the malls array - it's directly under 'data' key
    final dynamic dataField = json['data'];
    List<dynamic> mallsList = [];

    if (dataField is List) {
      mallsList = dataField;
    } else if (dataField is Map<String, dynamic>) {
      // Fallback: if data is an object with 'malls' key
      mallsList = (dataField['malls'] as List<dynamic>?) ?? [];
    }

    // Get pagination from root level
    final pagination = (json['pagination'] as Map<String, dynamic>?) ?? {};

    return MallsListResponse(
      malls: mallsList
          .map((e) => MallModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: pagination['total'] as int? ?? mallsList.length,
      page: pagination['page'] as int? ?? 1,
      limit: pagination['limit'] as int? ?? 10,
      totalPages:
          pagination['pages'] as int? ?? pagination['totalPages'] as int? ?? 1,
    );
  }
}
