class PricingPlanModel {
  final String id;
  final String title;
  final String price;
  final String description;
  final List<String> features;
  final String color;

  const PricingPlanModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.features,
    required this.color,
  });

  factory PricingPlanModel.fromJson(Map<String, dynamic> json) {
    return PricingPlanModel(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      price: (json['price'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      features: (json['features'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      color: (json['color'] ?? '#DC2626').toString(),
    );
  }

  Map<String, dynamic> toCreateJson() => {
    'title': title,
    'price': price,
    'description': description,
    'features': features,
    'color': color,
  };
}
