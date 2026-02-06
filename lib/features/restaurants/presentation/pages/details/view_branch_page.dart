import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class ViewBranchPage extends StatefulWidget {
  final Map<String, dynamic>? branchData;

  const ViewBranchPage({super.key, this.branchData});

  @override
  State<ViewBranchPage> createState() => _ViewBranchPageState();
}

class _ViewBranchPageState extends State<ViewBranchPage> {
  int _selectedTabIndex = 0;

  String get branchName => widget.branchData?['name'] ?? 'Branch';
  String get branchCity => widget.branchData?['city'] ?? 'City';
  String get branchStatus => widget.branchData?['status'] ?? 'Active';
  String get lastSync => widget.branchData?['lastSync'] ?? '2 min ago';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: TextButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF6B7280),
                        size: 18,
                      ),
                      label: Text(
                        'Back to Restaurant',
                        style: AirMenuTextStyle.normal.copyWith(
                          color: const Color(0xFF111827),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                  ),

                  // Header Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Branch Icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC52031),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                branchName.substring(0, 1).toUpperCase(),
                                style: AirMenuTextStyle.headingH2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Branch Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      branchName,
                                      style: AirMenuTextStyle.headingH3
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF111827),
                                          ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: branchStatus == 'Active'
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        branchStatus,
                                        style: AirMenuTextStyle.tiny.copyWith(
                                          color: branchStatus == 'Active'
                                              ? const Color(0xFF15803D)
                                              : const Color(0xFF6B7280),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      branchCity,
                                      style: AirMenuTextStyle.small.copyWith(
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 16,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'N/A',
                                      style: AirMenuTextStyle.small.copyWith(
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.email_outlined,
                                      size: 16,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'N/A',
                                      style: AirMenuTextStyle.small.copyWith(
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Joined Jan 2024',
                                      style: AirMenuTextStyle.small.copyWith(
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTabs(),
                  ),
                  const SizedBox(height: 24),

                  // Tab Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTabContent(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      {'icon': Icons.dashboard_outlined, 'label': 'Overview'},
      {'icon': Icons.restaurant_menu, 'label': 'Menu & Issues'},
      {'icon': Icons.qr_code_2, 'label': 'Tables & QR'},
      {'icon': Icons.inventory_2_outlined, 'label': 'Inventory Health'},
      {'icon': Icons.receipt_long_outlined, 'label': 'Billing'},
      {'icon': Icons.people_outline, 'label': 'Staff & Roles'},
      {
        'icon': Icons.integration_instructions_outlined,
        'label': 'Integrations',
      },
      {'icon': Icons.rocket_launch_outlined, 'label': 'Onboarding'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTabIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFC52031) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tab['label'] as String,
                      style: AirMenuTextStyle.normal.copyWith(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF6B7280),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildMenuIssuesTab();
      case 2:
        return _buildTablesQRTab();
      case 3:
        return _buildInventoryHealthTab();
      case 4:
        return _buildBillingTab();
      case 5:
        return _buildStaffRolesTab();
      case 6:
        return _buildIntegrationsTab();
      case 7:
        return _buildOnboardingTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legal Information (GSTIN & FSSAI)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GSTIN',
                      style: AirMenuTextStyle.tiny.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '29ABCDE1234F1ZH',
                      style: AirMenuTextStyle.normal.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w500,
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
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '12345678901234',
                      style: AirMenuTextStyle.normal.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tables Section (similar to Branches in restaurant view)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tables',
                    style: AirMenuTextStyle.headingH4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC52031),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Add Table',
                      style: AirMenuTextStyle.normal.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Table Header
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'TABLE NAME',
                      style: AirMenuTextStyle.tiny.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'CAPACITY',
                      style: AirMenuTextStyle.tiny.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'STATUS',
                      style: AirMenuTextStyle.tiny.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'LAST SYNC',
                      style: AirMenuTextStyle.tiny.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),

              // Sample Tables
              _buildTableRow('Table 1', '4 seats', 'Active', '2 min ago'),
              const Divider(height: 32),
              _buildTableRow('Table 2', '6 seats', 'Active', '5 min ago'),
              const Divider(height: 32),
              _buildTableRow('Table 3', '2 seats', 'Inactive', '1 hr ago'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow(
    String name,
    String capacity,
    String status,
    String lastSync,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            name,
            style: AirMenuTextStyle.normal.copyWith(
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            capacity,
            style: AirMenuTextStyle.normal.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: status == 'Active'
                      ? const Color(0xFF15803D)
                      : const Color(0xFF6B7280),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: AirMenuTextStyle.normal.copyWith(
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            lastSync,
            style: AirMenuTextStyle.normal.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.visibility_outlined,
            size: 20,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '$title for $branchName branch',
          style: AirMenuTextStyle.normal.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuIssuesTab() => _buildPlaceholderTab('Menu Issues');
  Widget _buildTablesQRTab() => _buildPlaceholderTab('Tables & QR Codes');
  Widget _buildInventoryHealthTab() => _buildPlaceholderTab('Inventory Health');
  Widget _buildBillingTab() => _buildPlaceholderTab('Billing Information');
  Widget _buildStaffRolesTab() => _buildPlaceholderTab('Staff & Roles');
  Widget _buildIntegrationsTab() => _buildPlaceholderTab('Integrations');
  Widget _buildOnboardingTab() => _buildPlaceholderTab('Onboarding Status');
}
