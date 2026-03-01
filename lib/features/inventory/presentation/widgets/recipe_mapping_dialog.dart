import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeMappingDialog extends StatefulWidget {
  const RecipeMappingDialog({super.key});

  @override
  State<RecipeMappingDialog> createState() => _RecipeMappingDialogState();
}

class _RecipeMappingDialogState extends State<RecipeMappingDialog> {
  final List<String> unitOptions = ['g', 'kg', 'ml', 'l', 'pcs'];

  // State
  String? selectedMenuItem;
  final List<RecipeIngredient> ingredients = [];

  @override
  void initState() {
    super.initState();
    ingredients.add(RecipeIngredient());
    // Load recipes if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InventoryBloc>().add(LoadRecipes());
    });
  }

  void _addIngredient() {
    setState(() => ingredients.add(RecipeIngredient()));
  }

  void _removeIngredient(int index) {
    setState(() => ingredients.removeAt(index));
  }

  void _saveMapping() {
    if (selectedMenuItem == null) return;
    final validIngredients = ingredients
        .where((i) => i.materialId != null && i.quantity != null && i.quantity!.isNotEmpty)
        .map((i) => {
              'materialId': i.materialId,
              'quantity': double.tryParse(i.quantity ?? '0') ?? 0,
            })
        .toList();
    if (validIngredients.isEmpty) return;

    context.read<InventoryBloc>().add(AddRecipe({
      'menuItemId': selectedMenuItem!,
      'ingredients': validIngredients,
    }));
    Navigator.pop(context);
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
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(), // Red top border included here if needed or via Container decoration
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Select Menu Item
                    Text(
                      'Select Menu Item',
                      style: AirMenuTextStyle.normal.medium500().withColor(
                        const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMenuDropdown(),
                    const SizedBox(height: 24),

                    // Ingredients Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ingredients',
                          style: AirMenuTextStyle.normal.medium500().withColor(
                            const Color(0xFF6B7280),
                          ),
                        ),
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

                    // Ingredients List
                    ...ingredients.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildIngredientRow(entry.key, entry.value),
                      );
                    }),

                    const SizedBox(height: 32),

                    // Estimated Cost
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                        ),
                      ),
                      child: Responsive.isMobile(context)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Cost per Serving',
                                  style: AirMenuTextStyle.large
                                      .medium500()
                                      .withColor(const Color(0xFF6B7280)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹85.50',
                                  style: AirMenuTextStyle.headingH2
                                      .black900()
                                      .withColor(const Color(0xFF111827)),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Estimated Cost per Serving',
                                  style: AirMenuTextStyle.large
                                      .medium500()
                                      .withColor(const Color(0xFF6B7280)),
                                ),
                                Text(
                                  '₹85.50', // Mock calculation
                                  style: AirMenuTextStyle.headingH2
                                      .black900()
                                      .withColor(const Color(0xFF111827)),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 4), // Visual adjustment
            child: Text(
              'Recipe Mapping',
              style: AirMenuTextStyle.headingH3.bold700().withColor(
                Colors.black,
              ),
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

  Widget _buildMenuDropdown() {
    return TextFormField(
      initialValue: selectedMenuItem,
      onChanged: (val) => setState(() => selectedMenuItem = val.trim().isEmpty ? null : val.trim()),
      style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: 'Enter menu item ID or name',
        hintStyle: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF9CA3AF)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
        fillColor: const Color(0xFFFAFAFA),
        filled: true,
      ),
    );
  }

  Widget _buildIngredientRow(int index, RecipeIngredient ingredient) {
    final materials = context.watch<InventoryBloc>().state.items;
    final isMobile = Responsive.isMobile(context);

    final materialDropdown = DropdownButtonFormField<InventoryItem>(
      value: materials.where((m) => m.id == ingredient.materialId).firstOrNull,
      hint: Text('Select Ingredient', style: AirMenuTextStyle.normal.medium500().withColor(const Color(0xFF9CA3AF))),
      onChanged: (val) => setState(() {
        ingredient.materialId = val?.id;
        ingredient.materialName = val?.name;
      }),
      items: materials.map((m) => DropdownMenuItem(
        value: m,
        child: Text('${m.name} (${m.unit})', style: AirMenuTextStyle.normal.medium500(), overflow: TextOverflow.ellipsis),
      )).toList(),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
        fillColor: Colors.white,
        filled: true,
      ),
      dropdownColor: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF), size: 18),
    );

    final qtyField = TextFormField(
      initialValue: ingredient.quantity,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      onChanged: (val) => ingredient.quantity = val,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
        hintText: 'Qty',
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        fillColor: Colors.white,
        filled: true,
      ),
      style: AirMenuTextStyle.normal.medium500(),
    );

    final removeBtn = IconButton(
      onPressed: () => _removeIngredient(index),
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

  Widget _buildFooter() {
    bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Save Button (Full Width)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveMapping,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Save Mapping',
                  style: AirMenuTextStyle.normal.bold600().withColor(
                    Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Cancel Button (Full Width)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF374151),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Text('Cancel', style: AirMenuTextStyle.normal.bold600()),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Cancel Button
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF374151),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Text('Cancel', style: AirMenuTextStyle.normal.bold600()),
          ),
          const SizedBox(width: 16),

          // Save Button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _saveMapping,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Save Mapping',
                style: AirMenuTextStyle.normal.bold600().withColor(
                  Colors.white,
                ),
              ),
            ),
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
