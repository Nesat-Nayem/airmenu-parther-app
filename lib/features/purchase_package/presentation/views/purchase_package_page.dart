import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class PurchasePackagePage extends StatefulWidget {
  const PurchasePackagePage({super.key});

  @override
  State<PurchasePackagePage> createState() => _PurchasePackagePageState();
}

class _PurchasePackagePageState extends State<PurchasePackagePage> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await locator<ApiService>().invoke(
        urlPath: '/auth/me',
        type: RequestType.get,
        fun: (json) => jsonDecode(json) as Map<String, dynamic>,
      );
      if (result is DataSuccess<Map<String, dynamic>>) {
        final data = result.data?['data'] as Map<String, dynamic>? ?? {};
        setState(() {
          _profile = data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = result.error?.message ?? 'Failed to load plan';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final access = _profile?['accessStatus'] as Map<String, dynamic>? ?? {};
    final subscription = _profile?['subscription'] as Map<String, dynamic>? ?? {};
    final hasAccess = access['hasAccess'] == true;
    final accessType = (access['accessType'] ?? 'none').toString();
    final planName = (access['planName'] ?? subscription['planName'] ?? '—').toString();
    final planPrice = (access['planPrice'] ?? subscription['planPrice'] ?? '').toString();
    final billingPeriod = (access['billingPeriod'] ?? subscription['billingPeriod'] ?? 'monthly').toString();
    final billingLabel = billingPeriod == 'yearly' ? 'Yearly plan' : 'Monthly plan';
    final priceLabel = planPrice.isNotEmpty
        ? '$planPrice ${billingPeriod == 'yearly' ? 'per year' : 'per month'}'
        : '—';
    final daysRemaining = access['daysRemaining'];
    final trialCode = (_profile?['trialCode'] ?? '').toString();
    final trialEndsAt = access['trialEndsAt'] ?? _profile?['trialEndsAt'];
    final subscriptionExpiresAt = access['subscriptionExpiresAt'] ?? subscription['expiresAt'];
    final features = (_profile?['packageFeatures'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return Container(
      color: const Color(0xFFF9FAFB),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _StatusCard(
            hasAccess: hasAccess,
            accessType: accessType,
            planName: planName,
            planPrice: priceLabel,
            billingLabel: billingLabel,
            daysRemaining: daysRemaining,
            trialCode: trialCode,
            trialEndsAt: trialEndsAt?.toString(),
            subscriptionExpiresAt: subscriptionExpiresAt?.toString(),
          ),
          const SizedBox(height: 20),
          if (features.isNotEmpty) ...[
            Text('Plan Features', style: AirMenuTextStyle.headingH4.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...features.map(
              (f) => Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
                  title: Text(f),
                ),
              ),
            ),
          ],
          if (!hasAccess) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Text(
                'Your trial or subscription has expired. Please contact support or renew your plan to continue using the vendor panel.',
                style: AirMenuTextStyle.small.copyWith(color: const Color(0xFF9A3412)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool hasAccess;
  final String accessType;
  final String planName;
  final String planPrice;
  final String billingLabel;
  final dynamic daysRemaining;
  final String trialCode;
  final String? trialEndsAt;
  final String? subscriptionExpiresAt;

  const _StatusCard({
    required this.hasAccess,
    required this.accessType,
    required this.planName,
    required this.planPrice,
    required this.billingLabel,
    required this.daysRemaining,
    required this.trialCode,
    this.trialEndsAt,
    this.subscriptionExpiresAt,
  });

  @override
  Widget build(BuildContext context) {
    final accent = hasAccess ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final statusLabel = hasAccess
        ? (accessType == 'trial' ? 'Trial Active' : 'Subscription Active')
        : 'Expired';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasAccess ? Icons.verified_rounded : Icons.error_outline_rounded,
                color: accent,
              ),
              const SizedBox(width: 10),
              Text(statusLabel, style: AirMenuTextStyle.headingH4.copyWith(color: accent, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          _row('Plan', planName),
          if (accessType == 'subscription') ...[
            _row('Billing', billingLabel),
            if (planPrice != '—') _row('Price', planPrice),
          ],
          if (accessType == 'trial' && trialCode.isNotEmpty) _row('Trial Code', trialCode),
          if (daysRemaining != null) _row('Days Remaining', daysRemaining.toString()),
          if (trialEndsAt != null && trialEndsAt!.isNotEmpty) _row('Trial Ends', _fmt(trialEndsAt!)),
          if (subscriptionExpiresAt != null && subscriptionExpiresAt!.isNotEmpty)
            _row('Subscription Ends', _fmt(subscriptionExpiresAt!)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(width: 140, child: Text(label, style: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade600))),
        Expanded(child: Text(value, style: AirMenuTextStyle.normal.copyWith(fontWeight: FontWeight.w600))),
      ],
    ),
  );

  String _fmt(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
