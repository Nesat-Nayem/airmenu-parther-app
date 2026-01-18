import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_task_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_config_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_stats_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/data/models/hotel_model.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:dartz/dartz.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';

/// Station model for dynamic filter tabs
class KitchenStationModel {
  final String id;
  final String name;
  final String code;
  final bool isActive;
  final int parallelSlots;
  final String? color;

  const KitchenStationModel({
    required this.id,
    required this.name,
    required this.code,
    this.isActive = true,
    this.parallelSlots = 3,
    this.color,
  });

  factory KitchenStationModel.fromJson(Map<String, dynamic> json) {
    return KitchenStationModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      isActive: json['isActive'] ?? true,
      parallelSlots: json['parallelSlots'] ?? 3,
      color: json['color'],
    );
  }
}

abstract class KitchenRepository {
  Future<Either<Failure, List<KitchenTaskModel>>> getKitchenQueue({
    required String hotelId,
    String? stationId,
    String? status,
  });

  Future<Either<Failure, KitchenStatusModel>> getKitchenStatus(String hotelId);

  Future<Either<Failure, List<OrderModel>>> getReadyOrders(String hotelId);

  Future<Either<Failure, void>> updateTaskStatus({
    required String taskId,
    required String status,
  });

  Future<Either<Failure, void>> acceptOrder({
    required String orderId,
    String orderType = 'DINE_IN',
  });

  Future<Either<Failure, void>> cancelOrder({required String orderId});

  Future<Either<Failure, void>> initializeStations(String hotelId);

  /// Get all kitchen stations for a hotel (for dynamic filter tabs)
  Future<Either<Failure, List<KitchenStationModel>>> getStations(
    String hotelId,
  );

  /// Get kitchen statistics with comparison data from API
  Future<Either<Failure, KitchenStatsModel>> getStatsComparison(String hotelId);

  /// Get kitchen configuration (thresholds, feature flags) from API
  Future<Either<Failure, KitchenConfigModel>> getKitchenConfig(String hotelId);

  /// Get vendor's hotels for hotel selection
  Future<Either<Failure, List<HotelModel>>> getHotels();
}
