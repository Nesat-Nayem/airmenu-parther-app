import 'package:airmenuai_partner_app/features/landmark/data/models/mall_model.dart';

/// Abstract repository interface for Landmark feature
abstract class ILandmarkRepository {
  /// Get paginated list of malls
  Future<MallsListResponse> getMalls({
    String? search,
    int page = 1,
    int limit = 10,
  });

  /// Get mall by ID
  Future<MallModel> getMallById(String id);

  /// Create a new mall
  Future<MallModel> createMall(CreateMallRequest request, {String? imagePath});

  /// Update mall
  Future<MallModel> updateMall(
    String id,
    UpdateMallRequest request, {
    String? imagePath,
  });

  /// Delete mall (soft delete)
  Future<void> deleteMall(String id);
}
