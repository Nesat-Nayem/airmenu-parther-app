import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/details/restaurant_details_state.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class OverviewTab extends StatelessWidget {
  final RestaurantDetailsLoaded state;

  const OverviewTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats
        _buildStatsGrid(context),
        const SizedBox(height: 24),

        // Restaurant Details Section
        _buildRestaurantDetailsSection(context),
        const SizedBox(height: 24),

        // Weekly Timings Section
        _buildWeeklyTimingsSection(context),
        const SizedBox(height: 24),

        // Buffets Section
        _buildBuffetsSection(context),
        const SizedBox(height: 24),

        // Legal Info
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Legal Information',
                style: AirMenuTextStyle.headingH4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GSTIN',
                          style: AirMenuTextStyle.tiny.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '29ABCDE1234F1ZH',
                          style: AirMenuTextStyle.normal.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FSSAI LICENSE',
                          style: AirMenuTextStyle.tiny.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '12345678901234',
                          style: AirMenuTextStyle.normal.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Branches
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Branches',
                    style: AirMenuTextStyle.headingH4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => context.push(AppRoutes.addBranch.path),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Add Branch',
                      style: AirMenuTextStyle.small.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildBranchesList(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Restaurant Details Section - Description, Tax Rates, Price Range, Offers
  Widget _buildRestaurantDetailsSection(BuildContext context) {
    final restaurant = state.restaurant;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Color(0xFF0EA5E9),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Restaurant Details',
                style: AirMenuTextStyle.headingH4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Description
          _buildDetailRow(
            icon: Icons.description_outlined,
            label: 'Description',
            child: Text(
              restaurant.description.isNotEmpty 
                  ? restaurant.description 
                  : 'No description available',
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Tax Rates Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildTaxCard('CGST Rate', '${restaurant.cgstRate}%', Icons.percent)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTaxCard('SGST Rate', '${restaurant.sgstRate}%', Icons.percent)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTaxCard('Service Charge', '${restaurant.serviceCharge}%', Icons.room_service_outlined)),
                  ],
                );
              }
              
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildTaxCard('CGST Rate', '${restaurant.cgstRate}%', Icons.percent)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTaxCard('SGST Rate', '${restaurant.sgstRate}%', Icons.percent)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTaxCard('Service Charge', '${restaurant.serviceCharge}%', Icons.room_service_outlined),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          
          // Price Range & Offer
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              
              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.attach_money,
                        label: 'Price Range',
                        value: restaurant.price.isNotEmpty ? restaurant.price : 'N/A',
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: restaurant.offer.isNotEmpty
                          ? _buildOfferCard(restaurant.offer)
                          : _buildInfoCard(
                              icon: Icons.local_offer_outlined,
                              label: 'Current Offer',
                              value: 'No active offers',
                              color: const Color(0xFF6B7280),
                            ),
                    ),
                  ],
                );
              }
              
              return Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.attach_money,
                    label: 'Price Range',
                    value: restaurant.price.isNotEmpty ? restaurant.price : 'N/A',
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 12),
                  restaurant.offer.isNotEmpty
                      ? _buildOfferCard(restaurant.offer)
                      : _buildInfoCard(
                          icon: Icons.local_offer_outlined,
                          label: 'Current Offer',
                          value: 'No active offers',
                          color: const Color(0xFF6B7280),
                        ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              label,
              style: AirMenuTextStyle.small.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTaxCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF6366F1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AirMenuTextStyle.tiny.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AirMenuTextStyle.tiny.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(String offer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_offer,
              size: 18,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Offer',
                  style: AirMenuTextStyle.tiny.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  offer,
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Weekly Timings Section
  Widget _buildWeeklyTimingsSection(BuildContext context) {
    final weeklyTimings = state.restaurant.weeklyTimings;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Timings',
                style: AirMenuTextStyle.headingH4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          if (weeklyTimings.isEmpty)
            _buildEmptyState(
              icon: Icons.schedule_outlined,
              message: 'No timing information available',
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 800
                    ? 3
                    : (constraints.maxWidth > 500 ? 2 : 1);
                final spacing = 12.0;
                final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
                
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: weeklyTimings.map((timing) {
                    return SizedBox(
                      width: itemWidth,
                      child: _buildTimingCard(timing.day, timing.hours),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTimingCard(String day, String hours) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today,
              size: 16,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: AirMenuTextStyle.small.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hours,
                  style: AirMenuTextStyle.tiny.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Buffets Section
  Widget _buildBuffetsSection(BuildContext context) {
    final buffets = state.buffets;
    final isLoading = state.isBuffetsLoading;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Color(0xFF22C55E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Buffets',
                style: AirMenuTextStyle.headingH4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (buffets.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${buffets.length} ${buffets.length == 1 ? 'buffet' : 'buffets'}',
                    style: AirMenuTextStyle.tiny.copyWith(
                      color: const Color(0xFF15803D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          if (isLoading)
            _buildBuffetsShimmer()
          else if (buffets.isEmpty)
            _buildEmptyState(
              icon: Icons.restaurant_outlined,
              message: 'No buffets available',
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                final spacing = 16.0;
                final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
                
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: buffets.map((buffet) {
                    return SizedBox(
                      width: itemWidth,
                      child: _buildBuffetCard(buffet),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBuffetCard(dynamic buffet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFFFFF),
            const Color(0xFFF0FDF4).withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  buffet.name,
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  buffet.type,
                  style: AirMenuTextStyle.tiny.copyWith(
                    color: const Color(0xFF15803D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Days
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  buffet.days.join(', '),
                  style: AirMenuTextStyle.tiny.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Hours
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(
                buffet.hours,
                style: AirMenuTextStyle.tiny.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '₹${buffet.price.toStringAsFixed(0)}',
              style: AirMenuTextStyle.small.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuffetsShimmer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        final spacing = 16.0;
        final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(2, (index) {
            return SizedBox(
              width: itemWidth,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[200]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: const Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AirMenuTextStyle.small.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = state.overviewStats;
    final items = [
      {
        'label': 'Orders Today',
        'value': stats['ordersToday'],
        'icon': Icons.shopping_bag_outlined,
      },
      {
        'label': 'GMV Today',
        'value': stats['gmvToday'],
        'icon': Icons.trending_up,
      },
      {
        'label': 'Avg Prep Time',
        'value': stats['avgPrepTime'],
        'icon': Icons.schedule,
      },
      {
        'label': 'Kitchen Health',
        'value': stats['kitchenHealth'],
        'icon': Icons.soup_kitchen_outlined,
        'color': const Color(0xFF22C55E),
      },
      {
        'label': 'Inventory Risk',
        'value': stats['inventoryRisk'],
        'icon': Icons.inventory_2_outlined,
        'color': const Color(0xFFF97316),
      },
      {
        'label': 'SLA Score',
        'value': stats['slaScore'],
        'icon': Icons.check_circle_outline,
        'color': const Color(0xFF22C55E),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 6
            : (constraints.maxWidth > 600 ? 3 : 2);
        final width =
            (constraints.maxWidth - (24 * (crossAxisCount - 1))) /
            crossAxisCount;

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: items
              .map(
                (item) => Container(
                  width: width,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 16,
                            color: const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['label'] as String,
                            style: AirMenuTextStyle.tiny.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['value'] as String,
                        style: AirMenuTextStyle.headingH4.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              item['color'] as Color? ??
                              const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildBranchesList(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'BRANCH NAME',
                  style: AirMenuTextStyle.tiny.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'CITY',
                  style: AirMenuTextStyle.tiny.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'STATUS',
                  style: AirMenuTextStyle.tiny.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'LAST SYNC',
                  style: AirMenuTextStyle.tiny.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(width: 40), // Action placeholder
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        ...state.branches
            .map(
              (branch) => Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        branch['name'],
                        style: AirMenuTextStyle.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        branch['city'],
                        style: AirMenuTextStyle.small.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(flex: 2, child: _buildStatusTag(branch['status'])),
                    Expanded(
                      flex: 2,
                      child: Text(
                        branch['lastSync'],
                        style: AirMenuTextStyle.small.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push(
                        AppRoutes.viewBranch.path,
                        extra: branch,
                      ),
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 20,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            )
            ,
      ],
    );
  }

  Widget _buildStatusTag(String status) {
    final isActive = status == 'Active';
    final bgColor = isActive
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFF3F4F6); // Green or Grey
    final textColor = isActive
        ? const Color(0xFF15803D)
        : const Color(0xFF4B5563);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              status,
              style: AirMenuTextStyle.tiny.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
