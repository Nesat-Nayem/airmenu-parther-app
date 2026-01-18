/// Simple hotel model for hotel selection in Kitchen Panel
class HotelModel {
  final String? id;
  final String? name;
  final String? logo;
  final String? address;
  final bool? isActive;

  const HotelModel({
    this.id,
    this.name,
    this.logo,
    this.address,
    this.isActive,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString(),
      logo: json['logo']?.toString(),
      address: json['address']?.toString(),
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo': logo,
    'address': address,
    'isActive': isActive,
  };
}
