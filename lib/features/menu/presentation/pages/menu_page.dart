import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/local_storage.dart';
import 'package:airmenuai_partner_app/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/menu/menu_models.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/menu_repository.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/menu/menu_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/menu/menu_event.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/menu/menu_state.dart'
    as admin_menu_state;
import 'package:airmenuai_partner_app/features/restaurants/presentation/widgets/details/tabs/menu_tab_modals.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MenuCubit()),
        BlocProvider(create: (_) => MenuBloc(locator<MenuRepository>())),
      ],
      child: const _MenuPageView(),
    );
  }
}

class _MenuPageView extends StatefulWidget {
  const _MenuPageView();

  @override
  State<_MenuPageView> createState() => _MenuPageViewState();
}

class _MenuPageViewState extends State<_MenuPageView> {
  static const _primaryColor = Color(0xFFC52031);
  static const _greenColor = Color(0xFF16A34A);

  final Set<String> _expandedCategories = {};
  bool _hasKitchenStations = false;

  @override
  void initState() {
    super.initState();
    _fetchVendorHotel();
  }

  Future<void> _fetchVendorHotel() async {
    if (!mounted) return;
    context.read<MenuCubit>().setLoading();
    try {
      final hotelId = await locator<LocalStorage>().getString(localStorageKey: 'hotelId');
      if (!mounted) return;
      if (hotelId != null && hotelId.isNotEmpty) {
        context.read<MenuCubit>().setHotelLoaded(hotelId);
        context.read<MenuBloc>().add(LoadMenuCategories(hotelId));
        await _checkKitchenStations(hotelId);
      } else {
        context.read<MenuCubit>().setHotelError('No restaurant found for your account.');
      }
    } catch (e) {
      if (!mounted) return;
      context.read<MenuCubit>().setHotelError('Error: $e');
    }
  }

  Future<void> _checkKitchenStations(String hotelId) async {
    if (!mounted) return;
    try {
      final response = await locator<ApiService>().invoke(
        urlPath: ApiEndpoints.kitchenStations(hotelId),
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );
      if (!mounted) return;
      if (response is DataSuccess && response.data['success'] == true) {
        final stations = response.data['data'] as List<dynamic>? ?? [];
        setState(() => _hasKitchenStations = stations.isNotEmpty);
      }
    } catch (_) {}
  }

  void _showToast(String message, {bool isError = false}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => _SweetAlert(
        message: message,
        isError: isError,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MenuBloc, admin_menu_state.MenuState>(
      listener: (context, state) {
        if (state is admin_menu_state.MenuLoaded) {
          if (state.errorMessage != null) _showToast(state.errorMessage!, isError: true);
          if (state.successMessage != null) _showToast(state.successMessage!);
        }
      },
      child: BlocBuilder<MenuCubit, MenuState>(
        builder: (context, uiState) {
          if (uiState.isLoadingHotel || uiState.hotelId == null) {
            if (uiState.hotelError != null) {
              return _buildErrorState(uiState.hotelError!);
            }
            return _buildShimmerLoading();
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: BlocBuilder<MenuBloc, admin_menu_state.MenuState>(
              builder: (context, menuState) {
                if (menuState is admin_menu_state.MenuLoading) {
                  return _buildShimmerLoading();
                }
                if (menuState is admin_menu_state.MenuError) {
                  return _buildErrorState(menuState.message, hotelId: uiState.hotelId);
                }
                if (menuState is admin_menu_state.MenuLoaded) {
                  return _buildMenuPage(context, menuState, uiState.hotelId!);
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  // ─── Shimmer loading matching admin menu_tab ────────────────────────────────
  Widget _buildShimmerLoading() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 28, width: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                  Row(children: List.generate(3, (_) => Container(height: 44, width: 120, margin: const EdgeInsets.only(left: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))))),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.85, crossAxisSpacing: 20, mainAxisSpacing: 20),
                  itemCount: 6,
                  itemBuilder: (_, __) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Error state matching admin menu_tab ────────────────────────────────────
  Widget _buildErrorState(String message, {String? hotelId}) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
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
                onPressed: () {
                  if (hotelId != null) {
                    context.read<MenuBloc>().add(LoadMenuCategories(hotelId));
                  } else {
                    _fetchVendorHotel();
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Main menu page layout ─────────────────────────────────────────────────
  Widget _buildMenuPage(BuildContext context, admin_menu_state.MenuLoaded state, String hotelId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, state, hotelId),
          const SizedBox(height: 20),
          state.categories.isEmpty ? _buildEmptyState(hotelId) : _buildCategoriesGrid(context, state, hotelId),
        ],
      ),
    );
  }

  // ─── Header: Menu Settings | AI Import | Add Category ──────────────────────
  Widget _buildHeader(BuildContext context, admin_menu_state.MenuLoaded state, String hotelId) {
    const kitchenSetupMessage = 'Set up kitchen stations first (Kitchen tab) before adding menu categories.';
    return Row(
      children: [
        const Text('Menu Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        const Spacer(),
        _buildHeaderButton('Menu Settings', Icons.settings_outlined, Colors.white, Colors.grey[700]!, () => MenuTabModals.showSettingsModal(context, hotelId, state), hasBorder: true),
        const SizedBox(width: 10),
        Tooltip(
          message: _hasKitchenStations ? '' : kitchenSetupMessage,
          child: _buildGradientButton(
            'AI Import Menu',
            Icons.auto_awesome,
            _hasKitchenStations ? () => MenuTabModals.showAIImportModal(context, hotelId, state) : () {},
            disabled: !_hasKitchenStations,
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: _hasKitchenStations ? '' : kitchenSetupMessage,
          child: _buildHeaderButton(
            'Add Category',
            Icons.add,
            _primaryColor,
            Colors.white,
            (!_hasKitchenStations || state.isAddingCategory) ? null : () => MenuTabModals.showAddCategoryModal(context, hotelId),
            isLoading: state.isAddingCategory,
          ),
        ),
      ],
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

  Widget _buildGradientButton(String label, IconData icon, VoidCallback onPressed, {bool disabled = false}) {
    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF4F46E5)]),
          borderRadius: BorderRadius.circular(8),
          boxShadow: disabled ? [] : [BoxShadow(color: const Color(0xFF9333EA).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : onPressed,
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
      ),
    );
  }

  // ─── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(String hotelId) {
    final kitchenReady = _hasKitchenStations;
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
              decoration: BoxDecoration(
                color: kitchenReady ? _primaryColor.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                kitchenReady ? Icons.restaurant_menu : Icons.kitchen_outlined,
                size: 48,
                color: kitchenReady ? _primaryColor : Colors.orange[700],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              kitchenReady ? 'No Menu Categories Yet' : 'Kitchen Setup Required',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            Text(
              kitchenReady
                  ? 'Add your first category to start building your menu'
                  : 'Please set up your kitchen stations first before adding menu categories.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            if (kitchenReady)
              ElevatedButton.icon(
                onPressed: () => MenuTabModals.showAddCategoryModal(context, hotelId),
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
                style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              )
            else
              Tooltip(
                message: 'Go to Kitchen tab → Stations to set up your kitchen',
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.kitchen_outlined),
                  label: const Text('Set Up Kitchen First'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[100],
                    foregroundColor: Colors.orange[800],
                    disabledBackgroundColor: Colors.orange[100],
                    disabledForegroundColor: Colors.orange[800],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Category Grid (matching admin menu_tab) ──────────────────────────────
  Widget _buildCategoriesGrid(BuildContext context, admin_menu_state.MenuLoaded state, String hotelId) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 500 ? 1 : (constraints.maxWidth < 850 ? 2 : 3);
        double cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 20) / crossAxisCount;

        List<Widget> categoryWidgets = [];

        for (var category in state.categories) {
          categoryWidgets.add(
            SizedBox(
              width: cardWidth,
              child: _buildCategoryCard(context, state, category, hotelId),
            ),
          );
        }

        if (state.isAddingCategory) {
          categoryWidgets.add(
            SizedBox(
              width: cardWidth,
              child: _buildCategorySkeletonCard(),
            ),
          );
        }

        List<Widget> rows = [];
        for (int i = 0; i < categoryWidgets.length; i += crossAxisCount) {
          List<Widget> rowChildren = [];
          for (int j = i; j < i + crossAxisCount && j < categoryWidgets.length; j++) {
            rowChildren.add(categoryWidgets[j]);
            if (j < i + crossAxisCount - 1 && j < categoryWidgets.length - 1) {
              rowChildren.add(const SizedBox(width: 20));
            }
          }
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

        return Column(children: rows);
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

  // ─── Category Card (matching admin menu_tab) ──────────────────────────────
  Widget _buildCategoryCard(BuildContext context, admin_menu_state.MenuLoaded state, MenuCategory category, String hotelId) {
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
                    _actionButton('Edit', _primaryColor, isDeleting ? null : () => MenuTabModals.showEditCategoryModal(context, hotelId, category)),
                    const SizedBox(width: 6),
                    _actionButton('Delete', _primaryColor, isDeleting ? null : () => MenuTabModals.showDeleteCategoryDialog(context, hotelId, category)),
                    const SizedBox(width: 6),
                    _actionButton('Add Item', _primaryColor, isDeleting || isAddingItemHere ? null : () => MenuTabModals.showAddItemModal(context, hotelId, state, category)),
                  ],
                ),
              ),
              // Category Image
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
                      ...itemsToShow.map((item) => _buildFoodItemRow(context, state, category, item, hotelId)),
                      if (isAddingItemHere) _buildItemSkeletonRow(),
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
                                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18, color: _primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  isExpanded ? 'Show less' : 'View +$remainingCount more items',
                                  style: TextStyle(color: _primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
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
                    SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3, color: _primaryColor)),
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

  // ─── Food Item Row (matching admin menu_tab) ──────────────────────────────
  Widget _buildFoodItemRow(BuildContext context, admin_menu_state.MenuLoaded state, MenuCategory category, FoodItem item, String hotelId) {
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.image != null && item.image!.isNotEmpty
                ? Image.network(item.image!, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholderImage())
                : _placeholderImage(),
          ),
          const SizedBox(width: 12),
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
          _itemActionButton(Icons.edit_outlined, Colors.blue, () => MenuTabModals.showEditItemModal(context, hotelId, state, category, item)),
          const SizedBox(width: 6),
          _itemActionButton(Icons.delete_outline, _primaryColor, isDeleting ? null : () => MenuTabModals.showDeleteItemDialog(context, hotelId, item), isLoading: isDeleting),
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
}

class _SweetAlert extends StatefulWidget {
  final String message;
  final bool isError;

  const _SweetAlert({required this.message, required this.isError});

  @override
  State<_SweetAlert> createState() => _SweetAlertState();
}

class _SweetAlertState extends State<_SweetAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.6, end: 1.0));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse(from: 1.0);
    if (mounted) Navigator.of(context, rootNavigator: true).maybePop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.isError;
    final accentColor = isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final bgIcon = isError ? Icons.cancel_rounded : Icons.check_circle_rounded;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Icon(bgIcon, color: Colors.white, size: 36),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                    child: Column(
                      children: [
                        Text(
                          isError ? 'Oops!' : 'Success!',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _dismiss,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'OK',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
