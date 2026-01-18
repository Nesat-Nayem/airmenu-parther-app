import 'dart:convert';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/domain/repositories/i_kyc_repository.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IKycRepository)
class KycRepositoryImpl implements IKycRepository {
  final ApiService _apiService;

  KycRepositoryImpl(this._apiService);

  @override
  Future<List<KycSubmission>> getAllKycSubmissions() async {
    try {
      // For Kanban board, we need all items grouped by status
      // Request a high limit to fetch all at once
      final response = await _apiService.invoke<List<KycSubmission>>(
        urlPath: '${ApiEndpoints.kycAll}?limit=200',
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          if (json['success'] == true && json['data'] != null) {
            final data = json['data'] as Map<String, dynamic>;
            final list = data['submissions'] as List?;
            if (list == null) return [];
            return list.map((e) => KycSubmission.fromJson(e)).toList();
          }
          return [];
        },
      );

      if (response is DataSuccess<List<KycSubmission>>) {
        return response.data ?? [];
      } else {
        // If API fails, return empty list or throw to let Bloc handle it
        throw Exception(
          (response as DataFailure?)?.error?.message ?? 'Failed to load KYC',
        );
      }
    } catch (e) {
      throw Exception('Failed to load KYC: $e');
    }
  }

  @override
  Future<List<KycSubmission>> getKycStats() async {
    // NOTE: The current requirement is just to get list and group them locally in Bloc.
    // If we need stats specifically later, we can implement this endpoint.
    // For now, the Bloc logic relies on 'getAllKycSubmissions' to build the board.
    // But if we want to call the stats endpoint:
    /*
     try {
       final response = await _apiService.invoke(
         urlPath: ApiEndpoints.kycStats,
         type: RequestType.get,
         fun: (b) => jsonDecode(b),
       );
       // This returns a Stats object, not list of submissions.
       // Since interface asks for List<KycSubmission>, this might be a mismatch in interface definition 
       // vs what this method name implies vs what API returns.
       // Given the Bloc calls getAllKycSubmissions to populate the board, we might not strictly need this yet 
       // for the 3 columns unless we display separate stats headers.
     } catch (e) { ... }
     */
    return [];
  }

  @override
  Future<KycSubmission> reviewKyc(
    String id,
    String status, {
    String? comments,
  }) async {
    try {
      final body = {
        'status': status,
        if (comments != null) 'adminComments': comments,
      };

      final response = await _apiService.invoke<KycSubmission>(
        urlPath: ApiEndpoints.kycReview(id),
        type: RequestType.put,
        params: body, // request body
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          if (json['success'] == true && json['data'] != null) {
            return KycSubmission.fromJson(json['data']);
          }
          throw Exception('Invalid response format');
        },
      );

      if (response is DataSuccess<KycSubmission>) {
        return response.data!;
      } else {
        throw Exception(
          (response as DataFailure?)?.error?.message ?? 'Failed to review KYC',
        );
      }
    } catch (e) {
      throw Exception('Failed to review KYC: $e');
    }
  }
}
