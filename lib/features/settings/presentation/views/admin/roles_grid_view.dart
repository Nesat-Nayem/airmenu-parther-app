import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class RolesGridView extends StatelessWidget {
  const RolesGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.0, // Adjust as needed
      children: [
        _buildRoleCard(
          'Super Admin',
          'Complete platform access',
          '2 users',
          ['Full Access', 'User Management', 'Settings', 'Billing'],
          Icons.admin_panel_settings_outlined,
          const Color(0xFFEF4444),
        ),
        _buildRoleCard(
          'Operations Manager',
          'Day-to-day operations management',
          '5 users',
          ['Restaurants', 'Orders', 'Delivery', 'Reports'],
          Icons.business_center_outlined,
          const Color(0xFFF59E0B),
        ),
        _buildRoleCard(
          'Support Lead',
          'Customer and restaurant support',
          '8 users',
          ['Restaurants', 'Orders', 'Feedback'],
          Icons.support_agent_outlined,
          const Color(0xFF10B981),
        ),
        _buildRoleCard(
          'Finance Admin',
          'Financial operations and reporting',
          '3 users',
          ['Payments', 'Settlements', 'Reports'],
          Icons.account_balance_wallet_outlined,
          const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    String title,
    String description,
    String userCount,
    List<String> permissions,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AirMenuTextStyle.headingH4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AirMenuColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                userCount,
                style: AirMenuTextStyle.small.copyWith(
                  color: AirMenuColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AirMenuTextStyle.normal.copyWith(
              color: AirMenuColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: permissions.map((p) => _buildPermissionBadge(p)).toList(),
          ),
          const Spacer(),
          Container(height: 1, color: const Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Edit',
                    style: AirMenuTextStyle.small.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AirMenuColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'View Users',
                    style: AirMenuTextStyle.small.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AirMenuColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AirMenuTextStyle.caption.copyWith(
          color: const Color(0xFF374151),
        ),
      ),
    );
  }
}
