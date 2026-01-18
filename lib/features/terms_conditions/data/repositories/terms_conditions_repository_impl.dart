import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/data/models/terms_conditions_model.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/domain/repositories/terms_conditions_repository.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:either_dart/either.dart';

class TermsConditionsRepositoryImpl implements TermsConditionsRepository {
  final ApiService _apiService = locator<ApiService>();

  @override
  Future<Either<Failure, TermsConditionsModel>> getTermsConditions() async {
    try {
      final response = await _apiService.invoke<TermsConditionsModel>(
        urlPath: ApiEndpoints.termsConditions,
        type: RequestType.get,
        fun: (jsonString) {
          final json = jsonDecode(jsonString);
          return TermsConditionsModel.fromJson(json['data'] ?? json);
        },
      );

      if (response is DataSuccess<TermsConditionsModel>) {
        return Right(response.data!);
      } else if (response is DataFailure<TermsConditionsModel>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to fetch terms & conditions';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(
          ServerFailure(message: 'Failed to fetch terms & conditions'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while fetching terms & conditions: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, TermsConditionsModel>> updateTermsConditions(
    String content,
  ) async {
    try {
      final response = await _apiService.invoke<TermsConditionsModel>(
        urlPath: ApiEndpoints.termsConditions,
        type: RequestType.put,
        params: {'content': content},
        fun: (jsonString) {
          final json = jsonDecode(jsonString);
          return TermsConditionsModel.fromJson(json['data'] ?? json);
        },
      );

      if (response is DataSuccess<TermsConditionsModel>) {
        return Right(response.data!);
      } else if (response is DataFailure<TermsConditionsModel>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to update terms & conditions';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(
          ServerFailure(message: 'Failed to update terms & conditions'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while updating terms & conditions: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, TermsConditionsModel>> generateTermsConditions(
    String platformName,
  ) async {
    try {
      final response = await _apiService.invoke<TermsConditionsModel>(
        urlPath: ApiEndpoints.generateDocument,
        type: RequestType.post,
        params: {
          'documentType': 'terms-and-conditions',
          'platformName': platformName,
        },
        fun: (jsonString) {
          final json = jsonDecode(jsonString);
          return TermsConditionsModel.fromJson(json['data'] ?? json);
        },
      );

      if (response is DataSuccess<TermsConditionsModel>) {
        return Right(response.data!);
      } else if (response is DataFailure<TermsConditionsModel>) {
        final error = response.error;
        final message =
            error?.message ?? 'Failed to generate terms & conditions';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(
          ServerFailure(message: 'Failed to generate terms & conditions'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while generating terms & conditions: $e',
        ),
      );
    }
  }
}
