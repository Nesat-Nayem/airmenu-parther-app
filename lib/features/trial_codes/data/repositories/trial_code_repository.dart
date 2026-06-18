import 'dart:convert';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/trial_codes/data/models/trial_code_model.dart';

class TrialCodeRepository {
  final ApiService _api;
  TrialCodeRepository(this._api);

  Future<List<TrialCodeModel>> getCodes() async {
    final result = await _api.invoke(
      urlPath: '/trial-codes',
      type: RequestType.get,
      fun: (json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        final data = map['data'] as List<dynamic>? ?? [];
        return data.map((e) => TrialCodeModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      },
    );
    if (result is DataSuccess<List<TrialCodeModel>>) return result.data ?? [];
    throw Exception(result.error?.message ?? 'Failed to load trial codes');
  }

  Future<TrialCodeModel> createCode(TrialCodeModel code) async {
    final result = await _api.invoke(
      urlPath: '/trial-codes',
      type: RequestType.post,
      params: code.toCreateJson(),
      fun: (json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return TrialCodeModel.fromJson(Map<String, dynamic>.from(map['data'] as Map));
      },
    );
    if (result is DataSuccess<TrialCodeModel>) return result.data!;
    throw Exception(result.error?.message ?? 'Failed to save trial code');
  }

  Future<TrialCodeModel> updateCode(String code, Map<String, dynamic> body) async {
    final result = await _api.invoke(
      urlPath: '/trial-codes/${code.toUpperCase()}',
      type: RequestType.put,
      params: body,
      fun: (json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return TrialCodeModel.fromJson(Map<String, dynamic>.from(map['data'] as Map));
      },
    );
    if (result is DataSuccess<TrialCodeModel>) return result.data!;
    throw Exception(result.error?.message ?? 'Failed to update trial code');
  }
}
