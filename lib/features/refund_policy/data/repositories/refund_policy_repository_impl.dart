import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/refund_policy/data/models/refund_policy_model.dart';
import 'package:airmenuai_partner_app/features/refund_policy/domain/repositories/refund_policy_repository.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:either_dart/either.dart';

class RefundPolicyRepositoryImpl implements RefundPolicyRepository {
  final ApiService _apiService = locator<ApiService>();

  @override
  Future<Either<Failure, RefundPolicyModel>> getRefundPolicy() async {
    try {
      final response = await _apiService.invoke<RefundPolicyModel>(
        urlPath: ApiEndpoints.refundPolicy,
        type: RequestType.get,
        fun: (jsonString) {
          final json = jsonDecode(jsonString);
          return RefundPolicyModel.fromJson(json['data'] ?? json);
        },
      );

      if (response is DataSuccess<RefundPolicyModel>) {
        return Right(response.data!);
      } else if (response is DataFailure<RefundPolicyModel>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to fetch refund policy';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to fetch refund policy'));
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while fetching refund policy: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, RefundPolicyModel>> updateRefundPolicy(
    String content,
  ) async {
    try {
      final response = await _apiService.invoke<RefundPolicyModel>(
        urlPath: ApiEndpoints.refundPolicy,
        type: RequestType.put,
        params: {'content': content},
        fun: (jsonString) {
          final json = jsonDecode(jsonString);
          return RefundPolicyModel.fromJson(json['data'] ?? json);
        },
      );

      if (response is DataSuccess<RefundPolicyModel>) {
        return Right(response.data!);
      } else if (response is DataFailure<RefundPolicyModel>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to update refund policy';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to update refund policy'));
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while updating refund policy: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, RefundPolicyModel>> generateRefundPolicy(
    String platformName,
  ) async {
    try {
      final response = await _apiService.invoke<RefundPolicyModel>(
        urlPath: ApiEndpoints.generateDocument,
        type: RequestType.post,
        params: {'documentType': 'refund-policy', 'platformName': platformName},
        fun: (jsonString) {
          final json = jsonDecode(jsonString);
          return RefundPolicyModel.fromJson(json['data'] ?? json);
        },
      );

      if (response is DataSuccess<RefundPolicyModel>) {
        return Right(response.data!);
      } else if (response is DataFailure<RefundPolicyModel>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to generate refund policy';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to generate refund policy'));
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while generating refund policy: $e',
        ),
      );
    }
  }
}
