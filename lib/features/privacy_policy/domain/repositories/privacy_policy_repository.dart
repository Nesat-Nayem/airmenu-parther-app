import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/data/models/privacy_policy_model.dart';
import 'package:either_dart/either.dart';

abstract class PrivacyPolicyRepository {
  Future<Either<Failure, PrivacyPolicyModel>> getPrivacyPolicy();
  Future<Either<Failure, PrivacyPolicyModel>> updatePrivacyPolicy(
    String content,
  );
  Future<Either<Failure, PrivacyPolicyModel>> generatePrivacyPolicy(
    String platformName,
  );
}
