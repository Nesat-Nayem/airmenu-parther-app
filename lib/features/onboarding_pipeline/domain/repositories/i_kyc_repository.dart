import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';

abstract class IKycRepository {
  Future<List<KycSubmission>> getAllKycSubmissions();
  Future<List<KycSubmission>> getKycStats(); // Or simpler map return
  Future<KycSubmission> reviewKyc(String id, String status, {String? comments});
}
