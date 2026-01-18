import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/staff_management/data/models/staff_model.dart';
import 'package:dartz/dartz.dart';

/// Abstract repository interface for Staff operations
abstract class StaffRepository {
  /// Get all staff members for the current vendor
  Future<Either<Failure, List<StaffModel>>> getAllStaff();

  /// Get a staff member by ID
  Future<Either<Failure, StaffModel>> getStaffById(String id);

  /// Create a new staff member
  Future<Either<Failure, StaffModel>> createStaff({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String hotelId,
    String? staffRole,
    String? shift,
    StaffPermissions? permissions,
  });

  /// Update an existing staff member
  Future<Either<Failure, StaffModel>> updateStaff({
    required String id,
    String? name,
    String? email,
    String? phone,
    String? status,
    String? staffRole,
    String? shift,
    StaffPermissions? permissions,
  });

  /// Delete a staff member
  Future<Either<Failure, void>> deleteStaff(String id);

  /// Toggle staff status (active/inactive)
  Future<Either<Failure, StaffModel>> toggleStaffStatus(String id);
}
