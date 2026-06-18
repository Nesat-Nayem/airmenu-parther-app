import 'dart:convert';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/pricing/data/models/pricing_plan_model.dart';

class PricingRepository {
  final ApiService _api;

  PricingRepository(this._api);

  Future<List<PricingPlanModel>> getPlans() async {
    final result = await _api.invoke(
      urlPath: '/pricing',
      type: RequestType.get,
      fun: (json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        final data = map['data'] as List<dynamic>? ?? [];
        return data
            .map((e) => PricingPlanModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      },
    );
    if (result is DataSuccess<List<PricingPlanModel>>) return result.data ?? [];
    throw Exception(result.error?.message ?? 'Failed to load pricing plans');
  }

  Future<PricingPlanModel> createPlan(PricingPlanModel plan) async {
    final result = await _api.invoke(
      urlPath: '/pricing',
      type: RequestType.post,
      params: plan.toCreateJson(),
      fun: (json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return PricingPlanModel.fromJson(
          Map<String, dynamic>.from(map['data'] as Map),
        );
      },
    );
    if (result is DataSuccess<PricingPlanModel>) return result.data!;
    throw Exception(result.error?.message ?? 'Failed to create pricing plan');
  }

  Future<PricingPlanModel> updatePlan(String id, Map<String, dynamic> body) async {
    final result = await _api.invoke(
      urlPath: '/pricing/$id',
      type: RequestType.put,
      params: body,
      fun: (json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return PricingPlanModel.fromJson(
          Map<String, dynamic>.from(map['data'] as Map),
        );
      },
    );
    if (result is DataSuccess<PricingPlanModel>) return result.data!;
    throw Exception(result.error?.message ?? 'Failed to update pricing plan');
  }

  Future<void> deletePlan(String id) async {
    final result = await _api.invoke(
      urlPath: '/pricing/$id',
      type: RequestType.delete,
      fun: (_) {},
    );
    if (result is DataFailure) {
      throw Exception(result.error?.message ?? 'Failed to delete pricing plan');
    }
  }
}
