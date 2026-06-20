import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item.dart';
import 'package:airmenuai_partner_app/core/services/vendor_nav_menu_flags_service.dart';
import 'package:airmenuai_partner_app/features/common_shell/app_scaffold_shell.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class FeatureFlagsListView extends StatefulWidget {
  const FeatureFlagsListView({super.key});

  @override
  State<FeatureFlagsListView> createState() => _FeatureFlagsListViewState();
}

class _FeatureFlagsListViewState extends State<FeatureFlagsListView> {
  final VendorNavMenuFlagsService _flagsService =
      locator<VendorNavMenuFlagsService>();

  Map<String, bool> _flags = {};
  bool _loading = true;
  String? _error;
  String? _successMessage;
  final Set<String> _savingKeys = {};

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
      final flags = await _flagsService.load(force: true);
      if (!mounted) return;
      setState(() {
        _flags = Map<String, bool>.from(flags);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load vendor menu feature flags';
        _loading = false;
      });
    }
  }

  Future<void> _toggleFlag(NavMenuItem item, bool enabled) async {
    final key = item.vendorNavFlagKey;
    setState(() {
      _savingKeys.add(key);
      _error = null;
      _successMessage = null;
      _flags[key] = enabled;
    });

    final ok = await _flagsService.updateFlag(key, enabled);
    if (!mounted) return;

    setState(() {
      _savingKeys.remove(key);
      if (ok) {
        _flags = Map<String, bool>.from(_flagsService.flags);
        _successMessage = '${item.getTitle()} ${enabled ? 'enabled' : 'hidden'} for vendors';
      } else {
        _flags[key] = !enabled;
        _error = 'Failed to update ${item.getTitle()}';
      }
    });

    if (ok) {
      await AppScaffoldShell.refreshNavigation();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = vendorNavMenuFeatureFlags;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.menu_open_rounded, color: Color(0xFFDC2626)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vendor Sidebar Menu',
                        style: AirMenuTextStyle.subheadingH5.copyWith(
                          color: const Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Show or hide menu items in the vendor panel sidebar. Changes apply to all vendors immediately.',
                        style: AirMenuTextStyle.small.copyWith(
                          color: const Color(0xFF7F1D1D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            _buildBanner(_error!, isError: true),
            const SizedBox(height: 12),
          ],
          if (_successMessage != null) ...[
            _buildBanner(_successMessage!, isError: false),
            const SizedBox(height: 12),
          ],
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  _buildFeatureRow(
                    items[i],
                    isLast: i == items.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(NavMenuItem item, {required bool isLast}) {
    final key = item.vendorNavFlagKey;
    final isEnabled = _flags[key] ?? true;
    final isSaving = _savingKeys.contains(key);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AirMenuColors.primary.shade9,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.getIcon(), color: AirMenuColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.getTitle(),
                  style: AirMenuTextStyle.headingH4.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AirMenuColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.vendorNavFlagDescription,
                  style: AirMenuTextStyle.normal.copyWith(
                    color: AirMenuColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isSaving)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch.adaptive(
              value: isEnabled,
              activeTrackColor: const Color(0xFFDC2626),
              onChanged: (value) => _toggleFlag(item, value),
            ),
        ],
      ),
    );
  }

  Widget _buildBanner(String message, {required bool isError}) {
    final color = isError ? const Color(0xFFDC2626) : const Color(0xFF10B981);
    final bgColor = isError ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5);
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AirMenuTextStyle.small.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
