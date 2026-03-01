import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/locations_extended_cubit.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/locations/add_location_form_dialog.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';

class LocationsTabContent extends StatelessWidget {
  const LocationsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationsExtCubit, LocationsExtState>(
      builder: (context, state) {
        if (state.status == LocationsExtStatus.loading && state.locations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final locations = state.locations;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${locations.length} active location${locations.length == 1 ? '' : 's'}',
                    style: AirMenuTextStyle.normal.medium500().withColor(
                      const Color(0xFF6B7280),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => BlocProvider.value(
                          value: context.read<LocationsExtCubit>(),
                          child: const AddLocationFormDialog(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: InventoryColors.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (locations.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No locations found')))
              else
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: locations.map((loc) => _LocationCard(
                    name: loc.name,
                    type: loc.type,
                    address: loc.address,
                    manager: loc.manager,
                    phone: loc.phone,
                    items: '',
                    icon: _iconForType(loc.type),
                    iconColor: _colorForType(loc.type),
                    iconBg: _bgForType(loc.type),
                    onEdit: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => BlocProvider.value(
                          value: context.read<LocationsExtCubit>(),
                          child: AddLocationFormDialog(existing: loc),
                        ),
                      );
                    },
                    onDelete: () => context.read<LocationsExtCubit>().removeLocation(loc.id),
                  )).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'warehouse': return Icons.warehouse;
      case 'branch': return Icons.storefront;
      case 'storage': return Icons.ac_unit;
      default: return Icons.kitchen;
    }
  }

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'warehouse': return const Color(0xFFF59E0B);
      case 'branch': return const Color(0xFFEF4444);
      case 'storage': return const Color(0xFF3B82F6);
      default: return const Color(0xFF10B981);
    }
  }

  Color _bgForType(String type) {
    switch (type.toLowerCase()) {
      case 'warehouse': return const Color(0xFFFEF3C7);
      case 'branch': return const Color(0xFFFEE2E2);
      case 'storage': return const Color(0xFFDBEAFE);
      default: return const Color(0xFFD1FAE5);
    }
  }
}

class _LocationCard extends StatelessWidget {
  final String name;
  final String type;
  final String address;
  final String manager;
  final String phone;
  final String items;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _LocationCard({
    required this.name,
    required this.type,
    required this.address,
    required this.manager,
    required this.phone,
    required this.items,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.onEdit,
    this.onDelete,
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
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
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
          if (items.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(items, style: AirMenuTextStyle.small.bold600().withColor(const Color(0xFF374151))),
              ],
            ),
        ],
      ),
    );
  }
}
