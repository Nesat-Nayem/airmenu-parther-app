import 'package:airmenuai_partner_app/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:airmenuai_partner_app/features/menu/presentation/widgets/add_edit_item_dialog.dart';
import 'package:airmenuai_partner_app/features/menu/presentation/widgets/ai_import_dialog.dart';
import 'package:airmenuai_partner_app/features/menu/presentation/widgets/manage_categories_dialog.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Category Sidebar ---
class CategorySidebar extends StatelessWidget {
  const CategorySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AirMenuColors.borderDefault)),
      ),
      child: BlocBuilder<MenuCubit, MenuState>(
        builder: (context, state) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: AirMenuTextStyle.headingH4.bold700().withColor(
                      Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const ManageCategoriesDialog(),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: AirMenuColors.textSecondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _CategoryItem(
                label: 'All Items',
                count: 5,
                categoryId: 'all',
                isActive: state.selectedCategoryId == 'all',
                onTap: () => context.read<MenuCubit>().selectCategory('all'),
              ),
              const SizedBox(height: 4),
              _CategoryItem(
                label: 'Main Course',
                count: 24,
                categoryId: 'main-course',
                isActive: state.selectedCategoryId == 'main-course',
                onTap: () =>
                    context.read<MenuCubit>().selectCategory('main-course'),
              ),
              const SizedBox(height: 4),
              _CategoryItem(
                label: 'Starters',
                count: 18,
                categoryId: 'starters',
                isActive: state.selectedCategoryId == 'starters',
                onTap: () =>
                    context.read<MenuCubit>().selectCategory('starters'),
              ),
              const SizedBox(height: 4),
              _CategoryItem(
                label: 'Breads',
                count: 12,
                categoryId: 'breads',
                isActive: state.selectedCategoryId == 'breads',
                onTap: () => context.read<MenuCubit>().selectCategory('breads'),
              ),
              const SizedBox(height: 4),
              _CategoryItem(
                label: 'Rice',
                count: 8,
                categoryId: 'rice',
                isActive: state.selectedCategoryId == 'rice',
                onTap: () => context.read<MenuCubit>().selectCategory('rice'),
              ),
              const SizedBox(height: 4),
              _CategoryItem(
                label: 'Desserts',
                count: 10,
                categoryId: 'desserts',
                isActive: state.selectedCategoryId == 'desserts',
                onTap: () =>
                    context.read<MenuCubit>().selectCategory('desserts'),
              ),
              const SizedBox(height: 4),
              _CategoryItem(
                label: 'Beverages',
                count: 15,
                categoryId: 'beverages',
                isActive: state.selectedCategoryId == 'beverages',
                onTap: () =>
                    context.read<MenuCubit>().selectCategory('beverages'),
              ),
              const SizedBox(height: 4),
              _CategoryItem(
                label: 'Combos',
                count: 6,
                categoryId: 'combos',
                isActive: state.selectedCategoryId == 'combos',
                onTap: () => context.read<MenuCubit>().selectCategory('combos'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final int count;
  final String categoryId;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label,
    required this.count,
    required this.categoryId,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AirMenuColors.primaryRedLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Show drag indicator only for active item
              if (isActive)
                Icon(
                  Icons.drag_indicator,
                  size: 16,
                  color: AirMenuColors.primaryRed,
                ),
              if (isActive) const SizedBox(width: 8),
              if (!isActive) const SizedBox(width: 24), // Spacing alignment
              Expanded(
                child: Text(
                  label,
                  style: AirMenuTextStyle.normal
                      .medium500()
                      .withColor(
                        isActive
                            ? AirMenuColors.primaryRed
                            : AirMenuColors.textPrimary,
                      )
                      .copyWith(
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 14,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                count.toString(),
                style: AirMenuTextStyle.small
                    .medium500()
                    .withColor(
                      isActive
                          ? AirMenuColors.primaryRed
                          : AirMenuColors.textTertiary,
                    )
                    .copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Menu Header ---
class MenuHeader extends StatelessWidget {
  const MenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AirMenuColors.borderDefault)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar (Search, Filter, Actions)
          Row(
            children: [
              // Search Bar
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    hintStyle: AirMenuTextStyle.normal.medium500().withColor(
                      const Color(0xFF9CA3AF),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                    suffixIcon: const Icon(
                      Icons.filter_list,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ), // Filter inside search or separate? Screenshot typically shows separate button or inside.
                    // Designing based on "Search menu items..." text field + separate circle filter button
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(
                        color: AirMenuColors.borderDefault,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(
                        color: AirMenuColors.borderDefault,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (val) =>
                      context.read<MenuCubit>().updateSearchQuery(val),
                ),
              ),
              const SizedBox(width: 16),
              // Filter Button (Circle)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AirMenuColors.borderDefault),
                  color: Colors.white,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 20),
                  color: AirMenuColors.textSecondary,
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // View Toggle
              BlocBuilder<MenuCubit, MenuState>(
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AirMenuColors.borderDefault),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _ViewToggleButton(
                          icon: Icons
                              .format_list_bulleted, // List icon refinement
                          isActive: state.viewMode == MenuViewMode.list,
                          onTap: () => context.read<MenuCubit>().setViewMode(
                            MenuViewMode.list,
                          ),
                        ),
                        _ViewToggleButton(
                          icon: Icons.grid_view,
                          isActive: state.viewMode == MenuViewMode.grid,
                          onTap: () => context.read<MenuCubit>().setViewMode(
                            MenuViewMode.grid,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),

              // AI Import Button
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AiMenuImportDialog(),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AirMenuColors.textPrimary,
                  side: const BorderSide(color: AirMenuColors.borderDefault),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 16),
                    const SizedBox(width: 8),
                    Text('AI Import', style: AirMenuTextStyle.normal.bold600()),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Add Item Button
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        const AddEditMenuItemDialog(), // Default Add Mode
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AirMenuColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 18),
                    const SizedBox(width: 6),
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

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? AirMenuColors.primaryRedLight : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive
              ? AirMenuColors.primaryRed
              : AirMenuColors.textSecondary,
        ),
      ),
    );
  }
}

// --- Menu Item Card (Grid) ---
class MenuItemCard extends StatelessWidget {
  final dynamic item;

  const MenuItemCard({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF1E293B,
            ).withOpacity(0.08), // Softer, premium shadow
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AirMenuColors.borderDefault.withOpacity(0.6)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: Image + Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Overlay
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
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
                    // Veg/Non-Veg Indicator (Overlay)
                    Positioned(
                      top: 8,
                      left: 8,
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
                          Icons.circle, // Inner dot
                          color: (item?.isVeg ?? false)
                              ? AirMenuColors.vegGreen
                              : AirMenuColors.nonVegRed,
                          size: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item?.name ?? 'Butter Chicken',
                              style: AirMenuTextStyle.headingH4
                                  .bold700()
                                  .withColor(AirMenuColors.textPrimary)
                                  .copyWith(fontSize: 18), // Slightly larger
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${(item?.price ?? 350).toStringAsFixed(0)}',
                            style: AirMenuTextStyle.headingH4
                                .bold700()
                                .withColor(AirMenuColors.textPrimary)
                                .copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item?.category ?? 'Main Course',
                        style: AirMenuTextStyle.small.medium500().withColor(
                          AirMenuColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        item?.description ??
                            'Creamy tomato-based curry with tender chicken pieces. Rich flavor profile.',
                        style: AirMenuTextStyle.normal
                            .medium500()
                            .withColor(AirMenuColors.textTertiary)
                            .copyWith(fontSize: 13, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Stats Row
                      Row(
                        children: [
                          _StatLabel('${item?.variants ?? 2} variants'),
                          const SizedBox(width: 12),
                          _StatLabel('${item?.addOns ?? 2} add-ons'),
                          const SizedBox(width: 12),
                          // Growth Stat
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.trending_up,
                                size: 14,
                                color: AirMenuColors.vegGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '45 today',
                                style: AirMenuTextStyle.small
                                    .bold600()
                                    .withColor(AirMenuColors.vegGreen),
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
          ),

          const SizedBox(height: 16),
          // Bottom Actions & Tags Row
          Row(
            children: [
              // Tag (Mocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // Amber-100
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Missing description',
                  style: AirMenuTextStyle.small
                      .medium500()
                      .withColor(
                        const Color(0xFFD97706), // Amber-600
                      )
                      .copyWith(fontSize: 11),
                ),
              ),
              const Spacer(),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(icon: Icons.visibility_outlined, onTap: () {}),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AddEditMenuItemDialog(),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    onTap: () {},
                    color: AirMenuColors.nonVegRed,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Padding(
        padding: const EdgeInsets.all(6), // Easier touch target
        child: Icon(
          icon,
          size: 18,
          color: color ?? AirMenuColors.textSecondary,
        ),
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  final String text;
  const _StatLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AirMenuTextStyle.small.medium500().withColor(
        AirMenuColors.textSecondary,
      ),
    );
  }
}

class MenuItemListTile extends StatelessWidget {
  final dynamic item;

  const MenuItemListTile({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AirMenuColors.borderDefault),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Drag Handle
          const Icon(Icons.drag_indicator, color: AirMenuColors.textTertiary),
          const SizedBox(width: 16),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48,
              height: 48,
              color: const Color(0xFFE5989B).withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 16),

          // Name & Cat
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.crop_square,
                      color: AirMenuColors.vegGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Butter Chicken',
                      style: AirMenuTextStyle.normal.bold600(),
                    ),
                  ],
                ),
                Text(
                  'Main Course',
                  style: AirMenuTextStyle.small.medium500().withColor(
                    AirMenuColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Price
          Expanded(
            flex: 1,
            child: Text('₹350', style: AirMenuTextStyle.normal.bold600()),
          ),

          // Toggle
          Expanded(
            flex: 1,
            child: Switch(
              value: true,
              activeColor: AirMenuColors.primaryRed,
              onChanged: (val) {},
            ),
          ),

          // Actions
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AirMenuColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AirMenuColors.nonVegRed,
            ),
          ),
        ],
      ),
    );
  }
}
