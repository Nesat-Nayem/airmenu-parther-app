import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/models/pagination_model.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_stats_model.dart';
import 'package:airmenuai_partner_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:airmenuai_partner_app/core/models/generic_response.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: OrdersRepository)
class OrdersRepositoryImpl implements OrdersRepository {
  final ApiService _apiService;

  OrdersRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, OrderStatsModel>> getOrderStats() async {
    try {
      final response = await _apiService.invoke<OrderStatsModel>(
        urlPath: ApiEndpoints.orderStats,
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          // Debug logging
          print('🔍 Order Stats API Response: ${json['success']}');
          print('🔍 Order Stats Data: ${json['data']}');
          if (json['success'] == true && json['data'] != null) {
            final model = OrderStatsModel.fromJson(json['data']);
            print('🔍 Parsed stats count: ${model.stats?.length}');
            print('🔍 Parsed filters count: ${model.filters?.length}');
            return model;
          }
          print('🔍 Order Stats: Returning empty model');
          return OrderStatsModel.empty;
        },
      );

      if (response is DataSuccess<OrderStatsModel>) {
        print(
          '🔍 Order Stats: DataSuccess - ${response.data?.stats?.length} stats',
        );
        return Right(response.data ?? OrderStatsModel.empty);
      } else if (response is DataFailure<OrderStatsModel>) {
        final error = response.error;
        print('🔍 Order Stats: DataFailure - ${error?.message}');
        return Left(
          ServerFailure(
            message: error?.message ?? 'Failed to fetch order stats',
          ),
        );
      }
      print('🔍 Order Stats: Unknown response type');
      return Left(ServerFailure(message: 'Failed to fetch order stats'));
    } catch (e) {
      print('🔍 Order Stats: Exception - $e');
      return Left(
        ServerFailure(
          message: 'An error occurred while fetching order stats: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, GenericResponse<List<OrderModel>>>> getOrders({
    String? status,
    String? paymentStatus,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty && status != 'All Status') {
        queryParams['status'] = status.toLowerCase();
      }

      if (paymentStatus != null &&
          paymentStatus.isNotEmpty &&
          paymentStatus != 'All Payments') {
        queryParams['paymentStatus'] = paymentStatus.toLowerCase();
      }

      final response = await _apiService
          .invoke<GenericResponse<List<OrderModel>>>(
            urlPath: ApiEndpoints.orders + _buildQueryString(queryParams),
            type: RequestType.get,
            fun: (responseBody) {
              final json = jsonDecode(responseBody);
              // Parse pagination from data.pagination
              PaginationModel? pagination;
              if (json['data'] != null && json['data']['pagination'] != null) {
                pagination = PaginationModel.fromJson(
                  json['data']['pagination'],
                );
              }

              return GenericResponse<List<OrderModel>>(
                success: json['success'] as bool?,
                message: json['message'] as String?,
                data: json['data'] != null && json['data']['orders'] != null
                    ? (json['data']['orders'] as List)
                          .map(
                            (e) =>
                                OrderModel.fromJson(e as Map<String, dynamic>),
                          )
                          .toList()
                    : [],
                pagination: pagination,
              );
            },
          );

      if (response is DataSuccess<GenericResponse<List<OrderModel>>>) {
        return Right(response.data!);
      } else if (response is DataFailure<GenericResponse<List<OrderModel>>>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to fetch orders';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to fetch orders'));
      }
    } catch (e) {
      return Left(
        ServerFailure(message: 'An error occurred while fetching orders: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await _apiService.invoke<void>(
        urlPath: '${ApiEndpoints.orders}/$orderId/status',
        type: RequestType.patch,
        params: {'status': status},
        fun: (r) {},
      );

      if (response is DataSuccess) {
        return const Right(null);
      } else if (response is DataFailure) {
        final error = response.error;
        final message = error?.message ?? 'Failed to update order status';
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to update order status'));
      }
    } catch (e) {
      return Left(
        ServerFailure(message: 'An error occurred while updating order: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> processRefund({
    required String orderId,
    required double amount,
    required String method,
    String? reason,
  }) async {
    try {
      final params = <String, dynamic>{'amount': amount, 'method': method};
      if (reason != null && reason.isNotEmpty) {
        params['reason'] = reason;
      }

      final response = await _apiService.invoke<void>(
        urlPath: '${ApiEndpoints.orders}/$orderId/refund',
        type: RequestType.post,
        params: params,
        fun: (r) {},
      );

      if (response is DataSuccess) {
        return const Right(null);
      } else if (response is DataFailure) {
        final error = response.error;
        final message = error?.message ?? 'Failed to process refund';
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to process refund'));
      }
    } catch (e) {
      return Left(
        ServerFailure(message: 'An error occurred while processing refund: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> recordManualPayment({
    required String orderId,
    required double amount,
  }) async {
    try {
      final response = await _apiService.invoke<void>(
        urlPath: '${ApiEndpoints.orders}/$orderId/manual-payment',
        type: RequestType.post,
        params: {'amount': amount},
        fun: (r) {},
      );

      if (response is DataSuccess) {
        return const Right(null);
      } else if (response is DataFailure) {
        final error = response.error;
        final message = error?.message ?? 'Failed to record payment';
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to record payment'));
      }
    } catch (e) {
      return Left(
        ServerFailure(message: 'An error occurred while recording payment: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markOrderComplete({
    required String orderId,
  }) async {
    try {
      final response = await _apiService.invoke<void>(
        urlPath: '${ApiEndpoints.orders}/$orderId/complete',
        type: RequestType.post,
        params: {},
        fun: (r) {},
      );

      if (response is DataSuccess) {
        return const Right(null);
      } else if (response is DataFailure) {
        final error = response.error;
        final message = error?.message ?? 'Failed to mark order complete';
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to mark order complete'));
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while marking order complete: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateItemStatus({
    required String orderId,
    required String itemId,
    required String status,
  }) async {
    try {
      final response = await _apiService.invoke<void>(
        urlPath: '${ApiEndpoints.orders}/$orderId/items/$itemId/status',
        type: RequestType.patch,
        params: {'status': status},
        fun: (r) {},
      );

      if (response is DataSuccess) {
        return const Right(null);
      } else if (response is DataFailure) {
        final error = response.error;
        final message = error?.message ?? 'Failed to update item status';
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to update item status'));
      }
    } catch (e) {
      return Left(
        ServerFailure(message: 'An error occurred while updating item: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addToCart({
    required String hotelId,
    required String menuItemId,
    int quantity = 1,
    String tableNumber = "12",
  }) async {
    try {
      final response = await _apiService.invoke<void>(
        urlPath: ApiEndpoints.cart,
        type: RequestType.post,
        params: {
          'hotelId': hotelId,
          'menuItemId': menuItemId,
          'quantity': quantity,
          'tableNumber': tableNumber,
        },
        fun: (r) {},
      );

      if (response is DataSuccess) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to add to cart',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createOrder({
    required String hotelId,
    required String tableNumber,
    String paymentMethod = "cash",
  }) async {
    try {
      final response = await _apiService.invoke<void>(
        urlPath: ApiEndpoints.orders,
        type: RequestType.post,
        params: {
          'hotelId': hotelId,
          'tableNumber': tableNumber,
          'paymentMethod': paymentMethod,
        },
        fun: (r) {},
      );

      if (response is DataSuccess) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to create order',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  String _buildQueryString(Map<String, String> params) {
    if (params.isEmpty) return "";
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '?$query';
  }

  @override
  Future<Either<Failure, List<({String id, String name})>>> getBranches() async {
    try {
      final response = await _apiService.invoke(
        urlPath: '/orders/branches',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final data = response.data;
        List<dynamic>? list;
        if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            list = data['data'] as List;
          } else if (data['branches'] is List) {
            list = data['branches'] as List;
          }
        } else if (data is List) {
          list = data;
        }

        if (list != null) {
          return Right(
            list
                .map((e) => (
                      id: (e['id'] ?? e['_id'] ?? '').toString(),
                      name: (e['name'] ?? '').toString(),
                    ))
                .where((b) => b.id.isNotEmpty && b.name.isNotEmpty)
                .toList(),
          );
        }
      }

      return const Right([]);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to fetch branches: $e'),
      );
    }
  }
}
