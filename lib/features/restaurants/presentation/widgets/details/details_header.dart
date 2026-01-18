import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class DetailsHeader extends StatelessWidget {
  final RestaurantModel restaurant;

  const DetailsHeader({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 800;

          if (isSmallScreen) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(restaurant),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTitleSection(restaurant, context)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoRow(restaurant),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, child: _buildActionButton()),
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(restaurant),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTitleSection(restaurant, context),
                          ),
                          _buildActionButton(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(restaurant),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildAvatar(RestaurantModel restaurant) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE53935), // A brand red shade
            Color(0xFFE35D5B), // A lighter pink-red shade
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          restaurant.name.isNotEmpty
              ? restaurant.name.characters.first.toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(RestaurantModel restaurant, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              restaurant.name,
              style: AirMenuTextStyle.headingH3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            _buildTag(
              'Premium',
              const Color(0xFFFFF7ED),
              const Color(0xFFF97316),
            ), // Amber orange
            const SizedBox(width: 8),
            _buildTag(
              'Active',
              const Color(0xFFDCFCE7),
              const Color(0xFF22C55E),
            ), // Green
          ],
        ),
        const SizedBox(height: 4),
        Text(
          restaurant.primaryCuisine ?? 'Fine Dining',
          style: AirMenuTextStyle.normal.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(RestaurantModel restaurant) {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: [
        _buildIconText(
          Icons.location_on_outlined,
          restaurant.address ?? '123 MG Road, Indiranagar, Bangalore',
        ),
        _buildIconText(Icons.phone_outlined, restaurant.contactNumber),
        _buildIconText(Icons.email_outlined, restaurant.contactEmail),
        _buildIconText(Icons.calendar_today_outlined, 'Joined Jan 2024'),
      ],
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          text,
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AirMenuTextStyle.tiny.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.open_in_new, size: 18),
      label: const Text('Open Restaurant Dashboard'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC52031), // Brand Red
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    );
  }
}
