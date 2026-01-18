import 'package:airmenuai_partner_app/features/dashboard/data/models/shared/dashboard_models.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Top restaurants table widget
class TopRestaurantsTable extends StatefulWidget {
  final List<TopRestaurantModel> restaurants;

  const TopRestaurantsTable({super.key, required this.restaurants});

  @override
  State<TopRestaurantsTable> createState() => _TopRestaurantsTableState();
}

class _TopRestaurantsTableState extends State<TopRestaurantsTable> {
  String _searchQuery = '';
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final filteredRestaurants = widget.restaurants.where((restaurant) {
      return restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? AirMenuColors.primary.withOpacity(0.1)
                : const Color(0xFFF3F4F6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 16 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with search
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Restaurants',
                  style: AirMenuTextStyle.subheadingH5.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // Search field
                    SizedBox(
                      width: 200,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search restaurants...',
                          hintStyle: AirMenuTextStyle.small.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 18,
                            color: Color(0xFF9CA3AF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AirMenuColors.primary,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          isDense: true,
                        ),
                        style: AirMenuTextStyle.small,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.filter_list, size: 20),
                      onPressed: () {
                        // TODO: Implement filter
                      },
                      color: const Color(0xFF6B7280),
                      tooltip: 'Filter',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Showing ${filteredRestaurants.length} of ${widget.restaurants.length} restaurants',
              style: AirMenuTextStyle.caption.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            // Table with horizontal scroll
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 900),
                  child: SingleChildScrollView(
                    child: Table(
                      columnWidths: const {
                        0: FixedColumnWidth(200),
                        1: FixedColumnWidth(100),
                        2: FixedColumnWidth(120),
                        3: FixedColumnWidth(100),
                        4: FixedColumnWidth(140),
                        5: FixedColumnWidth(140),
                        6: FixedColumnWidth(100),
                      },
                      children: [
                        // Header row
                        TableRow(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          children: [
                            _buildHeaderCell('RESTAURANT'),
                            _buildHeaderCell('ORDERS'),
                            _buildHeaderCell('PREP TIME'),
                            _buildHeaderCell('QUEUE'),
                            _buildHeaderCell('HEALTH'),
                            _buildHeaderCell('STATUS'),
                            _buildHeaderCell('ACTIONS'),
                          ],
                        ),
                        // Data rows
                        ...filteredRestaurants.asMap().entries.map(
                          (entry) => _buildDataRow(entry.value, entry.key + 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text,
        style: AirMenuTextStyle.caption.copyWith(
          color: const Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  TableRow _buildDataRow(TopRestaurantModel restaurant, int index) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      children: [
        _buildDataCell(
          Row(
            children: [
              // Badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AirMenuColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '#$index',
                    style: AirMenuTextStyle.small.copyWith(
                      color: AirMenuColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  restaurant.name,
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        _buildDataCell(
          Text(
            restaurant.orders.toString(),
            style: AirMenuTextStyle.normal.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildDataCell(
          Text(restaurant.prepTime, style: AirMenuTextStyle.normal),
        ),
        _buildDataCell(
          Text(restaurant.queue.toString(), style: AirMenuTextStyle.normal),
        ),
        _buildDataCell(
          Row(
            children: [
              Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: restaurant.healthPercentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getHealthColor(restaurant.healthPercentage),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${restaurant.healthPercentage.toInt()}%',
                style: AirMenuTextStyle.small.copyWith(
                  color: _getHealthColor(restaurant.healthPercentage),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _buildDataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(restaurant.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 6,
                  color: _getStatusColor(restaurant.status),
                ),
                const SizedBox(width: 6),
                Text(
                  restaurant.status.toUpperCase(),
                  style: AirMenuTextStyle.caption.copyWith(
                    color: _getStatusColor(restaurant.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildDataCell(
          IconButton(
            icon: const Icon(Icons.more_vert, size: 18),
            onPressed: () {
              // TODO: Show actions menu
            },
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: child,
    );
  }

  Color _getHealthColor(double health) {
    if (health >= 80) {
      return const Color(0xFF10B981);
    } else if (health >= 60) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFFEF4444);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981);
      case 'warning':
        return const Color(0xFFF59E0B);
      case 'critical':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
