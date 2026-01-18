import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/use_case/use_case.dart';
import 'package:airmenuai_partner_app/features/platform_activity/data/models/activity_model.dart';
import 'package:airmenuai_partner_app/features/platform_activity/domain/repositories/platform_activity_repository.dart';
import 'package:either_dart/either.dart';

class GetPlatformActivitiesUsecase
    implements
        UseCaseOneInput<GetPlatformActivitiesParams, PlatformActivityResponse> {
  final PlatformActivityRepository repository;

  GetPlatformActivitiesUsecase(this.repository);

  @override
  Future<Either<Failure, PlatformActivityResponse>> invoke(
    GetPlatformActivitiesParams params,
  ) async {
    return await repository.getPlatformActivities(
      page: params.page,
      limit: params.limit,
      actorRole: params.actorRole,
      action: params.action,
      entityType: params.entityType,
    );
  }
}

class GetPlatformActivitiesParams {
  final int page;
  final int limit;
  final String? actorRole;
  final String? action;
  final String? entityType;

  GetPlatformActivitiesParams({
    this.page = 1,
    this.limit = 20,
    this.actorRole,
    this.action,
    this.entityType,
  });
}
