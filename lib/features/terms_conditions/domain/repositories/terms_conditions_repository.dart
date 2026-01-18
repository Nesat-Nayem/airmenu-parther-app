import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/data/models/terms_conditions_model.dart';
import 'package:either_dart/either.dart';

abstract class TermsConditionsRepository {
  Future<Either<Failure, TermsConditionsModel>> getTermsConditions();
  Future<Either<Failure, TermsConditionsModel>> updateTermsConditions(
    String content,
  );
  Future<Either<Failure, TermsConditionsModel>> generateTermsConditions(
    String platformName,
  );
}
