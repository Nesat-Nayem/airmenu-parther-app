import 'package:airmenuai_partner_app/features/menu/presentation/bloc/menu_cubit.dart';
import 'package:airmenuai_partner_app/features/menu/presentation/widgets/menu_widgets.dart';
import 'package:airmenuai_partner_app/features/menu/presentation/widgets/mobile_menu_widgets.dart';
import 'package:airmenuai_partner_app/features/menu/presentation/models/menu_item_mock.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MenuCubit(),
      child: const _MenuPageView(),
    );
  }
}

class _MenuPageView extends StatelessWidget {
  const _MenuPageView();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Sidebar
        const SizedBox(width: 280, child: CategorySidebar()),

        // Main Content
        Expanded(
          child: Container(
            color: const Color(0xFFFAFAFA), // Light gray background
            child: Column(
              children: [
                const MenuHeader(),
                Expanded(
                  child: BlocBuilder<MenuCubit, MenuState>(
                    builder: (context, state) {
                      // Get filtered items based on selected category
                      final items = MockMenuData.getItemsByCategory(
                        state.selectedCategoryId,
                      );

                      if (state.viewMode == MenuViewMode.grid) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                childAspectRatio: 1.6,
                              ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return MenuItemCard(item: items[index]);
                          },
                        );
                      } else {
                        return ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return MenuItemListTile(item: items[index]);
                          },
                        );
                      }
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

  Widget _buildMobileLayout() {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: Column(
        children: [
          const MobileMenuHeader(),
          const MobileCategories(),
          Expanded(
            child: BlocBuilder<MenuCubit, MenuState>(
              builder: (context, state) {
                // Get filtered items based on selected category
                final items = MockMenuData.getItemsByCategory(
                  state.selectedCategoryId,
                );

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return MobileMenuItemCard(item: items[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
