import 'package:airmenuai_partner_app/features/category/domain/entities/category_entity.dart';
import 'package:airmenuai_partner_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:airmenuai_partner_app/features/category/presentation/widgets/category_dialog.dart';
import 'package:airmenuai_partner_app/features/category/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final bool isMobile;

  const CategoryCard({
    super.key,
    required this.category,
    this.isMobile = false,
  });

  void _showCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CategoryBloc>(),
        child: CategoryDialog(category: category),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CategoryBloc>(),
        child: DeleteConfirmationDialog(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      // Horizontal layout for mobile
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: category.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: category.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: AirMenuColors.secondary.shade9,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: AirMenuColors.secondary.shade9,
                          child: const Icon(Icons.error),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: AirMenuColors.secondary.shade9,
                        child: const Icon(Icons.image, size: 40),
                      ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: AirMenuTextStyle.normal.bold700(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.createdAt,
                      style: AirMenuTextStyle.caption.copyWith(
                        color: AirMenuColors.secondary.shade7,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showCategoryDialog(context),
                    icon: const Icon(Icons.edit_outlined),
                    color: AirMenuColors.primary,
                    iconSize: 20,
                  ),
                  IconButton(
                    onPressed: () => _showDeleteDialog(context),
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Vertical layout for tablet
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: category.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: category.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AirMenuColors.secondary.shade9,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AirMenuColors.secondary.shade9,
                        child: const Icon(Icons.error, size: 48),
                      ),
                    )
                  : Container(
                      color: AirMenuColors.secondary.shade9,
                      child: const Icon(Icons.image, size: 64),
                    ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: AirMenuTextStyle.normal.bold700(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  category.createdAt,
                  style: AirMenuTextStyle.caption.copyWith(
                    color: AirMenuColors.secondary.shade7,
                  ),
                ),
                const SizedBox(height: 12),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showCategoryDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AirMenuColors.primary,
                          side: const BorderSide(color: AirMenuColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showDeleteDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
