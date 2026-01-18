import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/platform_activity/data/models/activity_model.dart';
import 'package:either_dart/either.dart';

abstract class PlatformActivityRepository {
  Future<Either<Failure, PlatformActivityResponse>> getPlatformActivities({
    int page = 1,
    int limit = 20,
    String? actorRole,
    String? action,
    String? entityType,
  });
}
