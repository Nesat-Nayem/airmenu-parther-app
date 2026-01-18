import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/help_support/data/models/help_support_model.dart';
import 'package:either_dart/either.dart';

abstract class HelpSupportRepository {
  Future<Either<Failure, HelpSupportModel>> getHelpSupport();
  Future<Either<Failure, HelpSupportModel>> updateHelpSupport(String content);
  Future<Either<Failure, HelpSupportModel>> generateHelpSupport(
    String platformName,
  );
}
