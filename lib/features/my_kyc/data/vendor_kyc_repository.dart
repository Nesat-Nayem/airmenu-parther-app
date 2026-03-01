import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

class VendorKycRepository {
  final ApiService _apiService = locator<ApiService>();

  Future<KycSubmission> getMyKyc() async {
    final response = await _apiService.invoke<KycSubmission>(
      urlPath: ApiEndpoints.kycMyKyc,
      type: RequestType.get,
      fun: (responseBody) {
        final json = jsonDecode(responseBody);
        if (json['success'] == true && json['data'] != null) {
          return KycSubmission.fromJson(json['data'] as Map<String, dynamic>);
        }
        throw Exception('No KYC data found');
      },
    );

    if (response is DataSuccess<KycSubmission>) {
      return response.data!;
    } else {
      throw Exception(
        (response as DataFailure?)?.error?.message ?? 'Failed to load KYC',
      );
    }
  }
}
