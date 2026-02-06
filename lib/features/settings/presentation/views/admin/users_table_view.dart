import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class UsersTableView extends StatelessWidget {
  const UsersTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildHeaderCell('User')),
                Expanded(flex: 2, child: _buildHeaderCell('Role')),
                Expanded(flex: 2, child: _buildHeaderCell('Last Active')),
                Expanded(flex: 2, child: _buildHeaderCell('Status')),
                Expanded(
                  flex: 1,
                  child: _buildHeaderCell('Actions', align: TextAlign.right),
                ),
              ],
            ),
          ),

          // Table Rows (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildRow(
                    'Arun Kumar',
                    'arun@airmenu.in',
                    'A',
                    const Color(0xFFFFCCCC),
                    'Super Admin',
                    '2 min ago',
                    true,
                  ),
                  _buildRow(
                    'Priya Sharma',
                    'priya@airmenu.in',
                    'P',
                    const Color(0xFFFFD1DC),
                    'Operations Manager',
                    '1 hour ago',
                    true,
                  ),
                  _buildRow(
                    'Rahul Verma',
                    'rahul@airmenu.in',
                    'R',
                    const Color(0xFFFFE4E1),
                    'Support Lead',
                    '3 hours ago',
                    true,
                  ),
                  _buildRow(
                    'Sneha Gupta',
                    'sneha@airmenu.in',
                    'S',
                    const Color(0xFFFFE4E1),
                    'Finance Admin',
                    'Yesterday',
                    true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: AirMenuTextStyle.small.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildRow(
    String name,
    String email,
    String initial,
    Color avatarColor,
    String role,
    String lastActive,
    bool isActive,
  ) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF9FAFB))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // User Column
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initial,
                    style: AirMenuTextStyle.normal.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF991B1B), // Dark red text
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AirMenuColors.textPrimary,
                      ),
                    ),
                    Text(
                      email,
                      style: AirMenuTextStyle.small.copyWith(
                        color: AirMenuColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Role Column
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  role,
                  style: AirMenuTextStyle.small.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF374151),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),

          // Last Active Column
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Text(
                  lastActive,
                  style: AirMenuTextStyle.small.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Status Column
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF10B981).withOpacity(0.2)
                        : const Color(0xFFEF4444).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'active' : 'inactive',
                      style: AirMenuTextStyle.small.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Actions Column
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionIcon(Icons.edit_outlined),
                const SizedBox(width: 8),
                _buildActionIcon(Icons.vpn_key_outlined),
                const SizedBox(width: 8),
                _buildActionIcon(Icons.delete_outline, isDestructive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, {bool isDestructive = false}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 18,
          color: isDestructive
              ? const Color(0xFFEF4444)
              : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}
