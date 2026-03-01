import 'package:airmenuai_partner_app/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/menu/menu_models.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/menu/menu_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/menu/menu_state.dart'
    as admin_menu_state;
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/menu_tab_modals.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Skeleton shimmer helper ─────────────────────────────────────────────────
class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _Shimmer({required this.width, required this.height, this.radius = 8});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.fromRGBO(203, 213, 225, _anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ─── Skeleton: Category Sidebar ──────────────────────────────────────────────
class VendorCategorySidebarSkeleton extends StatelessWidget {
  const VendorCategorySidebarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AirMenuColors.borderDefault)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Shimmer(width: 100, height: 20, radius: 6),
          const SizedBox(height: 20),
          ...List.generate(
            6,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  _Shimmer(width: 80 + (i % 3) * 20, height: 14, radius: 6),
                  const Spacer(),
                  const _Shimmer(width: 22, height: 14, radius: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton: Menu Item List Tile ───────────────────────────────────────────
class VendorMenuListSkeleton extends StatelessWidget {
  const VendorMenuListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AirMenuColors.borderDefault),
        ),
        child: Row(
          children: [
            const _Shimmer(width: 24, height: 24, radius: 4),
            const SizedBox(width: 12),
            const _Shimmer(width: 52, height: 52, radius: 8),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shimmer(width: 120 + (i % 3) * 30.0, height: 14, radius: 6),
                  const SizedBox(height: 6),
                  const _Shimmer(width: 70, height: 12, radius: 6),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const _Shimmer(width: 50, height: 16, radius: 6),
            const SizedBox(width: 24),
            const _Shimmer(width: 36, height: 36, radius: 18),
            const SizedBox(width: 8),
            const _Shimmer(width: 36, height: 36, radius: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton: Menu Item Grid ─────────────────────────────────────────────────
class VendorMenuGridSkeleton extends StatelessWidget {
  const VendorMenuGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.9,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AirMenuColors.borderDefault),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const _Shimmer(width: 90, height: 90, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _Shimmer(width: double.infinity, height: 16, radius: 6),
                  SizedBox(height: 8),
                  _Shimmer(width: 80, height: 12, radius: 6),
                  SizedBox(height: 8),
                  _Shimmer(width: 120, height: 12, radius: 6),
                  SizedBox(height: 8),
                  _Shimmer(width: 60, height: 12, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vendor Category Sidebar ────────────────────────────────────────────────
class VendorCategorySidebar extends StatelessWidget {
  final String hotelId;
  const VendorCategorySidebar({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AirMenuColors.borderDefault)),
      ),
      child: BlocBuilder<MenuBloc, admin_menu_state.MenuState>(
        builder: (context, menuState) {
          return BlocBuilder<MenuCubit, MenuState>(
            builder: (context, uiState) {
              final categories = menuState is admin_menu_state.MenuLoaded
                  ? menuState.categories
                  : <MenuCategory>[];
              final totalCount =
                  categories.fold<int>(0, (sum, c) => sum + c.items.length);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: AirMenuTextStyle.headingH4
                              .bold700()
                              .withColor(Colors.black),
                        ),
                        if (menuState is admin_menu_state.MenuLoaded)
                          IconButton(
                            onPressed: () => MenuTabModals.showAddCategoryModal(
                                context, hotelId),
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            color: AirMenuColors.primaryRed,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Add Category',
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _CategoryItem(
                      label: 'All Items',
                      count: totalCount,
                      categoryId: 'all',
                      isActive: uiState.selectedCategoryId == 'all',
                      onTap: () =>
                          context.read<MenuCubit>().selectCategory('all'),
                    ),
                    const SizedBox(height: 4),
                    ...categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _CategoryItemWithActions(
                          label: cat.name,
                          count: cat.items.length,
                          categoryId: cat.name,
                          isActive: uiState.selectedCategoryId == cat.name,
                          onTap: () => context
                              .read<MenuCubit>()
                              .selectCategory(cat.name),
                          onEdit: () => MenuTabModals.showEditCategoryModal(
                              context, hotelId, cat),
                          onDelete: () =>
                              MenuTabModals.showDeleteCategoryDialog(
                                  context, hotelId, cat),
                        ),
                      );
                    }),
                    if (menuState is admin_menu_state.MenuLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(
                            child:
                                CircularProgressIndicator(strokeWidth: 2)),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Category Item (plain) ───────────────────────────────────────────────────
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
              if (isActive)
                Icon(Icons.drag_indicator,
                    size: 16, color: AirMenuColors.primaryRed),
              if (isActive) const SizedBox(width: 8),
              if (!isActive) const SizedBox(width: 24),
              Expanded(
                child: Text(
                  label,
                  style: AirMenuTextStyle.normal.medium500().withColor(
                    isActive
                        ? AirMenuColors.primaryRed
                        : AirMenuColors.textPrimary,
                  ).copyWith(
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                count.toString(),
                style: AirMenuTextStyle.small.medium500().withColor(
                  isActive
                      ? AirMenuColors.primaryRed
                      : AirMenuColors.textTertiary,
                ).copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category Item with Edit/Delete ─────────────────────────────────────────
class _CategoryItemWithActions extends StatefulWidget {
  final String label;
  final int count;
  final String categoryId;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryItemWithActions({
    required this.label,
    required this.count,
    required this.categoryId,
    this.isActive = false,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CategoryItemWithActions> createState() =>
      _CategoryItemWithActionsState();
}

class _CategoryItemWithActionsState
    extends State<_CategoryItemWithActions> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AirMenuColors.primaryRedLight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (widget.isActive)
                  Icon(Icons.drag_indicator,
                      size: 16, color: AirMenuColors.primaryRed),
                if (widget.isActive) const SizedBox(width: 8),
                if (!widget.isActive) const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    widget.label,
                    style: AirMenuTextStyle.normal.medium500().withColor(
                      widget.isActive
                          ? AirMenuColors.primaryRed
                          : AirMenuColors.textPrimary,
                    ).copyWith(
                      fontWeight: widget.isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.count.toString(),
                  style: AirMenuTextStyle.small.medium500().withColor(
                    widget.isActive
                        ? AirMenuColors.primaryRed
                        : AirMenuColors.textTertiary,
                  ).copyWith(fontSize: 13),
                ),
                if (_hovered || widget.isActive) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onEdit,
                    child: const Icon(Icons.edit_outlined,
                        size: 14,
                        color: AirMenuColors.textSecondary),
                  ),
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: const Icon(Icons.delete_outline,
                        size: 14, color: AirMenuColors.nonVegRed),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Vendor Menu Header ──────────────────────────────────────────────────────
class VendorMenuHeader extends StatelessWidget {
  final String hotelId;
  const VendorMenuHeader({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(bottom: BorderSide(color: AirMenuColors.borderDefault)),
      ),
      child: BlocBuilder<MenuBloc, admin_menu_state.MenuState>(
        builder: (context, menuState) {
          final loaded = menuState is admin_menu_state.MenuLoaded
              ? menuState
              : null;
          return Row(
            children: [
              // Search Bar
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    hintStyle: AirMenuTextStyle.normal
                        .medium500()
                        .withColor(const Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF9CA3AF), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(
                          color: AirMenuColors.borderDefault),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(
                          color: AirMenuColors.borderDefault),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                  onChanged: (val) =>
                      context.read<MenuCubit>().updateSearchQuery(val),
                ),
              ),
              const SizedBox(width: 16),
              // View Toggle
              BlocBuilder<MenuCubit, MenuState>(
                builder: (context, uiState) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AirMenuColors.borderDefault),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _ViewToggleButton(
                          icon: Icons.format_list_bulleted,
                          isActive:
                              uiState.viewMode == MenuViewMode.list,
                          onTap: () => context
                              .read<MenuCubit>()
                              .setViewMode(MenuViewMode.list),
                        ),
                        _ViewToggleButton(
                          icon: Icons.grid_view,
                          isActive:
                              uiState.viewMode == MenuViewMode.grid,
                          onTap: () => context
                              .read<MenuCubit>()
                              .setViewMode(MenuViewMode.grid),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              // AI Import Button
              OutlinedButton.icon(
                onPressed: loaded == null
                    ? null
                    : () => MenuTabModals.showAIImportModal(
                        context, hotelId, loaded),
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: Text('AI Import',
                    style: AirMenuTextStyle.normal.bold600()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AirMenuColors.textPrimary,
                  side:
                      const BorderSide(color: AirMenuColors.borderDefault),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 12),
              // Add Item Button
              ElevatedButton.icon(
                onPressed: loaded == null || loaded.categories.isEmpty
                    ? null
                    : () => MenuTabModals.showAddItemModal(
                        context, hotelId, loaded, loaded.categories.first),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Add Item',
                  style: AirMenuTextStyle.normal
                      .bold600()
                      .copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AirMenuColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          );
        },
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
          color: isActive
              ? AirMenuColors.primaryRedLight
              : Colors.transparent,
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

// ─── Vendor Menu Item Card (Grid) ────────────────────────────────────────────
class VendorMenuItemCard extends StatelessWidget {
  final FoodItem item;
  final String hotelId;
  final admin_menu_state.MenuLoaded state;
  final MenuCategory category;

  const VendorMenuItemCard({
    super.key,
    required this.item,
    required this.hotelId,
    required this.state,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isVeg = item.itemType.any((t) =>
        t.toLowerCase() == 'veg' || t.toLowerCase() == 'vegetarian');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AirMenuColors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image with veg indicator
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: item.image != null && item.image!.isNotEmpty
                      ? Image.network(item.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder())
                      : _imagePlaceholder(),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 3)
                    ],
                  ),
                  child: Icon(
                    Icons.circle,
                    color: isVeg
                        ? AirMenuColors.vegGreen
                        : AirMenuColors.nonVegRed,
                    size: 7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: AirMenuTextStyle.normal
                      .bold600()
                      .withColor(AirMenuColors.textPrimary)
                      .copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  category.name,
                  style: AirMenuTextStyle.small
                      .medium500()
                      .withColor(AirMenuColors.textSecondary)
                      .copyWith(fontSize: 12),
                ),
                if (item.description.isNotEmpty) ...
                  [
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: AirMenuTextStyle.small
                          .medium500()
                          .withColor(AirMenuColors.textTertiary)
                          .copyWith(fontSize: 12, height: 1.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: AirMenuTextStyle.normal
                          .bold700()
                          .withColor(AirMenuColors.primaryRed)
                          .copyWith(fontSize: 14),
                    ),
                    const Spacer(),
                    _ActionButton(
                      icon: Icons.edit_outlined,
                      onTap: () => MenuTabModals.showEditItemModal(
                          context, hotelId, state, category, item),
                    ),
                    const SizedBox(width: 2),
                    _ActionButton(
                      icon: Icons.delete_outline,
                      onTap: () => MenuTabModals.showDeleteItemDialog(
                          context, hotelId, item),
                      color: AirMenuColors.nonVegRed,
                    ),
                  ],
                ),
                if (item.attributes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: item.attributes
                          .take(2)
                          .map((a) => _Tag(a))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE5989B).withOpacity(0.3),
      child: const Icon(Icons.fastfood,
          color: AirMenuColors.textTertiary, size: 28),
    );
  }
}

// ─── Vendor Menu Item List Tile ──────────────────────────────────────────────
class VendorMenuItemListTile extends StatelessWidget {
  final FoodItem item;
  final String hotelId;
  final admin_menu_state.MenuLoaded state;
  final MenuCategory category;

  const VendorMenuItemListTile({
    super.key,
    required this.item,
    required this.hotelId,
    required this.state,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isVeg = item.itemType.any((t) =>
        t.toLowerCase() == 'veg' || t.toLowerCase() == 'vegetarian');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AirMenuColors.borderDefault),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator,
              color: AirMenuColors.textTertiary),
          const SizedBox(width: 12),
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 52,
              height: 52,
              child: item.image != null && item.image!.isNotEmpty
                  ? Image.network(item.image!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE5989B).withOpacity(0.3)))
                  : Container(
                      color: const Color(0xFFE5989B).withOpacity(0.3)),
            ),
          ),
          const SizedBox(width: 12),
          // Name + category
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle,
                        color: isVeg
                            ? AirMenuColors.vegGreen
                            : AirMenuColors.nonVegRed,
                        size: 10),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(item.title,
                          style: AirMenuTextStyle.normal.bold600(),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                Text(
                  category.name,
                  style: AirMenuTextStyle.small
                      .medium500()
                      .withColor(AirMenuColors.textSecondary),
                ),
              ],
            ),
          ),
          // Price
          Expanded(
            flex: 1,
            child: Text('₹${item.price.toStringAsFixed(0)}',
                style: AirMenuTextStyle.normal.bold600()),
          ),
          // Actions
          IconButton(
            onPressed: () => MenuTabModals.showEditItemModal(
                context, hotelId, state, category, item),
            icon: const Icon(Icons.edit_outlined,
                size: 18, color: AirMenuColors.textSecondary),
          ),
          IconButton(
            onPressed: () =>
                MenuTabModals.showDeleteItemDialog(context, hotelId, item),
            icon: const Icon(Icons.delete_outline,
                size: 18, color: AirMenuColors.nonVegRed),
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────
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
        padding: const EdgeInsets.all(6),
        child: Icon(icon,
            size: 18, color: color ?? AirMenuColors.textSecondary),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AirMenuColors.primaryRedLight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: AirMenuTextStyle.small
            .medium500()
            .withColor(AirMenuColors.primaryRed)
            .copyWith(fontSize: 11),
      ),
    );
  }
}

// ─── Mobile Widgets ──────────────────────────────────────────────────────────
class VendorMobileMenuHeader extends StatelessWidget {
  final String hotelId;
  const VendorMobileMenuHeader({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, admin_menu_state.MenuState>(
      builder: (context, menuState) {
        final loaded = menuState is admin_menu_state.MenuLoaded ? menuState : null;
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Menu',
                        style: AirMenuTextStyle.headingH3.bold700()),
                  ),
                  if (loaded != null)
                    IconButton(
                      onPressed: () => MenuTabModals.showAIImportModal(
                          context, hotelId, loaded),
                      icon: const Icon(Icons.auto_awesome,
                          color: AirMenuColors.primaryRed),
                    ),
                  if (loaded != null && loaded.categories.isNotEmpty)
                    IconButton(
                      onPressed: () => MenuTabModals.showAddItemModal(
                          context, hotelId, loaded, loaded.categories.first),
                      icon: const Icon(Icons.add,
                          color: AirMenuColors.primaryRed),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search menu items...',
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF9CA3AF), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide:
                        const BorderSide(color: AirMenuColors.borderDefault),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide:
                        const BorderSide(color: AirMenuColors.borderDefault),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
                onChanged: (val) =>
                    context.read<MenuCubit>().updateSearchQuery(val),
              ),
            ],
          ),
        );
      },
    );
  }
}

class VendorMobileCategories extends StatelessWidget {
  final String hotelId;
  const VendorMobileCategories({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, admin_menu_state.MenuState>(
      builder: (context, menuState) {
        return BlocBuilder<MenuCubit, MenuState>(
          builder: (context, uiState) {
            final categories = menuState is admin_menu_state.MenuLoaded
                ? menuState.categories
                : <MenuCategory>[];
            return SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _MobileCategoryChip(
                    label: 'All',
                    isActive: uiState.selectedCategoryId == 'all',
                    onTap: () =>
                        context.read<MenuCubit>().selectCategory('all'),
                  ),
                  ...categories.map((c) => _MobileCategoryChip(
                        label: c.name,
                        isActive: uiState.selectedCategoryId == c.name,
                        onTap: () =>
                            context.read<MenuCubit>().selectCategory(c.name),
                      )),
                ],
              ),
            );
          },
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AirMenuColors.primaryRed
              : AirMenuColors.primaryRedLight,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: AirMenuTextStyle.small.bold600().withColor(
            isActive ? Colors.white : AirMenuColors.primaryRed,
          ),
        ),
      ),
    );
  }
}

class VendorMobileMenuItemCard extends StatelessWidget {
  final FoodItem item;
  final String hotelId;
  final admin_menu_state.MenuLoaded state;
  final MenuCategory category;

  const VendorMobileMenuItemCard({
    super.key,
    required this.item,
    required this.hotelId,
    required this.state,
    required this.category,
  });

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 64,
              height: 64,
              child: item.image != null && item.image!.isNotEmpty
                  ? Image.network(item.image!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[200]))
                  : Container(color: Colors.grey[200]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AirMenuTextStyle.normal.bold600(),
                    overflow: TextOverflow.ellipsis),
                Text(category.name,
                    style: AirMenuTextStyle.small
                        .medium500()
                        .withColor(AirMenuColors.textSecondary)),
                Text('₹${item.price.toStringAsFixed(0)}',
                    style: AirMenuTextStyle.normal
                        .bold700()
                        .withColor(AirMenuColors.primaryRed)),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () => MenuTabModals.showEditItemModal(
                    context, hotelId, state, category, item),
                child: const Icon(Icons.edit_outlined,
                    size: 18, color: AirMenuColors.textSecondary),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => MenuTabModals.showDeleteItemDialog(
                    context, hotelId, item),
                child: const Icon(Icons.delete_outline,
                    size: 18, color: AirMenuColors.nonVegRed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
