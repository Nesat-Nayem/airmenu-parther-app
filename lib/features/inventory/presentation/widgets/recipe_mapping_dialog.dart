import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/menu/menu_models.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/menu_repository.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Recipe Mapping manager.
///
/// Two views:
///  • List  — shows every menu item with its mapping status (mapped → shows
///            ingredient chips; unmapped → "Map recipe" CTA). Mapped recipes
///            can be edited or deleted.
///  • Form  — create or edit a single recipe (pick a menu item + ingredients
///            with quantities). When an order is served the backend deducts
///            each ingredient's quantity × ordered qty from inventory.
class RecipeMappingDialog extends StatefulWidget {
  const RecipeMappingDialog({super.key});

  @override
  State<RecipeMappingDialog> createState() => _RecipeMappingDialogState();
}

enum _View { list, form }

class _RecipeMappingDialogState extends State<RecipeMappingDialog> {
  _View _view = _View.list;

  // Menu items for this hotel.
  List<FoodItem> _menuItems = [];
  bool _loadingMenu = true;

  // Form state
  FoodItem? _selectedMenuItem;
  String? _editingRecipeId; // non-null when editing an existing recipe
  final List<RecipeIngredient> _ingredients = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InventoryBloc>().add(LoadRecipes());
    });
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    final hotelId = await locator<LocalStorage>().getString(localStorageKey: 'hotelId');
    if (hotelId == null || hotelId.isEmpty) {
      if (mounted) setState(() => _loadingMenu = false);
      return;
    }
    final categories = await locator<MenuRepository>().getMenuCategories(hotelId);
    final allItems = categories.expand((cat) => cat.items).toList();
    if (mounted) {
      setState(() {
        _menuItems = allItems;
        _loadingMenu = false;
      });
    }
  }

  String _menuItemName(String menuItemId, String fallback) {
    final match = _menuItems.where((m) => m.id == menuItemId).firstOrNull;
    if (match != null) return match.title;
    return fallback.isNotEmpty ? fallback : 'Unknown item';
  }

  // ── Form helpers ────────────────────────────────────────────────────────────
  void _startCreate({FoodItem? preselect}) {
    setState(() {
      _editingRecipeId = null;
      _selectedMenuItem = preselect;
      _ingredients
        ..clear()
        ..add(RecipeIngredient());
      _view = _View.form;
    });
  }

  void _startEdit(RecipeModel recipe) {
    final menuItem = _menuItems.where((m) => m.id == recipe.menuItemId).firstOrNull;
    setState(() {
      _editingRecipeId = recipe.id;
      _selectedMenuItem = menuItem;
      _ingredients
        ..clear()
        ..addAll(recipe.ingredients.map((i) => RecipeIngredient(
              materialId: i.materialId,
              materialName: i.materialName,
              quantity: _fmtQty(i.quantity),
            )));
      if (_ingredients.isEmpty) _ingredients.add(RecipeIngredient());
      _view = _View.form;
    });
  }

  static String _fmtQty(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  void _addIngredient() => setState(() => _ingredients.add(RecipeIngredient()));
  void _removeIngredient(int index) => setState(() => _ingredients.removeAt(index));

  void _saveMapping() {
    if (_selectedMenuItem == null) return;
    final validIngredients = _ingredients
        .where((i) => i.materialId != null && i.quantity != null && i.quantity!.trim().isNotEmpty)
        .map((i) => {
              'materialId': i.materialId,
              'quantity': double.tryParse(i.quantity ?? '0') ?? 0,
            })
        .where((m) => (m['quantity'] as double) > 0)
        .toList();
    if (validIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient with a quantity')),
      );
      return;
    }

    final bloc = context.read<InventoryBloc>();
    final payload = {
      'menuItemId': _selectedMenuItem!.id,
      'ingredients': validIngredients,
    };
    if (_editingRecipeId != null) {
      bloc.add(EditRecipe(_editingRecipeId!, payload));
    } else {
      bloc.add(AddRecipe(payload));
    }
    setState(() => _view = _View.list);
  }

  void _confirmDelete(RecipeModel recipe) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove recipe mapping'),
        content: Text(
          'Remove the recipe for "${_menuItemName(recipe.menuItemId, recipe.menuItemName)}"? '
          'Inventory will no longer be deducted for this item.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<InventoryBloc>().add(DeleteRecipe(recipe.id));
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Flexible(
              child: _view == _View.list ? _buildListView() : _buildFormView(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          if (_view == _View.form)
            IconButton(
              onPressed: () => setState(() => _view = _View.list),
              icon: const Icon(Icons.arrow_back, size: 20),
              color: const Color(0xFF6B7280),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
          if (_view == _View.form) const SizedBox(width: 8),
          Expanded(
            child: Text(
              _view == _View.list
                  ? 'Recipe Mapping'
                  : (_editingRecipeId != null ? 'Edit Recipe' : 'New Recipe'),
              style: AirMenuTextStyle.headingH3.bold700().withColor(Colors.black),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20),
            color: const Color(0xFF9CA3AF),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  // ── List view ───────────────────────────────────────────────────────────────
  Widget _buildListView() {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        final recipes = state.recipes;
        final recipeByMenuId = {for (final r in recipes) r.menuItemId: r};

        if (_loadingMenu) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final mappedCount = _menuItems.where((m) => recipeByMenuId.containsKey(m.id)).length;
        final unmappedCount = _menuItems.length - mappedCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              color: Colors.white,
              child: Row(
                children: [
                  _summaryPill('$mappedCount Mapped', const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
                  const SizedBox(width: 8),
                  _summaryPill('$unmappedCount Unmapped', const Color(0xFFDC2626), const Color(0xFFFEE2E2)),
                  const Spacer(),
                  // TextButton.icon(
                  //   onPressed: _menuItems.isEmpty ? null : () => _startCreate(),
                  //   icon: const Icon(Icons.add, size: 18),
                  //   label: const Text('New'),
                  //   style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                  // ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: _menuItems.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No menu items found for this restaurant',
                            style: TextStyle(color: Color(0xFF6B7280))),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _menuItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final item = _menuItems[i];
                        final recipe = recipeByMenuId[item.id];
                        return _menuItemTile(item, recipe);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryPill(String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: AirMenuTextStyle.small.bold600().withColor(fg)),
    );
  }

  Widget _menuItemTile(FoodItem item, RecipeModel? recipe) {
    final isMapped = recipe != null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMapped ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isMapped ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isMapped ? Icons.check_circle_outline : Icons.link_off,
                  size: 18,
                  color: isMapped ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: AirMenuTextStyle.normal.bold600().withColor(const Color(0xFF111827)),
                        overflow: TextOverflow.ellipsis),
                    Text(
                      isMapped
                          ? '${recipe.ingredients.length} ingredient${recipe.ingredients.length == 1 ? '' : 's'}'
                          : 'No recipe mapped',
                      style: AirMenuTextStyle.caption.medium500().withColor(
                            isMapped ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF),
                          ),
                    ),
                  ],
                ),
              ),
              if (isMapped) ...[
                IconButton(
                  onPressed: () => _startEdit(recipe),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: const Color(0xFF6B7280),
                  splashRadius: 18,
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _confirmDelete(recipe),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: const Color(0xFFEF4444),
                  splashRadius: 18,
                  tooltip: 'Remove',
                ),
              ] else
                TextButton(
                  onPressed: () => _startCreate(preselect: item),
                  child: const Text('Map recipe'),
                ),
            ],
          ),
          if (isMapped && recipe.ingredients.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: recipe.ingredients.map((ing) {
                final name = ing.materialName.isNotEmpty ? ing.materialName : 'Item';
                final unit = ing.materialUnit;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    '$name · ${_fmtQty(ing.quantity)}${unit.isNotEmpty ? ' $unit' : ''}',
                    style: AirMenuTextStyle.caption.medium500().withColor(const Color(0xFF374151)),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Form view ────────────────────────────────────────────────────────────────
  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Menu Item',
              style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF6B7280))),
          const SizedBox(height: 8),
          _buildMenuItemSelector(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ingredients',
                  style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF6B7280))),
              TextButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Ingredient'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF111827),
                  textStyle: AirMenuTextStyle.small.bold600(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._ingredients.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildIngredientRow(entry.key, entry.value),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quantities are per single serving. When an order for this '
                    'item is served, stock is reduced by quantity × number ordered.',
                    style: AirMenuTextStyle.caption.medium500().withColor(const Color(0xFF1D4ED8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildEstimatedCost(),
        ],
      ),
    );
  }

  Widget _buildEstimatedCost() {
    final materials = context.read<InventoryBloc>().state.items;
    double total = 0;
    for (final ing in _ingredients) {
      if (ing.materialId == null) continue;
      final qty = double.tryParse(ing.quantity ?? '0') ?? 0;
      final mat = materials.where((m) => m.id == ing.materialId).firstOrNull;
      if (mat != null) total += mat.costPrice * qty;
    }
    if (total <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Estimated Cost / Serving',
              style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF6B7280))),
          Text('₹${total.toStringAsFixed(2)}',
              style: AirMenuTextStyle.headingH4.black900().withColor(const Color(0xFF111827))),
        ],
      ),
    );
  }

  Widget _buildMenuItemSelector() {
    if (_loadingMenu) {
      return Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      // When editing, the menu item is locked (the recipe is keyed to it).
      onTap: _editingRecipeId != null ? null : () => _showMenuItemPicker(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedMenuItem != null ? const Color(0xFFEF4444) : const Color(0xFFF3F4F6),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _selectedMenuItem != null
                  ? Row(
                      children: [
                        const Icon(Icons.restaurant_menu, size: 16, color: Color(0xFFEF4444)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedMenuItem!.title,
                            style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF111827)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('₹${_selectedMenuItem!.price.toStringAsFixed(0)}',
                            style: AirMenuTextStyle.small.medium500().withColor(const Color(0xFF6B7280))),
                      ],
                    )
                  : Text(
                      _menuItems.isEmpty ? 'No menu items found' : 'Tap to select a menu item',
                      style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF9CA3AF)),
                    ),
            ),
            Icon(
              _editingRecipeId != null
                  ? Icons.lock_outline
                  : (_selectedMenuItem != null ? Icons.check_circle : Icons.keyboard_arrow_down),
              size: 18,
              color: _selectedMenuItem != null ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenuItemPicker() {
    // Menu items that already have a recipe (excluding the one being edited).
    final mappedIds = context
        .read<InventoryBloc>()
        .state
        .recipes
        .map((r) => r.menuItemId)
        .toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = _menuItems.where((item) {
              if (query.isEmpty) return true;
              return item.title.toLowerCase().contains(query.toLowerCase());
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (_, controller) => Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: TextField(
                      autofocus: true,
                      onChanged: (v) => setModalState(() => query = v),
                      decoration: InputDecoration(
                        hintText: 'Search menu items...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('No items found', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            controller: controller,
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final item = filtered[i];
                              final isSelected = _selectedMenuItem?.id == item.id;
                              final alreadyMapped = mappedIds.contains(item.id);
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFFEF2F2),
                                  child: Text(
                                    item.title.isNotEmpty ? item.title[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                        color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(item.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  alreadyMapped
                                      ? 'Already mapped · selecting will edit it'
                                      : '₹${item.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: alreadyMapped ? const Color(0xFFF59E0B) : const Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: Color(0xFFEF4444))
                                    : null,
                                onTap: () {
                                  Navigator.pop(ctx);
                                  // If the picked item is already mapped, switch
                                  // into edit mode for that recipe instead.
                                  final existing = context
                                      .read<InventoryBloc>()
                                      .state
                                      .recipes
                                      .where((r) => r.menuItemId == item.id)
                                      .firstOrNull;
                                  if (existing != null) {
                                    _startEdit(existing);
                                  } else {
                                    setState(() => _selectedMenuItem = item);
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIngredientRow(int index, RecipeIngredient ingredient) {
    final materials = context.watch<InventoryBloc>().state.items;
    final isMobile = Responsive.isMobile(context);

    final materialDropdown = DropdownButtonFormField<String>(
      initialValue: materials.any((m) => m.id == ingredient.materialId) ? ingredient.materialId : null,
      isExpanded: true,
      hint: Text('Select Ingredient',
          style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF9CA3AF))),
      onChanged: (val) => setState(() {
        final m = materials.where((m) => m.id == val).firstOrNull;
        ingredient.materialId = val;
        ingredient.materialName = m?.name;
      }),
      items: materials
          .map((m) => DropdownMenuItem(
                value: m.id,
                child: Text('${m.name} (${m.unit})',
                    style: AirMenuTextStyle.normal.medium500(), overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      decoration: _fieldDecoration(),
      dropdownColor: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF), size: 18),
    );

    final qtyField = TextFormField(
      initialValue: ingredient.quantity,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onChanged: (val) => setState(() => ingredient.quantity = val),
      decoration: _fieldDecoration(hint: 'Qty'),
      style: AirMenuTextStyle.normal.medium500(),
    );

    final removeBtn = IconButton(
      onPressed: _ingredients.length > 1 ? () => _removeIngredient(index) : null,
      icon: const Icon(Icons.close, size: 18),
      color: const Color(0xFFEF4444),
      splashRadius: 20,
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
    );

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(children: [
          Row(children: [Expanded(child: materialDropdown), const SizedBox(width: 8), removeBtn]),
          const SizedBox(height: 12),
          qtyField,
        ]),
      );
    }

    return Row(children: [
      Expanded(flex: 5, child: materialDropdown),
      const SizedBox(width: 12),
      Expanded(flex: 2, child: qtyField),
      const SizedBox(width: 12),
      removeBtn,
    ]);
  }

  InputDecoration _fieldDecoration({String? hint}) => InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        fillColor: Colors.white,
        filled: true,
      );

  // ── Footer ───────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    if (_view == _View.list) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF374151),
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Close', style: AirMenuTextStyle.normal.bold600()),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => setState(() => _view = _View.list),
            child: Text('Cancel', style: AirMenuTextStyle.normal.bold600().withColor(const Color(0xFF374151))),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _selectedMenuItem == null ? null : _saveMapping,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_editingRecipeId != null ? 'Update Recipe' : 'Save Recipe',
                style: AirMenuTextStyle.normal.bold600().withColor(Colors.white)),
          ),
        ],
      ),
    );
  }
}

class RecipeIngredient {
  String? materialId;
  String? materialName;
  String? quantity;

  RecipeIngredient({this.materialId, this.materialName, this.quantity = '1'});
}
