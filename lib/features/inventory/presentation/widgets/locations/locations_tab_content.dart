import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/locations/add_location_form_dialog.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';

class LocationsTabContent extends StatelessWidget {
  const LocationsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '4 active locations',
                style: AirMenuTextStyle.normal.medium500().withColor(
                  const Color(0xFF6B7280),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddLocationFormDialog(),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: InventoryColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: const [
              _LocationCard(
                name: 'Main Kitchen',
                type: 'Kitchen',
                address: '123 Main Street, Mumbai',
                manager: 'Rahul Sharma',
                phone: '+91 98765 43210',
                items: '5 items',
                critical: '1 critical',
                low: '2 low',
                value: '₹5,300 value',
                icon: Icons.kitchen,
                iconColor: Color(0xFF10B981),
                iconBg: Color(0xFFD1FAE5),
              ),
              _LocationCard(
                name: 'Downtown Branch',
                type: 'Branch',
                address: '456 MG Road, Mumbai',
                manager: 'Priya Patel',
                phone: '+91 98765 43211',
                items: '5 items',
                low: '1 low',
                value: '₹4,900 value',
                icon: Icons.storefront,
                iconColor: Color(0xFFEF4444),
                iconBg: Color(0xFFFEE2E2),
              ),
              _LocationCard(
                name: 'Central Warehouse',
                type: 'Warehouse',
                address: '789 Industrial Area, Mumbai',
                manager: 'Amit Kumar',
                phone: '+91 98765 43212',
                items: '5 items',
                value: '₹46,000 value',
                icon: Icons.warehouse,
                iconColor: Color(0xFFF59E0B),
                iconBg: Color(0xFFFEF3C7),
              ),
              _LocationCard(
                name: 'Cold Storage',
                type: 'Storage',
                address: '321 Warehouse Lane, Mumbai',
                manager: 'Neha Singh',
                phone: '+91 98765 43213',
                items: '3 items',
                value: '₹8,500 value',
                icon: Icons.ac_unit,
                iconColor: Color(0xFF3B82F6),
                iconBg: Color(0xFFDBEAFE),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String name;
  final String type;
  final String address;
  final String manager;
  final String phone;
  final String items;
  final String value;
  final String? critical;
  final String? low;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _LocationCard({
    required this.name,
    required this.type,
    required this.address,
    required this.manager,
    required this.phone,
    required this.items,
    required this.value,
    this.critical,
    this.low,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500, // Fixed width for Grid feel in Wrap
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AirMenuTextStyle.large.bold600().withColor(
                              const Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            type,
                            style: AirMenuTextStyle.small.medium500().withColor(
                              const Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            address,
            style: AirMenuTextStyle.normal.medium500().withColor(
              const Color(0xFF6B7280),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Manager: $manager',
                style: AirMenuTextStyle.small.medium500().withColor(
                  const Color(0xFF6B7280),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1D5DB),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  phone,
                  style: AirMenuTextStyle.small.medium500().withColor(
                    const Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        items,
                        style: AirMenuTextStyle.small.bold600().withColor(
                          const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                  if (critical != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          critical!,
                          style: AirMenuTextStyle.small.bold600().withColor(
                            const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  if (low != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_down,
                          size: 14,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          low!,
                          style: AirMenuTextStyle.small.bold600().withColor(
                            const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Text(
                value,
                style: AirMenuTextStyle.small.medium500().withColor(
                  const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
