import 'package:equatable/equatable.dart';

class ZoneModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final String hotelId;

  const ZoneModel({
    required this.id,
    required this.name,
    this.description = '',
    this.isActive = true,
    required this.hotelId,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      hotelId: json['hotelId'] is Map
          ? (json['hotelId']['_id'] as String? ?? '')
          : (json['hotelId'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }

  ZoneModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    String? hotelId,
  }) {
    return ZoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      hotelId: hotelId ?? this.hotelId,
    );
  }

  @override
  List<Object?> get props => [id, name, description, isActive, hotelId];
}
