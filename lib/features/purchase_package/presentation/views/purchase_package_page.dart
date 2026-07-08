import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

/// My Plan — modern Lovable-inspired subscription overview.
/// Data from `/auth/me` unchanged; UI-only upgrade.
class PurchasePackagePage extends StatefulWidget {
  const PurchasePackagePage({super.key});

  @override
  State<PurchasePackagePage> createState() => _PurchasePackagePageState();
}

class _PurchasePackagePageState extends State<PurchasePackagePage>
    with SingleTickerProviderStateMixin {
  static const _canvas = Color(0xFFFCFBF9);
  static const _foreground = Color(0xFF2A3038);
  static const _muted = Color(0xFF7A8494);
  static const _accent = Color(0xFFD4353A);

  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);
    _load();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
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
      if (!mounted) return;
      if (result is DataSuccess<Map<String, dynamic>>) {
        final data = result.data?['data'] as Map<String, dynamic>? ?? {};
        setState(() {
          _profile = data;
          _loading = false;
        });
        _enterCtrl.forward(from: 0);
      } else {
        setState(() {
          _error = result.error?.message ?? 'Failed to load plan';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ColoredBox(color: _canvas, child: _PlanSkeleton());
    }

    if (_error != null) {
      return ColoredBox(
        color: _canvas,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(fontSize: 14, color: _muted),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final access = _profile?['accessStatus'] as Map<String, dynamic>? ?? {};
    final subscription =
        _profile?['subscription'] as Map<String, dynamic>? ?? {};
    final hasAccess = access['hasAccess'] == true;
    final accessType = (access['accessType'] ?? 'none').toString();
    final planName =
        (access['planName'] ?? subscription['planName'] ?? '—').toString();
    final planPrice =
        (access['planPrice'] ?? subscription['planPrice'] ?? '').toString();
    final billingPeriod =
        (access['billingPeriod'] ?? subscription['billingPeriod'] ?? 'monthly')
            .toString();
    final billingLabel =
        billingPeriod == 'yearly' ? 'Yearly plan' : 'Monthly plan';
    final priceLabel = planPrice.isNotEmpty
        ? '₹$planPrice ${billingPeriod == 'yearly' ? '/ year' : '/ month'}'
        : '—';
    final daysRemaining = access['daysRemaining'];
    final trialCode = (_profile?['trialCode'] ?? '').toString();
    final trialEndsAt = access['trialEndsAt'] ?? _profile?['trialEndsAt'];
    final subscriptionExpiresAt =
        access['subscriptionExpiresAt'] ?? subscription['expiresAt'];
    final features = (_profile?['packageFeatures'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();

    return ColoredBox(
      color: _canvas,
      child: FadeTransition(
        opacity: _fade,
        child: RefreshIndicator(
          color: _accent,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _PlanHeroCard(
                hasAccess: hasAccess,
                accessType: accessType,
                planName: planName,
                planPrice: priceLabel,
                billingLabel: billingLabel,
                daysRemaining: daysRemaining,
                trialCode: trialCode,
                trialEndsAt: trialEndsAt?.toString(),
                subscriptionExpiresAt: subscriptionExpiresAt?.toString(),
                previewFeatures: features.take(3).toList(),
              ),
              if (features.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  'Plan Features',
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _foreground,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Everything included in your current package',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 16),
                _FeaturesGrid(features: features),
              ],
              if (!hasAccess) ...[
                const SizedBox(height: 24),
                const _ExpiredBanner(),
              ],
              const SizedBox(height: 28),
              _MetaGrid(
                hasAccess: hasAccess,
                accessType: accessType,
                billingLabel: billingLabel,
                daysRemaining: daysRemaining,
                trialCode: trialCode,
                trialEndsAt: trialEndsAt?.toString(),
                subscriptionExpiresAt: subscriptionExpiresAt?.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero plan card ───────────────────────────────────────────────────────────

class _PlanHeroCard extends StatefulWidget {
  final bool hasAccess;
  final String accessType;
  final String planName;
  final String planPrice;
  final String billingLabel;
  final dynamic daysRemaining;
  final String trialCode;
  final String? trialEndsAt;
  final String? subscriptionExpiresAt;
  final List<String> previewFeatures;

  const _PlanHeroCard({
    required this.hasAccess,
    required this.accessType,
    required this.planName,
    required this.planPrice,
    required this.billingLabel,
    required this.daysRemaining,
    required this.trialCode,
    this.trialEndsAt,
    this.subscriptionExpiresAt,
    required this.previewFeatures,
  });

  @override
  State<_PlanHeroCard> createState() => _PlanHeroCardState();
}

class _PlanHeroCardState extends State<_PlanHeroCard> {
  bool _hovered = false;

  static const _accent = Color(0xFFD4353A);
  static const _success = Color(0xFF16A34A);
  static const _foreground = Color(0xFF2A3038);
  static const _muted = Color(0xFF7A8494);

  @override
  Widget build(BuildContext context) {
    final accent = widget.hasAccess ? _success : _accent;
    final statusLabel = widget.hasAccess
        ? (widget.accessType == 'trial' ? 'Trial Active' : 'Subscription Active')
        : 'Expired';
    final renewLabel = _renewCopy();

    return MouseRegion(
      onEnter: (_) {
        if (!_hovered) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered) setState(() => _hovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.hasAccess
                ? [
                    const Color(0xFFFFF5F5),
                    const Color(0xFFFFFBF7),
                    Colors.white,
                  ]
                : [
                    const Color(0xFFFFF1F1),
                    const Color(0xFFFFF7F7),
                    Colors.white,
                  ],
          ),
          border: Border.all(
            color: _hovered
                ? accent.withValues(alpha: 0.4)
                : accent.withValues(alpha: 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: _hovered ? 0.16 : 0.08),
              blurRadius: _hovered ? 24 : 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.12),
                        accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC52031), Color(0xFFEA580C)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          widget.hasAccess
                                              ? Icons.verified_rounded
                                              : Icons.error_outline_rounded,
                                          size: 13,
                                          color: accent,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          statusLabel,
                                          style: GoogleFonts.sora(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: accent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F3F1),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Current Plan',
                                      style: GoogleFonts.sora(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: _muted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.planName,
                                style: GoogleFonts.sora(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: _foreground,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                [
                                  if (widget.planPrice != '—') widget.planPrice,
                                  if (renewLabel != null) renewLabel,
                                ].join('  ·  '),
                                style: GoogleFonts.sora(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                  color: _muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.previewFeatures.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Divider(
                        height: 1,
                        color: accent.withValues(alpha: 0.12),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        children: widget.previewFeatures
                            .map(
                              (f) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: _success,
                                  ),
                                  const SizedBox(width: 6),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 220),
                                    child: Text(
                                      f,
                                      style: GoogleFonts.sora(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _foreground,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _renewCopy() {
    if (widget.accessType == 'trial' &&
        widget.trialEndsAt != null &&
        widget.trialEndsAt!.isNotEmpty) {
      return 'Ends ${_fmt(widget.trialEndsAt!)}';
    }
    if (widget.subscriptionExpiresAt != null &&
        widget.subscriptionExpiresAt!.isNotEmpty) {
      return 'Renews ${_fmt(widget.subscriptionExpiresAt!)}';
    }
    if (widget.daysRemaining != null) {
      return '${widget.daysRemaining} days remaining';
    }
    if (widget.accessType == 'subscription') return widget.billingLabel;
    return null;
  }

  String _fmt(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// ─── Features grid ────────────────────────────────────────────────────────────

class _FeaturesGrid extends StatelessWidget {
  final List<String> features;

  const _FeaturesGrid({required this.features});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 900
            ? 3
            : (constraints.maxWidth >= 560 ? 2 : 1);

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < features.length; i++)
              SizedBox(
                width: cols == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 12 * (cols - 1)) / cols,
                child: _FeatureTile(
                  label: features[i],
                  index: i,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FeatureTile extends StatefulWidget {
  final String label;
  final int index;

  const _FeatureTile({required this.label, required this.index});

  @override
  State<_FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<_FeatureTile>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: 40 * widget.index.clamp(0, 16)), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: MouseRegion(
        onEnter: (_) {
          if (!_hovered) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (_hovered) setState(() => _hovered = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? const Color(0xFF16A34A).withValues(alpha: 0.35)
                  : const Color(0xFFECE8E6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.035),
                blurRadius: _hovered ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: GoogleFonts.sora(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2A3038),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Meta details ─────────────────────────────────────────────────────────────

class _MetaGrid extends StatelessWidget {
  final bool hasAccess;
  final String accessType;
  final String billingLabel;
  final dynamic daysRemaining;
  final String trialCode;
  final String? trialEndsAt;
  final String? subscriptionExpiresAt;

  const _MetaGrid({
    required this.hasAccess,
    required this.accessType,
    required this.billingLabel,
    required this.daysRemaining,
    required this.trialCode,
    this.trialEndsAt,
    this.subscriptionExpiresAt,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_MetaItem>[];

    items.add(
      _MetaItem(
        icon: Icons.category_outlined,
        label: 'Access Type',
        value: accessType == 'trial'
            ? 'Trial'
            : (accessType == 'subscription' ? 'Subscription' : 'None'),
      ),
    );

    if (accessType == 'subscription') {
      items.add(
        _MetaItem(
          icon: Icons.calendar_month_outlined,
          label: 'Billing',
          value: billingLabel,
        ),
      );
    }

    if (accessType == 'trial' && trialCode.isNotEmpty) {
      items.add(
        _MetaItem(
          icon: Icons.confirmation_number_outlined,
          label: 'Trial Code',
          value: trialCode,
        ),
      );
    }

    if (daysRemaining != null) {
      items.add(
        _MetaItem(
          icon: Icons.hourglass_bottom_rounded,
          label: 'Days Remaining',
          value: daysRemaining.toString(),
        ),
      );
    }

    if (trialEndsAt != null && trialEndsAt!.isNotEmpty) {
      items.add(
        _MetaItem(
          icon: Icons.event_outlined,
          label: 'Trial Ends',
          value: _fmt(trialEndsAt!),
        ),
      );
    }

    if (subscriptionExpiresAt != null && subscriptionExpiresAt!.isNotEmpty) {
      items.add(
        _MetaItem(
          icon: Icons.event_available_outlined,
          label: 'Subscription Ends',
          value: _fmt(subscriptionExpiresAt!),
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Details',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2A3038),
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 720 ? 3 : 2;
            final width =
                (constraints.maxWidth - 12 * (cols - 1)) / cols;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: items
                  .map(
                    (item) => SizedBox(
                      width: width,
                      child: _MetaTile(item: item),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  String _fmt(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _MetaItem {
  final IconData icon;
  final String label;
  final String value;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _MetaTile extends StatelessWidget {
  final _MetaItem item;

  const _MetaTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECE8E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F0),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, size: 20, color: const Color(0xFFD4353A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.sora(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7A8494),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2A3038),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Expired banner ───────────────────────────────────────────────────────────

class _ExpiredBanner extends StatelessWidget {
  const _ExpiredBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFEA580C),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Access expired',
                  style: GoogleFonts.sora(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9A3412),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your trial or subscription has expired. Please contact support or renew your plan to continue using the vendor panel.',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9A3412),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _PlanSkeleton extends StatelessWidget {
  const _PlanSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFECE8E6),
      highlightColor: const Color(0xFFF8F6F4),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            height: 20,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
