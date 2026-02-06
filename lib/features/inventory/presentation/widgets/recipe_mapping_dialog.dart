import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';

class RecipeMappingDialog extends StatefulWidget {
  const RecipeMappingDialog({super.key});

  @override
  State<RecipeMappingDialog> createState() => _RecipeMappingDialogState();
}

class _RecipeMappingDialogState extends State<RecipeMappingDialog> {
  // Mock Data
  final List<String> menuItems = [
    'Butter Chicken',
    'Paneer Tikka',
    'Dal Makhani',
    'Chicken Biryani',
    'Veg Korma',
  ];

  final List<String> ingredientOptions = [
    'Paneer',
    'Chicken',
    'Basmati Rice',
    'Fresh Cream',
    'Onions',
    'Cooking Oil',
    'Tomato Puree',
    'Ginger Garlic Paste',
  ];

  final List<String> unitOptions = ['grams', 'kg', 'ml', 'L', 'pcs'];

  // State
  String? selectedMenuItem;
  final List<RecipeIngredient> ingredients = [];

  @override
  void initState() {
    super.initState();
    // Initialize with one empty ingredient row like in screenshot
    ingredients.add(RecipeIngredient());
  }

  void _addIngredient() {
    setState(() {
      ingredients.add(RecipeIngredient());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return PopupMenuButton<String>(
          offset: const Offset(0, 48),
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          color: Colors.white,
          onSelected: (value) => setState(() => selectedMenuItem = value),
          itemBuilder: (context) => menuItems.map((item) {
            final isSelected = selectedMenuItem == item;
            return PopupMenuItem<String>(
              value: item,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFEF2F2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.check,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                      ),
                    Text(
                      item,
                      style: isSelected
                          ? AirMenuTextStyle.normal.bold600().withColor(
                              const Color(0xFFEF4444), // Red text for selected
                            )
                          : AirMenuTextStyle.normal.medium500().withColor(
                              const Color(0xFF374151),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white), // White border generally
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedMenuItem ?? 'Select Menu Item',
                  style: AirMenuTextStyle.normal.medium500().withColor(
                    selectedMenuItem != null
                        ? const Color(0xFF111827)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientRow(int index, RecipeIngredient ingredient) {
    bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildCustomDropdown(
                    value: ingredient.name,
                    hint: 'Select Ingredient',
                    items: ingredientOptions,
                    onChanged: (val) => setState(() => ingredient.name = val),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeIngredient(index),
                  icon: const Icon(Icons.close, size: 18),
                  color: const Color(0xFFEF4444),
                  splashRadius: 20,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    alignment: Alignment.center,
                    child: TextFormField(
                      initialValue: ingredient.quantity,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (val) => ingredient.quantity = val,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Qty',
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                      ),
                      style: AirMenuTextStyle.normal.medium500(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCustomDropdown(
                    value: ingredient.unit,
                    hint: 'Unit',
                    items: unitOptions,
                    onChanged: (val) => setState(() => ingredient.unit = val),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Ingredient Dropdown (Expanded)
        Expanded(
          flex: 5,
          child: _buildCustomDropdown(
            value: ingredient.name,
            hint: 'Select Ingredient',
            items: ingredientOptions,
            onChanged: (val) => setState(() => ingredient.name = val),
          ),
        ),
        const SizedBox(width: 12),

        // Quantity Input
        Expanded(
          flex: 2,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            alignment: Alignment.center,
            child: TextFormField(
              initialValue: ingredient.quantity,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (val) => ingredient.quantity = val,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Qty',
                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              ),
              style: AirMenuTextStyle.normal.medium500(),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Unit Dropdown
        Expanded(
          flex: 2,
          child: _buildCustomDropdown(
            value: ingredient.unit,
            hint: 'Unit',
            items: unitOptions,
            onChanged: (val) => setState(() => ingredient.unit = val),
          ),
        ),
        const SizedBox(width: 12),

        // Remove Button
        IconButton(
          onPressed: () => _removeIngredient(index),
          icon: const Icon(Icons.close, size: 18),
          color: const Color(0xFFEF4444),
          splashRadius: 20,
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildCustomDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PopupMenuButton<String>(
          offset: const Offset(0, 48),
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          color: Colors.white,
          onSelected: onChanged,
          itemBuilder: (context) => items.map((item) {
            final isSelected = value == item;
            return PopupMenuItem<String>(
              value: item,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFEF2F2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.check,
                          color: Color(0xFFEF4444),
                          size: 14,
                        ),
                      ),
                    Text(
                      item,
                      style: isSelected
                          ? AirMenuTextStyle.normal.bold600().withColor(
                              const Color(0xFFEF4444),
                            )
                          : AirMenuTextStyle.normal.medium500(),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? hint,
                  style: AirMenuTextStyle.normal.medium500().withColor(
                    value != null
                        ? const Color(0xFF111827)
                        : const Color(0xFF9CA3AF),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF9CA3AF),
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
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
                onPressed: () {
                  Navigator.pop(context);
                },
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
              onPressed: () {
                // TODO: Save mapping
                Navigator.pop(context);
              },
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
  String? name;
  String? quantity;
  String? unit;

  RecipeIngredient({this.name, this.quantity = '1', this.unit = 'Unit'});
}
