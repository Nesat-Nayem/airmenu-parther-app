import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:airmenuai_partner_app/features/menu/presentation/widgets/menu_widgets.dart';
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
  @override
  void initState() {
    super.initState();
    _fetchVendorHotel();
  }

  Future<void> _fetchVendorHotel() async {
    if (!mounted) return;
    context.read<MenuCubit>().setLoading();
    try {
      final apiService = locator<ApiService>();
      final response = await apiService.invoke(
        urlPath: ApiEndpoints.vendorBranches,
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (!mounted) return;

      if (response is DataSuccess) {
        final data = response.data;
        List<dynamic>? list;
        if (data is Map<String, dynamic>) {
          list = data['data'] as List<dynamic>?;
        } else if (data is List) {
          list = data;
        }

        if (list != null && list.isNotEmpty) {
          final hotel = list.first as Map<String, dynamic>;
          final hotelId = (hotel['_id'] ?? hotel['id'])?.toString() ?? '';
          if (hotelId.isNotEmpty) {
            if (!mounted) return;
            context.read<MenuCubit>().setHotelLoaded(hotelId);
            context.read<MenuBloc>().add(LoadMenuCategories(hotelId));
            return;
          }
        }
        context.read<MenuCubit>().setHotelError('No restaurant found for your account.');
      } else {
        context.read<MenuCubit>().setHotelError('Failed to load restaurant data.');
      }
    } catch (e) {
      if (!mounted) return;
      context.read<MenuCubit>().setHotelError('Error: $e');
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
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
          if (uiState.isLoadingHotel) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(width: 280, child: VendorCategorySidebarSkeleton()),
                  Expanded(child: VendorMenuListSkeleton()),
                ],
              ),
            );
          }

          if (uiState.hotelError != null) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(uiState.hotelError!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchVendorHotel,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (uiState.hotelId == null) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(width: 280, child: VendorCategorySidebarSkeleton()),
                  Expanded(child: VendorMenuListSkeleton()),
                ],
              ),
            );
          }

          final isMobile = MediaQuery.of(context).size.width < 768;
          return Scaffold(
            backgroundColor: Colors.white,
            body: isMobile
                ? _buildMobileLayout(uiState.hotelId!)
                : _buildDesktopLayout(uiState.hotelId!),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(String hotelId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 280, child: VendorCategorySidebar(hotelId: hotelId)),
        Expanded(
          child: Container(
            color: const Color(0xFFFAFAFA),
            child: Column(
              children: [
                VendorMenuHeader(hotelId: hotelId),
                Expanded(
                  child: BlocBuilder<MenuBloc, admin_menu_state.MenuState>(
                    builder: (context, menuState) {
                      if (menuState is admin_menu_state.MenuLoading) {
                        return BlocBuilder<MenuCubit, MenuState>(
                          builder: (context, uiState) => uiState.viewMode == MenuViewMode.grid
                              ? const VendorMenuGridSkeleton()
                              : const VendorMenuListSkeleton(),
                        );
                      }
                      if (menuState is admin_menu_state.MenuError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                              const SizedBox(height: 12),
                              Text(menuState.message),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => context.read<MenuBloc>().add(LoadMenuCategories(hotelId)),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }
                      if (menuState is admin_menu_state.MenuLoaded) {
                        return _buildMenuContent(context, menuState, hotelId);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuContent(BuildContext context, admin_menu_state.MenuLoaded state, String hotelId) {
    return BlocBuilder<MenuCubit, MenuState>(
      builder: (context, uiState) {
        // Gather all items across all categories filtered by selected category
        List<FoodItem> items = [];
        if (uiState.selectedCategoryId == 'all') {
          for (final cat in state.categories) {
            items.addAll(cat.items);
          }
        } else {
          final cat = state.categories.where((c) => c.name == uiState.selectedCategoryId).firstOrNull;
          if (cat != null) items = cat.items;
        }

        // Apply search filter
        if (uiState.searchQuery.isNotEmpty) {
          final q = uiState.searchQuery.toLowerCase();
          items = items.where((i) => i.title.toLowerCase().contains(q) || i.description.toLowerCase().contains(q)).toList();
        }

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  uiState.searchQuery.isNotEmpty ? 'No items match your search.' : 'No menu items yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                ),
                if (uiState.searchQuery.isEmpty && state.categories.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => MenuTabModals.showAddItemModal(context, hotelId, state, state.categories.first),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Item'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC52031), foregroundColor: Colors.white),
                  ),
                ],
              ],
            ),
          );
        }

        if (uiState.viewMode == MenuViewMode.grid) {
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final cat = state.categories.firstWhere(
                (c) => c.items.any((i) => i.id == item.id),
                orElse: () => state.categories.first,
              );
              return VendorMenuItemCard(item: item, hotelId: hotelId, state: state, category: cat);
            },
          );
        } else {
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final cat = state.categories.firstWhere(
                (c) => c.items.any((i) => i.id == item.id),
                orElse: () => state.categories.first,
              );
              return VendorMenuItemListTile(item: item, hotelId: hotelId, state: state, category: cat);
            },
          );
        }
      },
    );
  }

  Widget _buildMobileLayout(String hotelId) {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: Column(
        children: [
          VendorMobileMenuHeader(hotelId: hotelId),
          VendorMobileCategories(hotelId: hotelId),
          Expanded(
            child: BlocBuilder<MenuBloc, admin_menu_state.MenuState>(
              builder: (context, menuState) {
                if (menuState is admin_menu_state.MenuLoading) {
                  return const VendorMenuListSkeleton();
                }
                if (menuState is admin_menu_state.MenuLoaded) {
                  return BlocBuilder<MenuCubit, MenuState>(
                    builder: (context, uiState) {
                      List<FoodItem> items = [];
                      if (uiState.selectedCategoryId == 'all') {
                        for (final cat in menuState.categories) {
                          items.addAll(cat.items);
                        }
                      } else {
                        final cat = menuState.categories.where((c) => c.name == uiState.selectedCategoryId).firstOrNull;
                        if (cat != null) items = cat.items;
                      }
                      if (uiState.searchQuery.isNotEmpty) {
                        final q = uiState.searchQuery.toLowerCase();
                        items = items.where((i) => i.title.toLowerCase().contains(q)).toList();
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final cat = menuState.categories.firstWhere(
                            (c) => c.items.any((i) => i.id == item.id),
                            orElse: () => menuState.categories.first,
                          );
                          return VendorMobileMenuItemCard(item: item, hotelId: hotelId, state: menuState, category: cat);
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
