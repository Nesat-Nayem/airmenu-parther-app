import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_task_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_config_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_stats_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/data/models/hotel_model.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: KitchenRepository)
class KitchenRepositoryImpl implements KitchenRepository {
  final ApiService _apiService;

  KitchenRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, List<KitchenTaskModel>>> getKitchenQueue({
    required String hotelId,
    String? stationId,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (stationId != null) queryParams['stationId'] = stationId;
      if (status != null) queryParams['status'] = status;

      final response = await _apiService.invoke<List<KitchenTaskModel>>(
        urlPath:
            '/kitchen-load/queue/$hotelId${_buildQueryString(queryParams)}',
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          final data = json['data'];
          if (data == null || data['queue'] == null) return [];

          final List<KitchenTaskModel> tasks = [];
          final queue = data['queue'] as Map<String, dynamic>;
          queue.forEach((station, stationTasks) {
            if (stationTasks is List) {
              tasks.addAll(
                stationTasks.map((t) => KitchenTaskModel.fromJson(t)),
              );
            }
          });
          return tasks;
        },
      );

      if (response is DataSuccess<List<KitchenTaskModel>>) {
        return Right(response.data!);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to fetch kitchen queue',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenStatusModel>> getKitchenStatus(
    String hotelId,
  ) async {
    try {
      final response = await _apiService.invoke<KitchenStatusModel>(
        urlPath: '/kitchen-load/status/$hotelId',
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          return KitchenStatusModel.fromJson(json['data']);
        },
      );

      if (response is DataSuccess<KitchenStatusModel>) {
        return Right(response.data!);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to fetch kitchen status',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    try {
      final response = await _apiService.invoke<void>(
        urlPath: '/kitchen-load/item/$taskId/status',
        type: RequestType.patch,
        params: {'status': status},
        fun: (r) {},
      );

      if (response is DataSuccess) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to update task status',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderModel>>> getReadyOrders(
    String hotelId,
  ) async {
    try {
      final response = await _apiService.invoke<List<OrderModel>>(
        urlPath: '/orders?limit=50',
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          final List orders = json['data']['orders'] ?? [];
          return orders.map((o) => OrderModel.fromJson(o)).where((o) {
            // Return orders that are READY in kitchen but NOT yet delivered
            final kitchenStatus = o.kitchenStatus?.toUpperCase();
            final orderStatus = o.status?.toLowerCase();
            return kitchenStatus == 'READY' && orderStatus != 'delivered';
          }).toList();
        },
      );

      if (response is DataSuccess<List<OrderModel>>) {
        return Right(response.data!);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to fetch ready orders',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptOrder({
    required String orderId,
    String orderType = 'DINE_IN',
  }) async {
    try {
      final response = await _apiService.invoke<void>(
        urlPath: '/kitchen-load/accept-order/$orderId',
        type: RequestType.post,
        params: {'orderType': orderType},
        fun: (r) {},
      );

      if (response is DataSuccess) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to accept order',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder({required String orderId}) async {
    try {
      final response = await _apiService.invoke<void>(
        urlPath: '/kitchen-load/cancel-order/$orderId',
        type: RequestType.post,
        fun: (r) {},
      );

      if (response is DataSuccess) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to cancel order from kitchen',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> initializeStations(String hotelId) async {
    try {
      final response = await _apiService.invoke<void>(
        urlPath: '/kitchen-station/stations/initialize',
        type: RequestType.post,
        params: {'hotelId': hotelId, 'useDefaults': true},
        fun: (r) {},
      );

      if (response is DataSuccess) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to initialize kitchen stations',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KitchenStationModel>>> getStations(
    String hotelId,
  ) async {
    try {
      final response = await _apiService.invoke<List<KitchenStationModel>>(
        // Note: kitchen-station routes are mounted at /kitchen, not /kitchen-station
        urlPath: '/kitchen/stations/hotel/$hotelId',
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          final List data = json['data'] ?? [];
          return data
              .map((s) => KitchenStationModel.fromJson(s))
              .where((s) => s.isActive)
              .toList();
        },
      );

      if (response is DataSuccess<List<KitchenStationModel>>) {
        return Right(response.data!);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to fetch kitchen stations',
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
  Future<Either<Failure, KitchenStatsModel>> getStatsComparison(
    String hotelId,
  ) async {
    try {
      final response = await _apiService.invoke<KitchenStatsModel>(
        urlPath: ApiEndpoints.kitchenStatsComparison(hotelId),
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          if (json['success'] == true && json['data'] != null) {
            return KitchenStatsModel.fromJson(json['data']);
          }
          return KitchenStatsModel.empty;
        },
      );

      if (response is DataSuccess<KitchenStatsModel>) {
        return Right(response.data ?? KitchenStatsModel.empty);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to fetch kitchen stats',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, KitchenConfigModel>> getKitchenConfig(
    String hotelId,
  ) async {
    try {
      final response = await _apiService.invoke<KitchenConfigModel>(
        urlPath: ApiEndpoints.kitchenConfig(hotelId),
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          if (json['success'] == true && json['data'] != null) {
            return KitchenConfigModel.fromJson(json['data']);
          }
          return KitchenConfigModel.defaultConfig;
        },
      );

      if (response is DataSuccess<KitchenConfigModel>) {
        return Right(response.data ?? KitchenConfigModel.defaultConfig);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to fetch kitchen config',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HotelModel>>> getHotels() async {
    try {
      final response = await _apiService.invoke<List<HotelModel>>(
        urlPath: ApiEndpoints.hotels,
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          if (json['success'] == true && json['data'] != null) {
            final List<dynamic> data = json['data'];
            return data.map((e) => HotelModel.fromJson(e)).toList();
          }
          return <HotelModel>[];
        },
      );

      if (response is DataSuccess<List<HotelModel>>) {
        return Right(response.data ?? []);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to fetch hotels',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
