import 'package:airmenuai_partner_app/features/category/domain/entities/category_entity.dart';
import 'package:airmenuai_partner_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:airmenuai_partner_app/features/category/presentation/bloc/category_event.dart';
import 'package:airmenuai_partner_app/features/category/presentation/widgets/category_card.dart';
import 'package:airmenuai_partner_app/features/category/presentation/widgets/category_dialog.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryDesktopView extends StatefulWidget {
  final List<CategoryEntity> categories;

  const CategoryDesktopView({super.key, required this.categories});

  @override
  State<CategoryDesktopView> createState() => _CategoryDesktopViewState();
}

class _CategoryDesktopViewState extends State<CategoryDesktopView> {
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
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                'Categories',
                style: AirMenuTextStyle.headingH2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Search Bar
              SizedBox(
                width: 300,
                child: TextField(
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
                      borderSide: const BorderSide(
                        color: AirMenuColors.primary,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Add Category Button
              ElevatedButton.icon(
                onPressed: () => _showCategoryDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AirMenuColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Grid
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
              : GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: widget.categories.length,
                  itemBuilder: (context, index) {
                    return CategoryCard(category: widget.categories[index]);
                  },
                ),
        ),
      ],
    );
  }
}
