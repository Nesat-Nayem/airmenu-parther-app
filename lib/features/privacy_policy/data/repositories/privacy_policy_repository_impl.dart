import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/data/models/privacy_policy_model.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/domain/repositories/privacy_policy_repository.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:either_dart/either.dart';

class PrivacyPolicyRepositoryImpl implements PrivacyPolicyRepository {
  final ApiService _apiService = locator<ApiService>();

  @override
  Future<Either<Failure, PrivacyPolicyModel>> getPrivacyPolicy() async {
    try {
      final response = await _apiService.invoke<PrivacyPolicyModel>(
        urlPath: ApiEndpoints.privacyPolicy,
        type: RequestType.get,
        fun: (jsonString) {
          final json = jsonDecode(jsonString);
          return PrivacyPolicyModel.fromJson(json['data'] ?? json);
        },
      );

      if (response is DataSuccess<PrivacyPolicyModel>) {
        return Right(response.data!);
      } else if (response is DataFailure<PrivacyPolicyModel>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to fetch privacy policy';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to fetch privacy policy'));
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while fetching privacy policy: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PrivacyPolicyModel>> updatePrivacyPolicy(
    String content,
  ) async {
    try {
      final response = await _apiService.invoke<PrivacyPolicyModel>(
        urlPath: ApiEndpoints.privacyPolicy,
        type: RequestType.put,
        params: {'content': content},
        fun: (jsonString) {
          final json = jsonDecode(jsonString);
          return PrivacyPolicyModel.fromJson(json['data'] ?? json);
        },
      );

      if (response is DataSuccess<PrivacyPolicyModel>) {
        return Right(response.data!);
      } else if (response is DataFailure<PrivacyPolicyModel>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to update privacy policy';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to update privacy policy'));
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while updating privacy policy: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PrivacyPolicyModel>> generatePrivacyPolicy(
    String platformName,
  ) async {
    try {
      final response = await _apiService.invoke<PrivacyPolicyModel>(
        urlPath: ApiEndpoints.generateDocument,
        type: RequestType.post,
        params: {
          'documentType': 'privacy-policy',
          'platformName': platformName,
        },
        fun: (jsonString) {
          final json = jsonDecode(jsonString);
          return PrivacyPolicyModel.fromJson(json['data'] ?? json);
        },
      );

      if (response is DataSuccess<PrivacyPolicyModel>) {
        return Right(response.data!);
      } else if (response is DataFailure<PrivacyPolicyModel>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to generate privacy policy';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(
          ServerFailure(message: 'Failed to generate privacy policy'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while generating privacy policy: $e',
        ),
      );
    }
  }
}
