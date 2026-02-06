import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:shimmer/shimmer.dart';

class VendorSettingsShimmer extends StatelessWidget {
  const VendorSettingsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sidebar Shimmer
                  SizedBox(
                    width: 250,
                    child: Column(
                      children: List.generate(
                        6,
                        (index) => _buildSidebarItem(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 32),

                  // Content Shimmer
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 180,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(child: _buildInputShimmer()),
                              const SizedBox(width: 24),
                              Expanded(child: _buildInputShimmer()),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: _buildInputShimmer()),
                              const SizedBox(width: 24),
                              Expanded(child: _buildInputShimmer()),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildInputShimmer(),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: _buildInputShimmer()),
                              const SizedBox(width: 24),
                              Expanded(child: _buildInputShimmer()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 100, height: 14, color: Colors.white),
              const SizedBox(height: 4),
              Container(width: 80, height: 10, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 80, height: 14, color: Colors.white),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SettingsSectionHeader({
    super.key,
    required this.title,
    this.subtitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AirMenuTextStyle.headingH4.copyWith(
            fontWeight: FontWeight.bold,
            color: AirMenuColors.textPrimary,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AirMenuTextStyle.normal.copyWith(
              color: AirMenuColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class SettingsTextField extends StatelessWidget {
  final String label;
  final String initialValue;
  final bool readOnly;

  const SettingsTextField({
    super.key,
    required this.label,
    required this.initialValue,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            fontWeight: FontWeight.w600,
            color: AirMenuColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          readOnly: readOnly,
          style: AirMenuTextStyle.normal,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AirMenuColors.primary),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class SettingsDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const SettingsDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            fontWeight: FontWeight.w600,
            color: AirMenuColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              isExpanded: true,
              hint: Text(
                'Select $label',
                style: AirMenuTextStyle.normal.copyWith(
                  color: Colors.grey.shade400,
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: AirMenuTextStyle.normal),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AirMenuColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AirMenuTextStyle.small.copyWith(
                    color: AirMenuColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AirMenuColors.primary,
          ),
        ],
      ),
    );
  }
}

class TimingRow extends StatelessWidget {
  final String day;
  final String start;
  final String end;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onStartTimeTap;
  final VoidCallback? onEndTimeTap;

  const TimingRow({
    super.key,
    required this.day,
    required this.start,
    required this.end,
    required this.enabled,
    required this.onToggle,
    this.onStartTimeTap,
    this.onEndTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              day,
              style: AirMenuTextStyle.normal.copyWith(
                fontWeight: FontWeight.w600,
                color: AirMenuColors.textPrimary,
              ),
            ),
          ),
          if (enabled) ...[
            _buildTimeBox(start, onStartTimeTap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'to',
                style: AirMenuTextStyle.small.copyWith(
                  color: AirMenuColors.textSecondary,
                ),
              ),
            ),
            _buildTimeBox(end, onEndTimeTap),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  'Closed',
                  style: AirMenuTextStyle.small.copyWith(
                    color: AirMenuColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          const Spacer(),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeColor: Colors.white,
            activeTrackColor: AirMenuColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String time, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time,
              style: AirMenuTextStyle.normal.copyWith(
                color: AirMenuColors.textPrimary,
              ),
            ),
            const Icon(
              Icons.access_time_rounded,
              size: 18,
              color: AirMenuColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class VendorSettingsMobileShimmer extends StatelessWidget {
  const VendorSettingsMobileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Shimmer
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                // Tabs Shimmer
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      4,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          width: 80,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 1), // Dividerish

          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInputShimmer(),
                  const SizedBox(height: 16),
                  _buildInputShimmer(),
                  const SizedBox(height: 16),
                  _buildInputShimmer(),
                  const SizedBox(height: 16),
                  _buildInputShimmer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 80, height: 14, color: Colors.white),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class PrinterCard extends StatelessWidget {
  final String name;
  final String location;
  final String ip;
  final bool isConnected;

  const PrinterCard({
    super.key,
    required this.name,
    required this.location,
    required this.ip,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: isConnected
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isConnected ? 'connected' : 'offline',
                            style: AirMenuTextStyle.caption.copyWith(
                              color: isConnected
                                  ? const Color(0xFF047857)
                                  : const Color(0xFFB91C1C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  location,
                  style: AirMenuTextStyle.small.copyWith(
                    color: AirMenuColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'IP: $ip',
                  style: AirMenuTextStyle.small.copyWith(
                    color: AirMenuColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text('Test Print'),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
