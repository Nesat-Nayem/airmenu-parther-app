import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_event.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class DetailsTabs extends StatelessWidget {
  final int selectedIndex;

  const DetailsTabs({super.key, required this.selectedIndex});

  static const _tabs = [
    {'icon': Icons.storefront_outlined, 'label': 'Overview'},
    {'icon': Icons.restaurant_menu_outlined, 'label': 'Menu & Issues'},
    {'icon': Icons.qr_code_2_outlined, 'label': 'Tables & QR'},
    {'icon': Icons.inventory_2_outlined, 'label': 'Inventory Health'},
    {'icon': Icons.receipt_long_outlined, 'label': 'Billing'},
    {'icon': Icons.people_outline, 'label': 'Staff & Roles'},
    {'icon': Icons.integration_instructions_outlined, 'label': 'Integrations'},
    {'icon': Icons.checklist_outlined, 'label': 'Onboarding'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                context.read<RestaurantDetailsBloc>().add(
                  SwitchDetailsTab(index),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFC52031)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _tabs[index]['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _tabs[index]['label'] as String,
                      style: AirMenuTextStyle.small.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
