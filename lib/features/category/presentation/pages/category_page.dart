import 'package:airmenuai_partner_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:airmenuai_partner_app/features/category/presentation/bloc/category_event.dart';
import 'package:airmenuai_partner_app/features/category/presentation/bloc/category_state.dart';
import 'package:airmenuai_partner_app/features/category/presentation/views/category_desktop_view.dart';
import 'package:airmenuai_partner_app/features/category/presentation/views/category_mobile_view.dart';
import 'package:airmenuai_partner_app/features/category/presentation/views/category_tablet_view.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<CategoryBloc>()..add(LoadCategoriesEvent()),
      child: const _CategoryView(),
    );
  }
}

class _CategoryView extends StatelessWidget {
  const _CategoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AirMenuColors.primary.shade1,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Categories',
                    style: AirMenuTextStyle.headingH3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AirMenuTextStyle.normal.copyWith(
                      color: AirMenuColors.secondary.shade7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CategoryBloc>().add(LoadCategoriesEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AirMenuColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CategoryEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: AirMenuColors.secondary.shade7,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Categories Yet',
                    style: AirMenuTextStyle.headingH3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AirMenuTextStyle.normal.copyWith(
                      color: AirMenuColors.secondary.shade7,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is CategoryLoaded) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (Responsive.isMobile(context)) {
                  return CategoryMobileView(
                    categories: state.filteredCategories,
                  );
                } else if (Responsive.isTablet(context)) {
                  return CategoryTabletView(
                    categories: state.filteredCategories,
                  );
                } else {
                  return CategoryDesktopView(
                    categories: state.filteredCategories,
                  );
                }
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
