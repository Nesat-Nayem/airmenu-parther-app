import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class DetailsHeader extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DetailsHeader({
    super.key,
    required this.restaurant,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Section: Name, Cuisines, Location, Buttons
        _buildTopSection(context),
        const SizedBox(height: 20),
        // Hero Image
        _buildHeroImage(context),
      ],
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 700;
        
        if (isSmallScreen) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRestaurantInfo(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          );
        }
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildRestaurantInfo()),
            const SizedBox(width: 16),
            _buildActionButtons(),
          ],
        );
      },
    );
  }

  Widget _buildRestaurantInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Restaurant Name
        Text(
          restaurant.name,
          style: AirMenuTextStyle.headingH2.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        // Cuisines
        Text(
          restaurant.primaryCuisine ?? 'Multi-Cuisine Restaurant',
          style: AirMenuTextStyle.normal.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),
        // Location & Rating Row
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Rating Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    restaurant.rating > 0 ? restaurant.rating.toStringAsFixed(1) : '5.0',
                    style: AirMenuTextStyle.small.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 14, color: Colors.white),
                ],
              ),
            ),
            // Distance (if available)
            if (restaurant.distance.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.near_me, size: 14, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.distance,
                    style: AirMenuTextStyle.small.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            // Location
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  restaurant.address ?? restaurant.location,
                  style: AirMenuTextStyle.small.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit Restaurant'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Delete Restaurant'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    // Use first gallery image or main image as fallback
    final imageUrl = restaurant.galleryImages.isNotEmpty
        ? restaurant.galleryImages.first.url
        : restaurant.mainImage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 320,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 320,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) => _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF334155),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            restaurant.name,
            style: AirMenuTextStyle.headingH3.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add gallery images to showcase your restaurant',
            style: AirMenuTextStyle.small.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
