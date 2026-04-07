import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/menu/menu_models.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/menu/menu_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/menu/menu_event.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/menu/menu_state.dart';

class MenuTabModals {
  static final ImagePicker _picker = ImagePicker();
  static const _primaryColor = Color(0xFFC52031);
  static const _greenColor = Color(0xFF16A34A);

  // Helper to pick image and return bytes
  static Future<Uint8List?> _pickImageBytes() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        return await image.readAsBytes();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }

  // ==================== ADD CATEGORY MODAL ====================
  static void showAddCategoryModal(BuildContext context, String hotelId) {
    final menuBloc = context.read<MenuBloc>();
    final nameController = TextEditingController();
    Uint8List? imageBytes;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalHeader('Add New Category', Icons.category, _primaryColor, () => Navigator.pop(dialogContext)),
                const SizedBox(height: 24),
                _buildLabel('Category Name'),
                const SizedBox(height: 8),
                _buildTextField(nameController, 'Enter category name', Icons.restaurant_menu),
                const SizedBox(height: 20),
                _buildLabel('Category Image'),
                const SizedBox(height: 8),
                _buildImagePickerWidget(imageBytes, null, () async {
                  final bytes = await _pickImageBytes();
                  if (bytes != null) setDialogState(() => imageBytes = bytes);
                }),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildOutlineButton('Cancel', () => Navigator.pop(dialogContext))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPrimaryButton('Add Category', _primaryColor, () {
                      if (nameController.text.trim().isNotEmpty && imageBytes != null) {
                        menuBloc.add(AddMenuCategoryWithBytes(hotelId: hotelId, name: nameController.text.trim(), imageBytes: imageBytes!));
                        Navigator.pop(dialogContext);
                      }
                    })),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== EDIT CATEGORY MODAL ====================
  static void showEditCategoryModal(BuildContext context, String hotelId, MenuCategory category) {
    final menuBloc = context.read<MenuBloc>();
    final nameController = TextEditingController(text: category.name);
    Uint8List? imageBytes;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalHeader('Edit Category', Icons.edit, Colors.blue, () => Navigator.pop(dialogContext)),
                const SizedBox(height: 24),
                _buildLabel('Category Name'),
                const SizedBox(height: 8),
                _buildTextField(nameController, 'Enter category name', Icons.restaurant_menu),
                const SizedBox(height: 20),
                _buildLabel('Category Image'),
                const SizedBox(height: 8),
                _buildImagePickerWidget(imageBytes, category.image, () async {
                  final bytes = await _pickImageBytes();
                  if (bytes != null) setDialogState(() => imageBytes = bytes);
                }),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildOutlineButton('Cancel', () => Navigator.pop(dialogContext))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPrimaryButton('Update Category', Colors.blue, () {
                      if (nameController.text.trim().isNotEmpty) {
                        menuBloc.add(UpdateMenuCategoryWithBytes(hotelId: hotelId, categoryName: category.name, newName: nameController.text.trim(), imageBytes: imageBytes));
                        Navigator.pop(dialogContext);
                      }
                    })),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== DELETE CATEGORY DIALOG ====================
  static void showDeleteCategoryDialog(BuildContext context, String hotelId, MenuCategory category) {
    final menuBloc = context.read<MenuBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                child: Icon(Icons.delete_forever, color: Colors.red[600], size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Delete Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Are you sure you want to delete "${category.name}"?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('This will also delete all ${category.items.length} food items in this category.', style: TextStyle(color: Colors.orange[700], fontSize: 12))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildOutlineButton('Cancel', () => Navigator.pop(dialogContext))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPrimaryButton('Delete', Colors.red, () {
                    menuBloc.add(DeleteMenuCategory(hotelId: hotelId, categoryName: category.name));
                    Navigator.pop(dialogContext);
                  })),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ADD/EDIT ITEM MODAL ====================
  static void showAddItemModal(BuildContext context, String hotelId, MenuLoaded state, MenuCategory category) {
    _showFoodItemModal(context, hotelId, state, category, null);
  }

  static void showEditItemModal(BuildContext context, String hotelId, MenuLoaded state, MenuCategory category, FoodItem item) {
    _showFoodItemModal(context, hotelId, state, category, item);
  }

  static void _showFoodItemModal(BuildContext context, String hotelId, MenuLoaded state, MenuCategory category, FoodItem? item) {
    final menuBloc = context.read<MenuBloc>();
    final isEditing = item != null;
    
    final titleController = TextEditingController(text: item?.title ?? '');
    final descriptionController = TextEditingController(text: item?.description ?? '');
    final priceController = TextEditingController(text: item != null ? item.price.toString() : '');
    final sortdescController = TextEditingController(text: item?.sortdesc ?? '');
    final offerController = TextEditingController(text: item?.offer ?? '');
    
    Uint8List? imageBytes;
    // For editing, find which category the item belongs to
    MenuCategory selectedCategory = category;
    if (isEditing) {
      final ownerCat = state.categories.where(
        (c) => c.items.any((i) => i.id == item.id),
      ).firstOrNull;
      if (ownerCat != null) selectedCategory = ownerCat;
    }
    List<String> selectedItemTypes = List.from(item?.itemType ?? []);
    List<String> selectedAttributes = List.from(item?.attributes ?? []);
    List<FoodItemOption> options = List.from(item?.options ?? []);
    String selectedStation = item?.station ?? 'main_course';
    int prepTime = item?.basePrepTimeMinutes ?? 15;
    double complexity = item?.complexityFactor ?? 1.0;
    int maxPerSlot = item?.maxPerSlot ?? 10;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 700,
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildModalHeader(isEditing ? 'Edit Food Item' : 'Add Food Item to ${category.name}', Icons.fastfood, _greenColor, () => Navigator.pop(dialogContext)),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Basic Information', Icons.info_outline),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Category *'),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<MenuCategory>(
                                    value: selectedCategory,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.category_outlined, size: 18),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    items: state.categories.map((cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat.name, overflow: TextOverflow.ellipsis),
                                    )).toList(),
                                    onChanged: (cat) {
                                      if (cat != null) setDialogState(() => selectedCategory = cat);
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLabel('Item Title *'),
                                  const SizedBox(height: 6),
                                  _buildTextField(titleController, 'e.g., Margherita Pizza', Icons.title),
                                  const SizedBox(height: 16),
                                  _buildLabel('Description *'),
                                  const SizedBox(height: 6),
                                  _buildTextArea(descriptionController, 'Describe your dish...', 3),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildLabel('Price (₹) *'),
                                            const SizedBox(height: 6),
                                            _buildTextField(priceController, '0.00', Icons.currency_rupee, isNumber: true),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildLabel('Offer'),
                                            const SizedBox(height: 6),
                                            _buildTextField(offerController, 'e.g., 20% Off', Icons.local_offer),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Item Image ${isEditing ? "" : "*"}'),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 180,
                                    child: _buildImagePickerWidget(imageBytes, item?.image, () async {
                                      final bytes = await _pickImageBytes();
                                      if (bytes != null) setDialogState(() => imageBytes = bytes);
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        _buildSectionHeader('Item Type & Attributes', Icons.label_outline),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildChipSelector('Item Type', state.settings.itemTypes, selectedItemTypes, (list) => setDialogState(() => selectedItemTypes = list))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildChipSelector('Attributes', state.settings.attributes, selectedAttributes, (list) => setDialogState(() => selectedAttributes = list))),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        _buildSectionHeader('Price Options', Icons.price_change_outlined),
                        const SizedBox(height: 12),
                        _buildOptionsEditor(options, (newOptions) => setDialogState(() => options = newOptions)),
                        
                        const SizedBox(height: 24),
                        _buildSectionHeader('Kitchen Settings', Icons.kitchen),
                        const SizedBox(height: 12),
                        _buildKitchenSettings(selectedStation, prepTime, complexity, maxPerSlot, (s, p, c, m) => setDialogState(() {
                          selectedStation = s;
                          prepTime = p;
                          complexity = c;
                          maxPerSlot = m;
                        })),
                        
                        const SizedBox(height: 16),
                        _buildLabel('Short Description'),
                        const SizedBox(height: 6),
                        _buildTextField(sortdescController, 'Brief description for sorting', Icons.short_text),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildOutlineButton('Cancel', () => Navigator.pop(dialogContext))),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: _buildPrimaryButton(isEditing ? 'Update Item' : 'Add Item', _greenColor, () {
                      final title = titleController.text.trim();
                      final description = descriptionController.text.trim();
                      final price = double.tryParse(priceController.text) ?? 0;
                      
                      if (title.isEmpty || description.isEmpty || price <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.red));
                        return;
                      }
                      if (!isEditing && imageBytes == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image'), backgroundColor: Colors.red));
                        return;
                      }

                      if (isEditing) {
                        menuBloc.add(UpdateFoodItemWithBytes(
                          hotelId: hotelId, foodId: item.id, title: title, description: description, price: price,
                          imageBytes: imageBytes, itemType: selectedItemTypes, attributes: selectedAttributes,
                          options: options.isNotEmpty ? options : null,
                          sortdesc: sortdescController.text.trim().isNotEmpty ? sortdescController.text.trim() : null,
                          offer: offerController.text.trim().isNotEmpty ? offerController.text.trim() : null,
                          station: selectedStation, basePrepTimeMinutes: prepTime, complexityFactor: complexity, maxPerSlot: maxPerSlot,
                        ));
                      } else {
                        menuBloc.add(AddFoodItemWithBytes(
                          hotelId: hotelId, categoryName: selectedCategory.name, title: title, description: description, price: price,
                          imageBytes: imageBytes!, itemType: selectedItemTypes, attributes: selectedAttributes,
                          options: options.isNotEmpty ? options : null,
                          sortdesc: sortdescController.text.trim().isNotEmpty ? sortdescController.text.trim() : null,
                          offer: offerController.text.trim().isNotEmpty ? offerController.text.trim() : null,
                          station: selectedStation, basePrepTimeMinutes: prepTime, complexityFactor: complexity, maxPerSlot: maxPerSlot,
                        ));
                      }
                      Navigator.pop(dialogContext);
                    })),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== DELETE ITEM DIALOG ====================
  static void showDeleteItemDialog(BuildContext context, String hotelId, FoodItem item) {
    final menuBloc = context.read<MenuBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                child: Icon(Icons.delete_forever, color: Colors.red[600], size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Delete Food Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Are you sure you want to delete "${item.title}"?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildOutlineButton('Cancel', () => Navigator.pop(dialogContext))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPrimaryButton('Delete', Colors.red, () {
                    menuBloc.add(DeleteFoodItem(hotelId: hotelId, foodId: item.id));
                    Navigator.pop(dialogContext);
                  })),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== MENU SETTINGS MODAL ====================
  static void showSettingsModal(BuildContext context, String hotelId, MenuLoaded state) {
    final menuBloc = context.read<MenuBloc>();
    List<String> itemTypes = List.from(state.settings.itemTypes);
    List<String> attributes = List.from(state.settings.attributes);
    final newItemTypeController = TextEditingController();
    final newAttributeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalHeader('Menu Settings', Icons.settings, Colors.indigo, () => Navigator.pop(dialogContext)),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSettingsColumn('Item Types', 'Veg, Non-Veg, etc.', itemTypes, newItemTypeController, (list) => setDialogState(() => itemTypes = list))),
                    const SizedBox(width: 24),
                    Expanded(child: _buildSettingsColumn('Attributes', 'Spicy, Best Seller, etc.', attributes, newAttributeController, (list) => setDialogState(() => attributes = list))),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildOutlineButton('Cancel', () => Navigator.pop(dialogContext)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: _buildPrimaryButton('Save Settings', Colors.indigo, () {
                        menuBloc.add(UpdateMenuSettings(hotelId: hotelId, itemTypes: itemTypes, attributes: attributes));
                        Navigator.pop(dialogContext);
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== AI IMPORT MODAL ====================
  static void showAIImportModal(BuildContext context, String hotelId, MenuLoaded state) {
    final menuBloc = context.read<MenuBloc>();
    Uint8List? fileBytes;
    String? fileBase64;
    String? mimeType;
    String? fileName;
    // selectedItems: catIndex → set of item indices
    Map<int, Set<int>> selectedItems = {};
    ExtractMenuResponse? extractedMenu;
    bool isExtracting = false;
    bool isImporting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => BlocProvider.value(
          value: menuBloc,
          child: BlocListener<MenuBloc, MenuState>(
            listener: (context, blocState) {
              if (blocState is MenuLoaded) {
                if (blocState.extractedMenu != null && extractedMenu == null) {
                  final menu = blocState.extractedMenu!;
                  // Default: all items selected
                  final Map<int, Set<int>> allSelected = {};
                  for (int i = 0; i < menu.categories.length; i++) {
                    allSelected[i] = Set.from(
                      List.generate(menu.categories[i].items.length, (j) => j),
                    );
                  }
                  setDialogState(() {
                    extractedMenu = menu;
                    selectedItems = allSelected;
                    isExtracting = false;
                  });
                }
                if (blocState.successMessage?.contains('imported') == true) {
                  Navigator.pop(dialogContext);
                }
                if (!blocState.isExtractingMenu && isExtracting) {
                  setDialogState(() => isExtracting = false);
                }
                if (!blocState.isImportingMenu && isImporting) {
                  setDialogState(() => isImporting = false);
                }
              }
            },
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 720,
                height: 580,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF4F46E5)]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI Menu Import', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text('Extract menu from image or PDF using AI', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (!isExtracting && !isImporting)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              menuBloc.add(const ClearExtractedMenu());
                              Navigator.pop(dialogContext);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: isExtracting
                          ? _buildExtractingUI()
                          : isImporting
                              ? _buildImportingUI()
                              : extractedMenu != null
                                  ? _buildPreviewUIWithItems(
                                      extractedMenu!,
                                      selectedItems,
                                      setDialogState,
                                    )
                                  : _buildUploadUIWithPdf(
                                      fileBytes,
                                      fileName,
                                      (bytes, base64, mime, name) => setDialogState(() {
                                        fileBytes = bytes;
                                        fileBase64 = base64;
                                        mimeType = mime;
                                        fileName = name;
                                      }),
                                    ),
                    ),
                    const SizedBox(height: 20),
                    if (!isExtracting && !isImporting)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildOutlineButton(extractedMenu != null ? 'Back' : 'Cancel', () {
                            if (extractedMenu != null) {
                              setDialogState(() => extractedMenu = null);
                              menuBloc.add(const ClearExtractedMenu());
                            } else {
                              Navigator.pop(dialogContext);
                            }
                          }),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 220,
                            child: _buildGradientButton(
                              extractedMenu != null
                                  ? 'Import ${_countSelectedItems(selectedItems)} Items'
                                  : 'Extract Menu with AI',
                              extractedMenu != null
                                  ? (_countSelectedItems(selectedItems) == 0
                                      ? null
                                      : () {
                                          // Build categories with only selected items
                                          final filteredCats = <ExtractedCategory>[];
                                          for (int i = 0; i < extractedMenu!.categories.length; i++) {
                                            final sel = selectedItems[i];
                                            if (sel == null || sel.isEmpty) continue;
                                            final cat = extractedMenu!.categories[i];
                                            final filteredItems = cat.items
                                                .asMap()
                                                .entries
                                                .where((e) => sel.contains(e.key))
                                                .map((e) => e.value)
                                                .toList();
                                            if (filteredItems.isNotEmpty) {
                                              filteredCats.add(ExtractedCategory(
                                                name: cat.name,
                                                items: filteredItems,
                                              ));
                                            }
                                          }
                                          setDialogState(() => isImporting = true);
                                          menuBloc.add(ImportExtractedMenu(
                                            hotelId: hotelId,
                                            categories: filteredCats,
                                            selectedItems: selectedItems,
                                          ));
                                        })
                                  : (fileBytes == null
                                      ? null
                                      : () {
                                          if (fileBase64 != null && mimeType != null) {
                                            setDialogState(() => isExtracting = true);
                                            menuBloc.add(ExtractMenuFromImage(
                                              imageBase64: fileBase64!,
                                              mimeType: mimeType!,
                                            ));
                                          }
                                        }),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static int _countSelectedItems(Map<int, Set<int>> selectedItems) {
    return selectedItems.values.fold(0, (sum, s) => sum + s.length);
  }

  // ==================== HELPER WIDGETS ====================
  
  static Widget _buildModalHeader(String title, IconData icon, Color color, VoidCallback onClose) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        IconButton(icon: const Icon(Icons.close), onPressed: onClose),
      ],
    );
  }

  static Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151)));
  }

  static Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
        ],
      ),
    );
  }

  static Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primaryColor, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  static Widget _buildTextArea(TextEditingController controller, String hint, int lines) {
    return TextField(
      controller: controller,
      maxLines: lines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primaryColor, width: 2)),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  // Image picker widget using Image.memory for web compatibility
  static Widget _buildImagePickerWidget(Uint8List? imageBytes, String? networkUrl, VoidCallback onTap) {
    Widget imageWidget;
    if (imageBytes != null) {
      imageWidget = Image.memory(imageBytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    } else if (networkUrl != null && networkUrl.isNotEmpty) {
      imageWidget = Image.network(networkUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (_, __, ___) => _buildImagePlaceholder());
    } else {
      imageWidget = _buildImagePlaceholder();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: imageBytes != null ? _greenColor : Colors.grey[300]!, width: imageBytes != null ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageWidget,
              if (imageBytes != null || (networkUrl != null && networkUrl.isNotEmpty))
                Positioned(
                  bottom: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.edit, color: Colors.white, size: 12), SizedBox(width: 4), Text('Change', style: TextStyle(color: Colors.white, fontSize: 10))],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
          child: Icon(Icons.add_photo_alternate, color: Colors.grey[500], size: 28),
        ),
        const SizedBox(height: 8),
        Text('Click to upload', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
        Text('PNG, JPG, WEBP, AVIF', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
      ],
    );
  }

  static Widget _buildOutlineButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
    );
  }

  static Widget _buildPrimaryButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  static Widget _buildGradientButton(String text, VoidCallback? onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null ? const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF4F46E5)]) : null,
        color: onPressed == null ? Colors.grey[300] : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const Icon(Icons.auto_awesome, size: 18), const SizedBox(width: 8), Text(text, style: const TextStyle(fontWeight: FontWeight.w600))],
        ),
      ),
    );
  }

  static Widget _buildChipSelector(String title, List<String> options, List<String> selected, Function(List<String>) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10), color: Colors.grey[50]),
          child: options.isEmpty
              ? Text('No $title available. Add in Menu Settings.', style: TextStyle(color: Colors.grey[500], fontSize: 12))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: options.map((opt) {
                    final isSelected = selected.contains(opt);
                    return FilterChip(
                      label: Text(opt, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.grey[700])),
                      selected: isSelected,
                      onSelected: (sel) {
                        final newList = List<String>.from(selected);
                        sel ? newList.add(opt) : newList.remove(opt);
                        onChanged(newList);
                      },
                      selectedColor: _greenColor,
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: isSelected ? _greenColor : Colors.grey[300]!),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  static Widget _buildOptionsEditor(List<FoodItemOption> options, Function(List<FoodItemOption>) onChanged) {
    final labelController = TextEditingController();
    final priceController = TextEditingController();
    
    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(flex: 2, child: _buildTextField(labelController, 'Option name (e.g., Half)', Icons.label_outline)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(priceController, 'Price', Icons.currency_rupee, isNumber: true)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle, color: _greenColor),
                onPressed: () {
                  if (labelController.text.trim().isNotEmpty && priceController.text.isNotEmpty) {
                    final newOptions = List<FoodItemOption>.from(options)
                      ..add(FoodItemOption(label: labelController.text.trim(), price: double.tryParse(priceController.text) ?? 0));
                    onChanged(newOptions);
                    labelController.clear();
                    priceController.clear();
                  }
                },
              ),
            ],
          ),
          if (options.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((opt) => Chip(
                label: Text('${opt.label}: ₹${opt.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => onChanged(options.where((o) => o != opt).toList()),
                backgroundColor: Colors.blue[50],
                side: BorderSide(color: Colors.blue[200]!),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildKitchenSettings(String station, int prepTime, double complexity, int maxPerSlot, Function(String, int, double, int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange[50]!, Colors.amber[50]!]),
        border: Border.all(color: Colors.orange[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Kitchen Station'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: station,
                      decoration: InputDecoration(
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: KitchenStation.defaultStations.map((s) => DropdownMenuItem(value: s.code, child: Text(s.name, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => onChanged(v ?? station, prepTime, complexity, maxPerSlot),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Complexity'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<double>(
                      value: complexity,
                      decoration: InputDecoration(
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: ComplexityOption.options.map((o) => DropdownMenuItem(value: o.value, child: Text(o.label, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => onChanged(station, prepTime, v ?? complexity, maxPerSlot),
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

  static Widget _buildSettingsColumn(String title, String hint, List<String> items, TextEditingController controller, Function(List<String>) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)), child: Text('${items.length}', style: const TextStyle(fontSize: 12))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true, fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final val = controller.text.trim();
                if (val.isNotEmpty && !items.contains(val)) {
                  onChanged([...items, val]);
                  controller.clear();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
          child: items.isEmpty
              ? Center(child: Text('No $title added yet', style: TextStyle(color: Colors.grey[500])))
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(items[i], style: const TextStyle(fontSize: 13)),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: Colors.red[400], size: 20),
                      onPressed: () => onChanged(items.where((e) => e != items[i]).toList()),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ==================== AI IMPORT UI BUILDERS ====================

  /// Upload UI supporting both image and PDF
  static Widget _buildUploadUIWithPdf(
    Uint8List? fileBytes,
    String? fileName,
    Function(Uint8List, String, String, String) onFileSelected,
  ) {
    final isPdf = fileName?.toLowerCase().endsWith('.pdf') == true;
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif', 'pdf'],
                  withData: true,
                );
                if (result != null && result.files.isNotEmpty) {
                  final file = result.files.first;
                  final bytes = file.bytes;
                  if (bytes != null) {
                    final ext = (file.extension ?? 'jpg').toLowerCase();
                    String mime = 'image/jpeg';
                    if (ext == 'png') mime = 'image/png';
                    else if (ext == 'webp') mime = 'image/webp';
                    else if (ext == 'gif') mime = 'image/gif';
                    else if (ext == 'pdf') mime = 'application/pdf';
                    onFileSelected(bytes, base64Encode(bytes), mime, file.name);
                  }
                }
              } catch (e) {
                debugPrint('File pick error: $e');
              }
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: fileBytes != null ? _greenColor : Colors.grey[300]!,
                  width: 2,
                  style: fileBytes != null ? BorderStyle.solid : BorderStyle.none,
                ),
                borderRadius: BorderRadius.circular(16),
                color: fileBytes != null ? _greenColor.withValues(alpha: 0.05) : Colors.grey[50],
              ),
              child: fileBytes != null
                  ? isPdf
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                              child: Icon(Icons.picture_as_pdf, color: Colors.red[600], size: 48),
                            ),
                            const SizedBox(height: 12),
                            Text(fileName ?? 'menu.pdf',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('${(fileBytes.length / 1024).toStringAsFixed(1)} KB',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.check_circle, color: Colors.green, size: 16),
                              label: const Text('PDF ready for extraction',
                                  style: TextStyle(color: Colors.green, fontSize: 12)),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(fileBytes, fit: BoxFit.contain),
                        )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF4F46E5)]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_photo_alternate, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text('Drop your menu card here', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('or click to browse', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text('Supports: JPG, PNG, WEBP, PDF', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo[50]!, Colors.purple[50]!]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.indigo[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How AI Menu Import Works', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo[700])),
                    const SizedBox(height: 4),
                    Text(
                      '1. Upload your menu card photo or PDF\n2. AI extracts categories, items & prices\n3. Select exactly which items to import',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Preview UI with per-item checkbox selection
  static Widget _buildPreviewUIWithItems(
    ExtractMenuResponse extractedMenu,
    Map<int, Set<int>> selectedItems,
    StateSetter setDialogState,
  ) {
    final totalSelected = selectedItems.values.fold(0, (s, v) => s + v.length);
    final totalItems = extractedMenu.categories.fold(0, (s, c) => s + c.items.length);

    return Column(
      children: [
        // Summary bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.green[50]!, Colors.teal[50]!]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Extraction Complete!',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
                    Text('$totalSelected / $totalItems items selected across ${extractedMenu.categories.length} categories',
                        style: TextStyle(color: Colors.green[600], fontSize: 12)),
                  ],
                ),
              ),
              // Select all / deselect all
              TextButton.icon(
                onPressed: () => setDialogState(() {
                  if (totalSelected == totalItems) {
                    // deselect all
                    for (final k in selectedItems.keys) selectedItems[k]!.clear();
                  } else {
                    // select all
                    for (int i = 0; i < extractedMenu.categories.length; i++) {
                      selectedItems[i] = Set.from(
                        List.generate(extractedMenu.categories[i].items.length, (j) => j),
                      );
                    }
                  }
                }),
                icon: Icon(totalSelected == totalItems ? Icons.deselect : Icons.select_all, size: 16),
                label: Text(totalSelected == totalItems ? 'Deselect All' : 'Select All',
                    style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: extractedMenu.categories.length,
            itemBuilder: (_, catIndex) {
              final category = extractedMenu.categories[catIndex];
              final catSelected = selectedItems[catIndex] ?? {};
              final allCatSelected = catSelected.length == category.items.length;
              final someCatSelected = catSelected.isNotEmpty && !allCatSelected;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: catSelected.isNotEmpty ? const Color(0xFF9333EA) : Colors.grey[300]!,
                    width: catSelected.isNotEmpty ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: catSelected.isNotEmpty ? const Color(0xFFF5F3FF) : Colors.white,
                ),
                child: Column(
                  children: [
                    // Category header row
                    InkWell(
                      onTap: () => setDialogState(() {
                        if (allCatSelected) {
                          selectedItems[catIndex] = {};
                        } else {
                          selectedItems[catIndex] = Set.from(
                            List.generate(category.items.length, (j) => j),
                          );
                        }
                      }),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            // Category checkbox (tri-state visual)
                            Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: catSelected.isNotEmpty ? const Color(0xFF9333EA) : Colors.grey[400]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(5),
                                color: allCatSelected ? const Color(0xFF9333EA) : Colors.white,
                              ),
                              child: allCatSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                                  : someCatSelected
                                      ? Container(
                                          margin: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF9333EA),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        )
                                      : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(category.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('${catSelected.length}/${category.items.length} items selected',
                                      style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                ],
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down, color: Colors.grey[400], size: 20),
                          ],
                        ),
                      ),
                    ),
                    // Items list
                    Container(
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey[200]!)),
                      ),
                      child: Column(
                        children: category.items.asMap().entries.map((entry) {
                          final itemIndex = entry.key;
                          final item = entry.value;
                          final isItemSelected = catSelected.contains(itemIndex);

                          return InkWell(
                            onTap: () => setDialogState(() {
                              final set = selectedItems[catIndex] ?? {};
                              if (isItemSelected) {
                                set.remove(itemIndex);
                              } else {
                                set.add(itemIndex);
                              }
                              selectedItems[catIndex] = set;
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              child: Row(
                                children: [
                                  // Item checkbox
                                  Container(
                                    width: 18, height: 18,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isItemSelected ? const Color(0xFF9333EA) : Colors.grey[400]!,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      color: isItemSelected ? const Color(0xFF9333EA) : Colors.white,
                                    ),
                                    child: isItemSelected
                                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  // Veg/NonVeg dot
                                  Container(
                                    width: 10, height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: item.isVeg
                                          ? Colors.green
                                          : item.isNonVeg
                                              ? Colors.red
                                              : Colors.amber,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isItemSelected ? const Color(0xFF1F2937) : Colors.grey[600],
                                        fontWeight: isItemSelected ? FontWeight.w500 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (item.spicy)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: Text('🌶️', style: TextStyle(fontSize: 12)),
                                    ),
                                  Text(
                                    item.price > 0 ? '₹${item.price.toStringAsFixed(0)}' : '—',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isItemSelected ? const Color(0xFF9333EA) : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static Widget _buildExtractingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.purple[400]!, Colors.indigo[600]!]))),
              const SizedBox(width: 80, height: 80, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
              const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Analyzing Menu Image...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Our AI is extracting categories, items, and prices', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          SizedBox(width: 200, child: LinearProgressIndicator(backgroundColor: Colors.grey[200], color: Colors.purple)),
        ],
      ),
    );
  }

  static Widget _buildImportingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.green[400]!, Colors.teal[600]!])),
            child: const Icon(Icons.cloud_upload, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 24),
          const Text('Importing Menu...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Adding categories and items to your menu', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          SizedBox(width: 200, child: LinearProgressIndicator(backgroundColor: Colors.grey[200], color: Colors.green)),
        ],
      ),
    );
  }
}
