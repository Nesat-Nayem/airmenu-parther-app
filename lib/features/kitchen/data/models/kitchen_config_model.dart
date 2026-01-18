/// Kitchen configuration model from /kitchen-config/:hotelId API
class KitchenConfigModel {
  final String? hotelId;
  final int defaultPrepTimeMinutes;
  final int bufferTimeMinutes;
  final int rushThresholdMinutes;
  final int alertOnOverloadMinutes;
  final bool enableKitchenLoadBalancing;
  final bool enableAutoSlotSuggestion;
  final bool enablePriorityQueue;
  final bool isActive;

  const KitchenConfigModel({
    this.hotelId,
    this.defaultPrepTimeMinutes = 15,
    this.bufferTimeMinutes = 5,
    this.rushThresholdMinutes = 15,
    this.alertOnOverloadMinutes = 35,
    this.enableKitchenLoadBalancing = true,
    this.enableAutoSlotSuggestion = true,
    this.enablePriorityQueue = true,
    this.isActive = true,
  });

  factory KitchenConfigModel.fromJson(Map<String, dynamic> json) {
    return KitchenConfigModel(
      hotelId: json['hotelId']?.toString(),
      defaultPrepTimeMinutes: json['defaultPrepTimeMinutes'] as int? ?? 15,
      bufferTimeMinutes: json['bufferTimeMinutes'] as int? ?? 5,
      rushThresholdMinutes: json['rushThresholdMinutes'] as int? ?? 15,
      alertOnOverloadMinutes: json['alertOnOverloadMinutes'] as int? ?? 35,
      enableKitchenLoadBalancing:
          json['enableKitchenLoadBalancing'] as bool? ?? true,
      enableAutoSlotSuggestion:
          json['enableAutoSlotSuggestion'] as bool? ?? true,
      enablePriorityQueue: json['enablePriorityQueue'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'hotelId': hotelId,
    'defaultPrepTimeMinutes': defaultPrepTimeMinutes,
    'bufferTimeMinutes': bufferTimeMinutes,
    'rushThresholdMinutes': rushThresholdMinutes,
    'alertOnOverloadMinutes': alertOnOverloadMinutes,
    'enableKitchenLoadBalancing': enableKitchenLoadBalancing,
    'enableAutoSlotSuggestion': enableAutoSlotSuggestion,
    'enablePriorityQueue': enablePriorityQueue,
    'isActive': isActive,
  };

  /// Default config when API returns nothing
  static const KitchenConfigModel defaultConfig = KitchenConfigModel();
}
