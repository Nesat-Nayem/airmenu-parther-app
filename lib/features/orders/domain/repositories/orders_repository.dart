import 'package:either_dart/either.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_stats_model.dart';
import 'package:airmenuai_partner_app/core/models/generic_response.dart';

abstract class OrdersRepository {
  /// Get order statistics for filter chips and stats tiles
  Future<Either<Failure, OrderStatsModel>> getOrderStats();

  /// Get all orders (pagination removed - to be implemented later)
  Future<Either<Failure, GenericResponse<List<OrderModel>>>> getOrders({
    String? status,
    String? paymentStatus,
  });

  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String status,
  });

  Future<Either<Failure, void>> processRefund({
    required String orderId,
    required double amount,
    required String method,
    String? reason,
  });

  Future<Either<Failure, void>> recordManualPayment({
    required String orderId,
    required double amount,
  });

  Future<Either<Failure, void>> markOrderComplete({required String orderId});

  Future<Either<Failure, void>> updateItemStatus({
    required String orderId,
    required String itemId,
    required String status,
  });

  Future<Either<Failure, void>> addToCart({
    required String hotelId,
    required String menuItemId,
    int quantity = 1,
    String tableNumber = "12",
  });

  Future<Either<Failure, void>> createOrder({
    required String hotelId,
    required String tableNumber,
    String paymentMethod = "cash",
  });
}
