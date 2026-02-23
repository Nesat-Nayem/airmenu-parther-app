import 'package:airmenuai_partner_app/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:airmenuai_partner_app/features/menu/presentation/widgets/add_edit_item_dialog.dart';
import 'package:airmenuai_partner_app/features/menu/presentation/widgets/ai_import_dialog.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ===== MOBILE UI WIDGETS =====

// Mobile Header with Search and Actions
class MobileMenuHeader extends StatelessWidget {
  const MobileMenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AirMenuColors.borderDefault)),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search menu items...',
              hintStyle: AirMenuTextStyle.normal.medium500().withColor(
                const Color(0xFF9CA3AF),
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AirMenuColors.borderDefault,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AirMenuColors.borderDefault,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (val) =>
                context.read<MenuCubit>().updateSearchQuery(val),
          ),
          const SizedBox(height: 12),

          // Action Buttons Row
          Row(
            children: [
              // View Toggles
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AirMenuColors.borderDefault),
                ),
                padding: const EdgeInsets.all(4),
                child: BlocBuilder<MenuCubit, MenuState>(
                  builder: (context, state) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MobileViewToggle(
                          icon: Icons.format_list_bulleted,
                          isActive: state.viewMode == MenuViewMode.list,
                          onTap: () => context.read<MenuCubit>().setViewMode(
                            MenuViewMode.list,
                          ),
                        ),
                        _MobileViewToggle(
                          icon: Icons.grid_view,
                          isActive: state.viewMode == MenuViewMode.grid,
                          onTap: () => context.read<MenuCubit>().setViewMode(
                            MenuViewMode.grid,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // AI Import Button
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AiMenuImportDialog(),
                  );
                },
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('AI Import'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AirMenuColors.textPrimary,
                  side: const BorderSide(color: AirMenuColors.borderDefault),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Add Item Button
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddEditMenuItemDialog(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AirMenuColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Add Item',
                      style: AirMenuTextStyle.normal.bold600().copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileViewToggle extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _MobileViewToggle({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF3F4F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive
              ? AirMenuColors.textPrimary
              : AirMenuColors.textSecondary,
        ),
      ),
    );
  }
}

// Mobile Horizontal Categories
class MobileCategories extends StatelessWidget {
  const MobileCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuCubit, MenuState>(
      builder: (context, state) {
        return Container(
          height: 50,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AirMenuColors.borderDefault),
            ),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _MobileCategoryChip(
                label: 'All',
                isActive: state.selectedCategoryId == 'all',
                onTap: () => context.read<MenuCubit>().selectCategory('all'),
              ),
              const SizedBox(width: 8),
              _MobileCategoryChip(
                label: 'Main Course',
                isActive: state.selectedCategoryId == 'main-course',
                onTap: () =>
                    context.read<MenuCubit>().selectCategory('main-course'),
              ),
              const SizedBox(width: 8),
              _MobileCategoryChip(
                label: 'Starters',
                isActive: state.selectedCategoryId == 'starters',
                onTap: () =>
                    context.read<MenuCubit>().selectCategory('starters'),
              ),
              const SizedBox(width: 8),
              _MobileCategoryChip(
                label: 'Breads',
                isActive: state.selectedCategoryId == 'breads',
                onTap: () => context.read<MenuCubit>().selectCategory('breads'),
              ),
              const SizedBox(width: 8),
              _MobileCategoryChip(
                label: 'Rice',
                isActive: state.selectedCategoryId == 'rice',
                onTap: () => context.read<MenuCubit>().selectCategory('rice'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MobileCategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MobileCategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AirMenuColors.primaryRed : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AirMenuColors.primaryRed
                : AirMenuColors.borderDefault,
          ),
        ),
        child: Text(
          label,
          style: AirMenuTextStyle.normal
              .medium500()
              .withColor(isActive ? Colors.white : AirMenuColors.textPrimary)
              .copyWith(fontSize: 14),
        ),
      ),
    );
  }
}

class MobileMenuItemCard extends StatelessWidget {
  final dynamic item;

  const MobileMenuItemCard({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AirMenuColors.borderDefault.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        item?.imageUrl ??
                            'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Veg/Non-Veg Indicator
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.circle,
                    color: (item?.isVeg ?? false)
                        ? AirMenuColors.vegGreen
                        : AirMenuColors.nonVegRed,
                    size: 8,
                  ),
                ),
              ),
            ],
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Category
                Text(
                  item?.name ?? 'Butter Chicken',
                  style: AirMenuTextStyle.headingH4
                      .bold700()
                      .withColor(AirMenuColors.textPrimary)
                      .copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item?.category ?? 'Main Course',
                  style: AirMenuTextStyle.small.medium500().withColor(
                    AirMenuColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  item?.description ??
                      'Creamy tomato-based curry with tender chicken pieces',
                  style: AirMenuTextStyle.normal
                      .medium500()
                      .withColor(AirMenuColors.textTertiary)
                      .copyWith(fontSize: 14, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Stats Row
                Row(
                  children: [
                    _MobileStatLabel('${item?.variants ?? 2} variants'),
                    const SizedBox(width: 12),
                    _MobileStatLabel('${item?.addOns ?? 2} add-ons'),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 14,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item?.ordersToday ?? 45} today',
                          style: AirMenuTextStyle.small
                              .medium500()
                              .withColor(const Color(0xFF10B981))
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileStatLabel extends StatelessWidget {
  final String text;

  const _MobileStatLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AirMenuTextStyle.small
            .medium500()
            .withColor(AirMenuColors.textSecondary)
            .copyWith(fontSize: 12),
      ),
    );
  }
}
