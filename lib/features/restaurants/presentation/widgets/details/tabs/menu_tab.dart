import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/menu/menu_models.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/menu/menu_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/menu/menu_event.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/menu/menu_state.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/menu_tab_modals.dart';

class MenuTab extends StatefulWidget {
  final String hotelId;

  const MenuTab({super.key, required this.hotelId});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  static const _primaryColor = Color(0xFFC52031);
  static const _greenColor = Color(0xFF16A34A);
  
  // Track expanded categories
  final Set<String> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(LoadMenuCategories(widget.hotelId));
  }

  void _showToast(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : _greenColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MenuBloc, MenuState>(
      listener: (context, state) {
        if (state is MenuLoaded) {
          if (state.errorMessage != null) {
            _showToast(context, state.errorMessage!, isError: true);
          }
          if (state.successMessage != null) {
            _showToast(context, state.successMessage!);
          }
        }
      },
      builder: (context, state) {
        if (state is MenuLoading) {
          return _buildShimmerLoading();
        }
        if (state is MenuError) {
          return _buildErrorState(state.message);
        }
        if (state is MenuLoaded) {
          return _buildMenuContent(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 28, width: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
              Row(children: List.generate(3, (_) => Container(height: 44, width: 120, margin: const EdgeInsets.only(left: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))))),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.85, crossAxisSpacing: 20, mainAxisSpacing: 20),
            itemCount: 6,
            itemBuilder: (_, __) => Container(height: 300, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red[200]!)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red[100], shape: BoxShape.circle),
              child: Icon(Icons.error_outline, size: 48, color: Colors.red[600]),
            ),
            const SizedBox(height: 20),
            Text('Failed to Load Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700])),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.red[600])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<MenuBloc>().add(LoadMenuCategories(widget.hotelId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuContent(BuildContext context, MenuLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context, state),
        const SizedBox(height: 20),
        state.categories.isEmpty ? _buildEmptyState() : _buildCategoriesGrid(context, state),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, MenuLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const Text('Menu Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const Spacer(),
          _buildHeaderButton('Menu Settings', Icons.settings_outlined, Colors.white, Colors.grey[700]!, () => MenuTabModals.showSettingsModal(context, widget.hotelId, state), hasBorder: true),
          const SizedBox(width: 10),
          _buildGradientButton('AI Import Menu', Icons.auto_awesome, () => MenuTabModals.showAIImportModal(context, widget.hotelId, state)),
          const SizedBox(width: 10),
          _buildHeaderButton('Add Category', Icons.add, _greenColor, Colors.white, state.isAddingCategory ? null : () => MenuTabModals.showAddCategoryModal(context, widget.hotelId), isLoading: state.isAddingCategory),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String label, IconData icon, Color bgColor, Color fgColor, VoidCallback? onPressed, {bool hasBorder = false, bool isLoading = false}) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: hasBorder ? Border.all(color: Colors.grey[300]!) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: fgColor))
              else
                Icon(icon, size: 18, color: fgColor),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: fgColor, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(String label, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF4F46E5)]),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: const Color(0xFF9333EA).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.restaurant_menu, size: 48, color: _primaryColor),
            ),
            const SizedBox(height: 20),
            const Text('No Menu Categories Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const SizedBox(height: 8),
            Text('Add your first category to start building your menu', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => MenuTabModals.showAddCategoryModal(context, widget.hotelId),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
              style: ElevatedButton.styleFrom(backgroundColor: _greenColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, MenuLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 500 ? 1 : (constraints.maxWidth < 850 ? 2 : 3);
        double cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 20) / crossAxisCount;
        
        // Build list of items including skeleton for new category
        List<Widget> categoryWidgets = [];
        
        for (var category in state.categories) {
          categoryWidgets.add(
            SizedBox(
              width: cardWidth,
              child: _buildCategoryCard(context, state, category),
            ),
          );
        }
        
        // Add skeleton card if adding new category
        if (state.isAddingCategory) {
          categoryWidgets.add(
            SizedBox(
              width: cardWidth,
              child: _buildCategorySkeletonCard(),
            ),
          );
        }
        
        // Group into rows
        List<Widget> rows = [];
        for (int i = 0; i < categoryWidgets.length; i += crossAxisCount) {
          List<Widget> rowChildren = [];
          for (int j = i; j < i + crossAxisCount && j < categoryWidgets.length; j++) {
            rowChildren.add(categoryWidgets[j]);
            if (j < i + crossAxisCount - 1 && j < categoryWidgets.length - 1) {
              rowChildren.add(const SizedBox(width: 20));
            }
          }
          // Fill remaining space if row is incomplete
          if (rowChildren.length < crossAxisCount * 2 - 1) {
            int emptySlots = crossAxisCount - ((rowChildren.length + 1) ~/ 2);
            for (int k = 0; k < emptySlots; k++) {
              rowChildren.add(const SizedBox(width: 20));
              rowChildren.add(SizedBox(width: cardWidth));
            }
          }
          rows.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rowChildren,
              ),
            ),
          );
        }
        
        return Column(
          children: rows,
        );
      },
    );
  }

  Widget _buildCategorySkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
              child: Row(
                children: [
                  Container(height: 20, width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const Spacer(),
                  Container(height: 28, width: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                  const SizedBox(width: 6),
                  Container(height: 28, width: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                ],
              ),
            ),
            Container(
              height: 100,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(height: 16, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, MenuLoaded state, MenuCategory category) {
    final isExpanded = _expandedCategories.contains(category.name);
    final itemsToShow = isExpanded ? category.items : category.items.take(3).toList();
    final remainingCount = category.items.length - 3;
    final isDeleting = state.isDeletingCategory && state.deletingCategoryName == category.name;
    final isAddingItemHere = state.isAddingItem && state.addingItemToCategoryName == category.name;
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDeleting ? _primaryColor.withOpacity(0.5) : Colors.grey[200]!),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header with Name and Actions
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
                child: Row(
                  children: [
                    Expanded(child: Text(category.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)), overflow: TextOverflow.ellipsis)),
                    _actionButton('Edit', _primaryColor, isDeleting ? null : () => MenuTabModals.showEditCategoryModal(context, widget.hotelId, category)),
                    const SizedBox(width: 6),
                    _actionButton('Delete', _primaryColor, isDeleting ? null : () => MenuTabModals.showDeleteCategoryDialog(context, widget.hotelId, category)),
                    const SizedBox(width: 6),
                    _actionButton('Add Item', _primaryColor, isDeleting || isAddingItemHere ? null : () => MenuTabModals.showAddItemModal(context, widget.hotelId, state, category)),
                  ],
                ),
              ),
          // Category Image - supports all image formats
          Container(
            height: 100,
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: category.image.isNotEmpty
                  ? Image.network(
                      category.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => Center(child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 40)),
                    )
                  : Center(child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 40)),
            ),
          ),
          // Items Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Text('Items (${category.items.length})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
                const Spacer(),
                if (category.items.isNotEmpty)
                  Text('${category.items.length} dish${category.items.length > 1 ? "es" : ""}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Items List - expandable
          if (category.items.isEmpty && !isAddingItemHere)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
              child: Text('No items in this category', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...itemsToShow.map((item) => _buildFoodItemRow(context, state, category, item)),
                  // Skeleton for adding new item
                  if (isAddingItemHere) _buildItemSkeletonRow(),
                  // Expand/Collapse button
                  if (remainingCount > 0)
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedCategories.remove(category.name);
                          } else {
                            _expandedCategories.add(category.name);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _primaryColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 18,
                              color: _primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isExpanded ? 'Show less' : 'View +$remainingCount more items',
                              style: TextStyle(
                                color: _primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
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
        // Deleting overlay
        if (isDeleting)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 3, color: _primaryColor),
                    ),
                    const SizedBox(height: 12),
                    Text('Deleting...', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItemSkeletonRow() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
            Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            const SizedBox(width: 6),
            Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback? onPressed) {
    final isDisabled = onPressed == null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDisabled ? color.withOpacity(0.5) : color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildFoodItemRow(BuildContext context, MenuLoaded state, MenuCategory category, FoodItem item) {
    final isDeleting = state.deletingItemId == item.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Item Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.image != null && item.image!.isNotEmpty
                ? Image.network(item.image!, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholderImage())
                : _placeholderImage(),
          ),
          const SizedBox(width: 12),
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('₹${item.price.toStringAsFixed(0)}', style: TextStyle(color: _greenColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    if (item.offer != null && item.offer!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(4)),
                        child: Text(item.offer!, style: TextStyle(color: Colors.orange[700], fontSize: 10, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          _itemActionButton(Icons.edit_outlined, Colors.blue, () => MenuTabModals.showEditItemModal(context, widget.hotelId, state, category, item)),
          const SizedBox(width: 6),
          _itemActionButton(Icons.delete_outline, _primaryColor, isDeleting ? null : () => MenuTabModals.showDeleteItemDialog(context, widget.hotelId, item), isLoading: isDeleting),
        ],
      ),
    );
  }

  Widget _placeholderImage() => Container(
    width: 48, height: 48,
    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
    child: Icon(Icons.fastfood, color: Colors.grey[400], size: 24),
  );

  Widget _itemActionButton(IconData icon, Color color, VoidCallback? onPressed, {bool isLoading = false}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: isLoading
            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: color))
            : Icon(icon, color: color, size: 16),
      ),
    );
  }
}
