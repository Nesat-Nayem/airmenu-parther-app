import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/help_support/data/models/help_support_model.dart';
import 'package:airmenuai_partner_app/features/help_support/domain/repositories/help_support_repository.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:either_dart/either.dart';

class HelpSupportRepositoryImpl implements HelpSupportRepository {
  final ApiService _apiService = locator<ApiService>();

  @override
  Future<Either<Failure, HelpSupportModel>> getHelpSupport() async {
    try {
      final response = await _apiService.invoke<HelpSupportModel>(
        urlPath: ApiEndpoints.helpSupport,
        type: RequestType.get,
        fun: (jsonString) => HelpSupportModel.fromJson(
          jsonDecode(jsonString)['data'] ?? jsonDecode(jsonString),
        ),
      );
      if (response is DataSuccess<HelpSupportModel>) {
        return Right(response.data!);
      } else if (response is DataFailure<HelpSupportModel>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to fetch help & support';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to fetch help & support'));
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while fetching help & support: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, HelpSupportModel>> updateHelpSupport(
    String content,
  ) async {
    try {
      final response = await _apiService.invoke<HelpSupportModel>(
        urlPath: ApiEndpoints.helpSupport,
        type: RequestType.put,
        params: {'content': content},
        fun: (jsonString) => HelpSupportModel.fromJson(
          jsonDecode(jsonString)['data'] ?? jsonDecode(jsonString),
        ),
      );
      if (response is DataSuccess<HelpSupportModel>) {
        return Right(response.data!);
      } else if (response is DataFailure<HelpSupportModel>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to update help & support';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(ServerFailure(message: 'Failed to update help & support'));
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while updating help & support: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, HelpSupportModel>> generateHelpSupport(
    String platformName,
  ) async {
    try {
      final response = await _apiService.invoke<HelpSupportModel>(
        urlPath: ApiEndpoints.generateDocument,
        type: RequestType.post,
        params: {
          'documentType': 'help-and-support',
          'platformName': platformName,
        },
        fun: (jsonString) => HelpSupportModel.fromJson(
          jsonDecode(jsonString)['data'] ?? jsonDecode(jsonString),
        ),
      );
      if (response is DataSuccess<HelpSupportModel>) {
        return Right(response.data!);
      } else if (response is DataFailure<HelpSupportModel>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to generate help & support';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(
          ServerFailure(message: 'Failed to generate help & support'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while generating help & support: $e',
        ),
      );
    }
  }
}
