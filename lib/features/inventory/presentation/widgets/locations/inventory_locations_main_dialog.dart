import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/locations_cubit.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/locations/locations_tab_content.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/locations/stock_by_location_tab_content.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/locations/transfers_tab_content.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryLocationsMainDialog extends StatelessWidget {
  const InventoryLocationsMainDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocationsCubit(),
      child: const _DialogShell(),
    );
  }
}

class _DialogShell extends StatelessWidget {
  const _DialogShell();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 1100,
        height: 800,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with Tabs
            const _Header(),

            // Content Area
            Expanded(
              child: BlocBuilder<LocationsCubit, LocationsState>(
                builder: (context, state) {
                  final index = (state as LocationsInitial).selectedTabIndex;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey(index),
                      child: _buildContent(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return const LocationsTabContent();
      case 1:
        return const StockByLocationTabContent();
      case 2:
        return const TransfersTabContent();
      default:
        return const SizedBox();
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFFEF4444),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Multi-Location Inventory Management',
                          style: AirMenuTextStyle.headingH4.withColor(
                            const Color(0xFF111827),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),

          // Floating Tabs centered
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(30),
              ),
              child: BlocBuilder<LocationsCubit, LocationsState>(
                builder: (context, state) {
                  final selectedIndex =
                      (state as LocationsInitial).selectedTabIndex;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TabButton(
                          label: 'Locations',
                          isSelected: selectedIndex == 0,
                          onTap: () =>
                              context.read<LocationsCubit>().selectTab(0),
                        ),
                        const SizedBox(width: 4),
                        _TabButton(
                          label: 'Stock by Location',
                          isSelected: selectedIndex == 1,
                          onTap: () =>
                              context.read<LocationsCubit>().selectTab(1),
                        ),
                        const SizedBox(width: 4),
                        _TabButton(
                          label: 'Transfers',
                          isSelected: selectedIndex == 2,
                          onTap: () =>
                              context.read<LocationsCubit>().selectTab(2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEF4444)
              : Colors.transparent, // Red vs Transparent
          borderRadius: BorderRadius.circular(24),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AirMenuTextStyle.small.medium500().withColor(
            isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
