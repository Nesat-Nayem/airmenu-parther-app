import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/use_case/use_case.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/data/models/privacy_policy_model.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/domain/repositories/privacy_policy_repository.dart';
import 'package:either_dart/either.dart';

class UpdatePrivacyPolicyUsecase
    implements UseCaseOneInput<String, PrivacyPolicyModel> {
  final PrivacyPolicyRepository repository;

  UpdatePrivacyPolicyUsecase(this.repository);

  @override
  Future<Either<Failure, PrivacyPolicyModel>> invoke(String content) async {
    return await repository.updatePrivacyPolicy(content);
  }
}
