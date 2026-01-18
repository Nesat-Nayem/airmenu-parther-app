import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/staff_management/data/models/staff_model.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

/// Load all staff members
class LoadStaff extends StaffEvent {
  const LoadStaff();
}

/// Refresh staff list
class RefreshStaff extends StaffEvent {
  const RefreshStaff();
}

/// Search staff by name or email
class SearchStaff extends StaffEvent {
  final String query;

  const SearchStaff(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter staff by role
class FilterByRole extends StaffEvent {
  final String? role; // null means "All"

  const FilterByRole(this.role);

  @override
  List<Object?> get props => [role];
}

/// Add new staff member
class AddStaff extends StaffEvent {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String hotelId;
  final String? staffRole;
  final String? shift;
  final StaffPermissions? permissions;

  const AddStaff({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.hotelId,
    this.staffRole,
    this.shift,
    this.permissions,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    phone,
    hotelId,
    staffRole,
    shift,
  ];
}

/// Update existing staff member
class UpdateStaff extends StaffEvent {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? status;
  final String? staffRole;
  final String? shift;
  final StaffPermissions? permissions;

  const UpdateStaff({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.status,
    this.staffRole,
    this.shift,
    this.permissions,
  });

  @override
  List<Object?> get props => [id, name, email, phone, status, staffRole, shift];
}

/// Toggle staff active/inactive status
class ToggleStaffStatus extends StaffEvent {
  final String id;

  const ToggleStaffStatus(this.id);

  @override
  List<Object?> get props => [id];
}

/// Delete staff member
class DeleteStaff extends StaffEvent {
  final String id;

  const DeleteStaff(this.id);

  @override
  List<Object?> get props => [id];
}
