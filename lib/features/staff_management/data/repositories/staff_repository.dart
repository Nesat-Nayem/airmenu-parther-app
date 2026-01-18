import 'dart:convert';

import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/staff_management/data/models/staff_model.dart';
import 'package:airmenuai_partner_app/features/staff_management/domain/repositories/staff_repository_interface.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: StaffRepository)
class StaffRepositoryImpl implements StaffRepository {
  final ApiService _apiService;

  StaffRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, List<StaffModel>>> getAllStaff() async {
    try {
      final response = await _apiService.invoke<List<StaffModel>>(
        urlPath: '/staff',
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          final List data = json['data'] ?? [];
          return data.map((e) => StaffModel.fromJson(e)).toList();
        },
      );

      if (response is DataSuccess<List<StaffModel>>) {
        return Right(response.data ?? []);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to fetch staff',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StaffModel>> getStaffById(String id) async {
    try {
      final response = await _apiService.invoke<StaffModel>(
        urlPath: '/staff/$id',
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          return StaffModel.fromJson(json['data']);
        },
      );

      if (response is DataSuccess<StaffModel>) {
        return Right(response.data!);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to fetch staff',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StaffModel>> createStaff({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String hotelId,
    String? staffRole,
    String? shift,
    StaffPermissions? permissions,
  }) async {
    try {
      final params = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'hotelId': hotelId,
      };

      // Add optional fields (will be ignored by current backend)
      if (staffRole != null) params['staffRole'] = staffRole;
      if (shift != null) params['shift'] = shift;
      if (permissions != null) params['permissions'] = permissions.toJson();

      final response = await _apiService.invoke<StaffModel>(
        urlPath: '/staff',
        type: RequestType.post,
        params: params,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          return StaffModel.fromJson(json['data']);
        },
      );

      if (response is DataSuccess<StaffModel>) {
        return Right(response.data!);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to create staff',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StaffModel>> updateStaff({
    required String id,
    String? name,
    String? email,
    String? phone,
    String? status,
    String? staffRole,
    String? shift,
    StaffPermissions? permissions,
  }) async {
    try {
      final params = <String, dynamic>{};

      if (name != null) params['name'] = name;
      if (email != null) params['email'] = email;
      if (phone != null) params['phone'] = phone;
      if (status != null) params['status'] = status;
      if (staffRole != null) params['staffRole'] = staffRole;
      if (shift != null) params['shift'] = shift;
      if (permissions != null) params['permissions'] = permissions.toJson();

      final response = await _apiService.invoke<StaffModel>(
        urlPath: '/staff/$id',
        type: RequestType.put,
        params: params,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          return StaffModel.fromJson(json['data']);
        },
      );

      if (response is DataSuccess<StaffModel>) {
        return Right(response.data!);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to update staff',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStaff(String id) async {
    try {
      final response = await _apiService.invoke<void>(
        urlPath: '/staff/$id',
        type: RequestType.delete,
        fun: (r) {},
      );

      if (response is DataSuccess) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(
            message:
                (response as DataFailure).error?.message ??
                'Failed to delete staff',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StaffModel>> toggleStaffStatus(String id) async {
    // First get current staff to determine new status
    final staffResult = await getStaffById(id);

    return staffResult.fold((failure) => Left(failure), (staff) async {
      final newStatus = staff.isActive ? 'inactive' : 'active';
      return updateStaff(id: id, status: newStatus);
    });
  }
}
