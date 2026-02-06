import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/landmark/data/models/mall_model.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/widgets/restaurant_card.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class LandmarkRestaurantsView extends StatelessWidget {
  final MallModel mall;

  const LandmarkRestaurantsView({super.key, required this.mall});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackNavigation(context),
            const SizedBox(height: 24),
            _buildHeader(),
            const SizedBox(height: 32),
            _buildRestaurantsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackNavigation(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Text(
              'Back to Landmarks',
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mall Icon or Image could go here
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Color(0xFFC52031),
              size: 32,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mall.name,
                  style: AirMenuTextStyle.headingH3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Color(0xFFC52031),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mall.displayAddress.isNotEmpty
                            ? mall.displayAddress
                            : 'Location not specified',
                        style: AirMenuTextStyle.normal.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Maybe some stats or actions here
        ],
      ),
    );
  }

  Widget _buildRestaurantsGrid(BuildContext context) {
    // Dummy Data - In reality this would come from an API based on mall.id
    final restaurants = [
      {
        'name': 'Royal Spice Garden',
        'image':
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&auto=format&fit=crop&q=60',
        'cuisines': 'Indian, Chinese, Tandoori',
        'location': '${mall.name}, Level 2',
        'cost': '₹200 - ₹800',
      },
      {
        'name': 'Capella Bangkok',
        'image':
            'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=500&auto=format&fit=crop&q=60',
        'cuisines': 'North Indian, Biryani, Mughlai',
        'location': '${mall.name}, Food Court',
        'cost': '₹300 - ₹500',
      },
      {
        'name': 'Woodhouse Grill',
        'image':
            'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=500&auto=format&fit=crop&q=60',
        'cuisines': 'Steakhouse, Continental',
        'location': '${mall.name}, Ground Floor',
        'cost': '₹100 - ₹1400',
      },
      {
        'name': 'Saffron Lounge',
        'image':
            'https://images.unsplash.com/photo-1550966871-3ed3c47e2ce2?w=500&auto=format&fit=crop&q=60',
        'cuisines': 'Asian, Thai, Sushi',
        'location': '${mall.name}, Rooftop',
        'cost': '₹500 - ₹1200',
      },
      {
        'name': 'Burger King',
        'image':
            'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500&auto=format&fit=crop&q=60',
        'cuisines': 'Burgers, Fast Food',
        'location': '${mall.name}, Food Court',
        'cost': '₹150 - ₹400',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Restaurants & Outlets',
              style: AirMenuTextStyle.headingH4.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${restaurants.length} Active',
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFFC52031),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1600
                ? 4
                : constraints.maxWidth > 1100
                ? 3
                : constraints.maxWidth > 750
                ? 2
                : 1;

            final itemWidth =
                (constraints.maxWidth - (crossAxisCount - 1) * 24) /
                crossAxisCount;
            // Height calculation: Image(160) + Content(~240) = 400
            final childAspectRatio = itemWidth / 420;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final r = restaurants[index];
                return RestaurantCard(
                  name: r['name']!,
                  imageUrl: r['image']!,
                  cuisines: r['cuisines']!,
                  location: r['location']!,
                  cost: r['cost']!,
                  onView: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Viewing ${r['name']}')),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
