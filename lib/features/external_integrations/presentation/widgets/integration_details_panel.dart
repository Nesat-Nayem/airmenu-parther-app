import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/external_integration_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/external_integrations_bloc.dart';

class IntegrationDetailsPanel extends StatefulWidget {
  final IntegrationPartner partner;

  const IntegrationDetailsPanel({super.key, required this.partner});

  @override
  State<IntegrationDetailsPanel> createState() =>
      _IntegrationDetailsPanelState();
}

class _IntegrationDetailsPanelState extends State<IntegrationDetailsPanel> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = [
    'Partner Info',
    'API & Webhooks',
    'Pricing & SLA',
    'Restaurants',
    'Failover',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 32),

          // Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: _buildTab(
                    entry.value,
                    entry.key == _selectedTabIndex,
                    entry.key,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 32),

          // Content
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626), // Red-600
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.partner.name.substring(0, 2).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.partner.name,
                  style: AirMenuTextStyle.headingH3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF059669),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'connected',
                        style: AirMenuTextStyle.caption.copyWith(
                          color: const Color(0xFF047857),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              'Last sync: ${widget.partner.lastSync}',
              style: AirMenuTextStyle.small.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => context.read<ExternalIntegrationsBloc>().add(
            CloseIntegrationDetails(),
          ),
          icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  Widget _buildTab(String label, bool isActive, int index) {
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildPartnerInfo();
      case 1:
        return _buildApiWebhooks();
      case 2:
        return _buildPricingSLA();
      case 3:
        return _buildRestaurants();
      case 4:
        return _buildFailover();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Partner Info ---
  Widget _buildPartnerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(child: _buildInfoItem('Type', widget.partner.type)),
              Expanded(
                child: _buildInfoItem(
                  'Restaurants Linked',
                  widget.partner.restaurantsLinked.split(' ')[0],
                  bigValue: true,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'API Status',
                  'connected',
                  valueColor: const Color(0xFF059669),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Last Sync',
                  widget.partner.lastSync,
                  bigValue: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Service Regions',
          style: AirMenuTextStyle.normal.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRegionPill('Bangalore'),
            const SizedBox(width: 8),
            _buildRegionPill('Hyderabad'),
            const SizedBox(width: 8),
            _buildRegionPill('Pune'),
          ],
        ),
      ],
    );
  }

  // --- API & Webhooks ---
  Widget _buildApiWebhooks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('API Key'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Text(
                'sk-live-****************************2abc',
                style: AirMenuTextStyle.normal.copyWith(
                  color: const Color(0xFF374151),
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              _buildSmallButton(Icons.content_copy, 'Copy'),
              const SizedBox(width: 8),
              _buildSmallButton(Icons.refresh, 'Rotate'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Webhooks'),
            _buildSmallButton(Icons.add, 'Add Webhook', isPrimary: false),
          ],
        ),
        const SizedBox(height: 16),
        _buildWebhookItem(
          'delivery.created',
          'https://api.airmenu.ai/webhook/rp/created',
        ),
        const SizedBox(height: 12),
        _buildWebhookItem(
          'delivery.updated',
          'https://api.airmenu.ai/webhook/rp/updated',
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Recent API Logs'),
            Text(
              'View All',
              style: AirMenuTextStyle.small.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLogItem(
          '12:45:23',
          'delivery.created',
          'Delivery #4521 assigned',
          '124ms',
          success: true,
        ),
        _buildLogItem(
          '12:42:18',
          'delivery.updated',
          'Status: In Transit',
          '',
          success: true,
        ),
        _buildLogItem(
          '12:38:45',
          'delivery.completed',
          'Delivered to customer',
          '',
          success: true,
        ),
        _buildLogItem(
          '12:35:12',
          'delivery.created',
          'Timeout - No riders available',
          '5000ms',
          success: false,
        ),
      ],
    );
  }

  // --- Pricing & SLA ---
  Widget _buildPricingSLA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPriceCard(
                '₹8.5', // Updated value from screenshot
                'Per Kilometer',
                icon: Icons.attach_money,
                iconColor: const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPriceCard(
                '₹25', // Updated value from screenshot
                'Minimum Fee',
                icon: Icons.attach_money,
                iconColor: const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPriceCard(
                '94%', // Updated value from screenshot
                'SLA Target',
                icon: Icons.trending_up,
                iconColor: const Color(0xFF059669),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'SLA Performance (Last 7 Days)',
          style: AirMenuTextStyle.normal.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Custom Graph Layout
        SizedBox(
          height: 220,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Y-Axis Labels
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '100',
                    style: AirMenuTextStyle.caption.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  Text(
                    '86',
                    style: AirMenuTextStyle.caption.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  Text(
                    '78',
                    style: AirMenuTextStyle.caption.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  Text(
                    '70',
                    style: AirMenuTextStyle.caption.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ), // Space for X-axis labels alignment
                ],
              ),
              const SizedBox(width: 16),
              // Bars
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _GraphBar(day: 'Mon', heightFraction: 0.60, value: '86%'),
                    _GraphBar(day: 'Tue', heightFraction: 0.85, value: '91%'),
                    _GraphBar(day: 'Wed', heightFraction: 0.55, value: '79%'),
                    _GraphBar(day: 'Thu', heightFraction: 0.80, value: '94%'),
                    _GraphBar(day: 'Fri', heightFraction: 0.75, value: '88%'),
                    _GraphBar(day: 'Sat', heightFraction: 0.55, value: '78%'),
                    _GraphBar(day: 'Sun', heightFraction: 0.95, value: '98%'),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Bottom Stats (Boxed)
        Row(
          children: [
            Expanded(
              child: _buildStatBox(
                'Avg Delivery Time',
                '28 min',
                valueColor: const Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatBox(
                'Late Deliveries',
                '6.0%',
                valueColor: const Color(0xFFD97706), // Orange
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatBox(
                'Cancellation Rate',
                '3.5%',
                valueColor: const Color(0xFFDC2626), // Red
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AirMenuTextStyle.caption.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AirMenuTextStyle.headingH4.copyWith(
              color: valueColor ?? const Color(0xFF111827),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- Restaurants ---
  Widget _buildRestaurants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '567 restaurants linked',
              style: AirMenuTextStyle.small.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            _buildSmallButton(Icons.link, 'Link Restaurant', isPrimary: false),
          ],
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            _buildRestaurantRow('Spice Garden', 'Bangalore', '45 orders today'),
            _buildRestaurantRow('Pizza Paradise', 'Mumbai', '38 orders today'),
            _buildRestaurantRow(
              'Biryani House',
              'Hyderabad',
              '52 orders today',
            ),
            _buildRestaurantRow(
              'Cafe Coffee Day',
              'Bangalore',
              '28 orders today',
            ),
            _buildRestaurantRow('Burger King', 'Delhi', '67 orders today'),
          ],
        ),
      ],
    );
  }

  // --- Failover ---
  Widget _buildFailover() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sync,
                  color: Color(0xFF059669),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enable Failover',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Automatically switch to backup partner if primary fails',
                      style: AirMenuTextStyle.small.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Enabled'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Fallback Partner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'Internal Fleet',
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF6B7280),
              ),
              items: ['Internal Fleet', 'Shadowfax', 'Dunzo'].map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AirMenuTextStyle.normal.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSmallButton(
    IconData icon,
    String label, {
    bool isPrimary = false,
  }) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF374151),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildWebhookItem(String type, String url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF059669),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            type,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          Text(
            url,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(
    String time,
    String event,
    String desc,
    String duration, {
    required bool success,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: success
                  ? const Color(0xFF059669)
                  : const Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF6B7280),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 16),
          Text(
            event,
            style: AirMenuTextStyle.small.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          Text(
            desc,
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 16),
          if (duration.isNotEmpty)
            Text(
              duration,
              style: AirMenuTextStyle.small.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          if (!success)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Timeout',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(
    String value,
    String label, {
    String? diff,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon ?? Icons.attach_money,
            color: iconColor ?? const Color(0xFFDC2626),
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AirMenuTextStyle.caption.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          if (diff != null)
            Text(
              diff,
              style: AirMenuTextStyle.caption.copyWith(
                color: const Color(0xFF059669),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRestaurantRow(String name, String city, String orders) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(20),
            ), // Light red circle
            child: const Icon(Icons.store, color: Color(0xFFDC2626), size: 16),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AirMenuTextStyle.normal.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                city,
                style: AirMenuTextStyle.caption.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(orders, style: AirMenuTextStyle.small),
          const SizedBox(width: 24),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Unlink',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }

  // Reuse existing helpers
  Widget _buildInfoItem(
    String label,
    String value, {
    bool bigValue = false,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.caption.copyWith(
            color: const Color(0xFF9CA3AF),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AirMenuTextStyle.normal.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: bigValue ? 18 : 14,
            color: valueColor ?? const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildRegionPill(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 12,
            color: Color(0xFF6B7280),
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: AirMenuTextStyle.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphBar extends StatefulWidget {
  final String day;
  final double heightFraction;
  final String value;

  const _GraphBar({
    required this.day,
    required this.heightFraction,
    required this.value,
  });

  @override
  State<_GraphBar> createState() => _GraphBarState();
}

class _GraphBarState extends State<_GraphBar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Tooltip(
            message: widget.value,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            textStyle: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            preferBelow: false,
            verticalOffset: 12,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 160 * widget.heightFraction,
              decoration: BoxDecoration(
                color: _isHovered
                    ? const Color(0xFFB91C1C)
                    : const Color(0xFFDC2626), // Darker on hover
                borderRadius: BorderRadius.circular(4),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.day,
          style: AirMenuTextStyle.caption.copyWith(
            color: _isHovered
                ? const Color(0xFF111827)
                : const Color(0xFF6B7280),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
