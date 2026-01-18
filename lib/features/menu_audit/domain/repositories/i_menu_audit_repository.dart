import 'package:airmenuai_partner_app/features/menu_audit/data/models/menu_audit_response.dart';
import 'package:either_dart/either.dart';

abstract class IMenuAuditRepository {
  Future<Either<String, MenuAuditStats>> getMenuAuditStats();
}
