import 'package:airmenuai_partner_app/features/category/domain/entities/category_entity.dart';
import 'package:airmenuai_partner_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:airmenuai_partner_app/features/category/presentation/bloc/category_event.dart';
import 'package:airmenuai_partner_app/features/category/presentation/widgets/category_card.dart';
import 'package:airmenuai_partner_app/features/category/presentation/widgets/category_dialog.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryMobileView extends StatefulWidget {
  final List<CategoryEntity> categories;

  const CategoryMobileView({super.key, required this.categories});

  @override
  State<CategoryMobileView> createState() => _CategoryMobileViewState();
}

class _CategoryMobileViewState extends State<CategoryMobileView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoryDialog({CategoryEntity? category}) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CategoryBloc>(),
        child: CategoryDialog(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Categories',
                    style: AirMenuTextStyle.headingH3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showCategoryDialog(),
                    icon: const Icon(Icons.add_circle),
                    color: AirMenuColors.primary,
                    iconSize: 32,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<CategoryBloc>().add(
                    SearchCategoriesEvent(value),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search Categories',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<CategoryBloc>().add(
                              const SearchCategoriesEvent(''),
                            );
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AirMenuColors.secondary.shade8,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AirMenuColors.secondary.shade8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AirMenuColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: widget.categories.isEmpty
              ? Center(
                  child: Text(
                    'No categories found',
                    style: AirMenuTextStyle.normal.copyWith(
                      color: AirMenuColors.secondary.shade7,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return CategoryCard(
                      category: widget.categories[index],
                      isMobile: true,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
