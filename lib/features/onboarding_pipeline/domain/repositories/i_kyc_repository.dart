import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_stats.dart';

abstract class IKycRepository {
  /// Fetch KYC submissions by status with pagination and optional filters
  Future<({List<KycSubmission> submissions, bool hasMore, int totalItems})> getKycByStatus({
    required String status,
    int page = 1,
    int limit = 10,
    String? restaurantType,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Fetch KYC statistics (counts by status)
  Future<KycStats> getKycStats();

  /// Review (approve/reject) a KYC submission
  Future<KycSubmission> reviewKyc(String id, String status, {String? comments});

  /// Get admin Adobe signing URL for a KYC submission
  Future<String> getAdminSigningUrl(String kycId);

  /// Sync Adobe agreement status for a KYC submission
  Future<Map<String, dynamic>> syncAdobeStatus(String kycId);
}
