import 'dart:convert';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_stats.dart';
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
  Future<({List<KycSubmission> submissions, bool hasMore, int totalItems})> getKycByStatus({
    required String status,
    int page = 1,
    int limit = 10,
    String? restaurantType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'status': status,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (restaurantType != null && restaurantType.isNotEmpty) {
        queryParams['restaurantType'] = restaurantType;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }
      final queryString = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      
      final response = await _apiService.invoke<Map<String, dynamic>>(
        urlPath: '${ApiEndpoints.kycAll}?$queryString',
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          if (json['success'] == true && json['data'] != null) {
            return json['data'] as Map<String, dynamic>;
          }
          return <String, dynamic>{};
        },
      );

      if (response is DataSuccess<Map<String, dynamic>>) {
        final data = response.data ?? {};
        final list = data['submissions'] as List? ?? [];
        final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
        
        final submissions = list.map((e) => KycSubmission.fromJson(e as Map<String, dynamic>)).toList();
        final currentPage = pagination['currentPage'] as int? ?? 1;
        final totalPages = pagination['totalPages'] as int? ?? 1;
        final totalItems = pagination['totalItems'] as int? ?? 0;
        
        return (
          submissions: submissions,
          hasMore: currentPage < totalPages,
          totalItems: totalItems,
        );
      } else {
        throw Exception(
          (response as DataFailure?)?.error?.message ?? 'Failed to load KYC',
        );
      }
    } catch (e) {
      throw Exception('Failed to load KYC by status: $e');
    }
  }

  @override
  Future<KycStats> getKycStats() async {
    try {
      final response = await _apiService.invoke<KycStats>(
        urlPath: ApiEndpoints.kycStats,
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          if (json['success'] == true && json['data'] != null) {
            return KycStats.fromJson(json['data'] as Map<String, dynamic>);
          }
          return const KycStats();
        },
      );

      if (response is DataSuccess<KycStats>) {
        return response.data ?? const KycStats();
      } else {
        throw Exception(
          (response as DataFailure?)?.error?.message ?? 'Failed to load KYC stats',
        );
      }
    } catch (e) {
      throw Exception('Failed to load KYC stats: $e');
    }
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

  @override
  Future<String> getAdminSigningUrl(String kycId) async {
    try {
      final response = await _apiService.invoke<String>(
        urlPath: ApiEndpoints.kycAdminSigningView(kycId),
        type: RequestType.get,
        fun: (responseBody) {
          final json = jsonDecode(responseBody);
          if (json['success'] == true && json['data'] != null) {
            return json['data']['signingUrl']?.toString() ?? '';
          }
          throw Exception('Failed to get admin signing URL');
        },
      );

      if (response is DataSuccess<String>) {
        return response.data ?? '';
      } else {
        throw Exception(
          (response as DataFailure?)?.error?.message ?? 'Failed to get admin signing URL',
        );
      }
    } catch (e) {
      throw Exception('Failed to get admin signing URL: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> syncAdobeStatus(String kycId) async {
    try {
      print('[Flutter Repo] syncAdobeStatus: kycId=$kycId');
      print('[Flutter Repo] syncAdobeStatus: URL=${ApiEndpoints.kycAdobeSync(kycId)}');
      final response = await _apiService.invoke<Map<String, dynamic>>(
        urlPath: ApiEndpoints.kycAdobeSync(kycId),
        type: RequestType.post,
        params: <String, dynamic>{},
        fun: (responseBody) {
          print('[Flutter Repo] syncAdobeStatus: Raw response body=$responseBody');
          final json = jsonDecode(responseBody);
          print('[Flutter Repo] syncAdobeStatus: Parsed JSON success=${json['success']}, message=${json['message']}');
          if (json['success'] == true && json['data'] != null) {
            print('[Flutter Repo] syncAdobeStatus: Data=${json['data']}');
            return json['data'] as Map<String, dynamic>;
          }
          print('[Flutter Repo] syncAdobeStatus: No success/data in response, returning empty map');
          return <String, dynamic>{};
        },
      );

      print('[Flutter Repo] syncAdobeStatus: Response type=${response.runtimeType}');
      if (response is DataSuccess<Map<String, dynamic>>) {
        print('[Flutter Repo] syncAdobeStatus: DataSuccess data=${response.data}');
        return response.data ?? {};
      } else {
        final errorMsg = (response as DataFailure?)?.error?.message ?? 'Failed to sync Adobe status';
        print('[Flutter Repo] syncAdobeStatus: DataFailure error=$errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('[Flutter Repo] syncAdobeStatus: EXCEPTION: $e');
      throw Exception('Failed to sync Adobe status: $e');
    }
  }
}
