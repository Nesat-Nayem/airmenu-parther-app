import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/platform_activity/data/models/activity_model.dart';
import 'package:airmenuai_partner_app/features/platform_activity/domain/repositories/platform_activity_repository.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:either_dart/either.dart';

class PlatformActivityRepositoryImpl implements PlatformActivityRepository {
  final ApiService _apiService = locator<ApiService>();

  @override
  Future<Either<Failure, PlatformActivityResponse>> getPlatformActivities({
    int page = 1,
    int limit = 20,
    String? actorRole,
    String? action,
    String? entityType,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (actorRole != null && actorRole.isNotEmpty) {
        queryParams['actorRole'] = actorRole;
      }
      if (action != null && action.isNotEmpty) {
        queryParams['action'] = action;
      }
      if (entityType != null && entityType.isNotEmpty) {
        queryParams['entityType'] = entityType;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiService.invoke<PlatformActivityResponse>(
        urlPath: '${ApiEndpoints.platformActivitiesAll}?$queryString',
        type: RequestType.get,
        fun: (jsonString) {
          final json = jsonDecode(jsonString);
          return PlatformActivityResponse.fromJson(json['data'] ?? json);
        },
      );

      if (response is DataSuccess<PlatformActivityResponse>) {
        return Right(response.data!);
      } else if (response is DataFailure<PlatformActivityResponse>) {
        final error = response.error;
        final message = error?.message ?? 'Failed to fetch platform activities';
        if (error?.statusCode == 401) {
          return Left(ServerFailure(message: 'Unauthorized: $message'));
        }
        return Left(ServerFailure(message: message));
      } else {
        return Left(
          ServerFailure(message: 'Failed to fetch platform activities'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An error occurred while fetching platform activities: $e',
        ),
      );
    }
  }
}
