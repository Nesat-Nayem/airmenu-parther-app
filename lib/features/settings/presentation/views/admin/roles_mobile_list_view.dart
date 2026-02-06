import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class RolesMobileListView extends StatelessWidget {
  const RolesMobileListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _buildRoleCard(
          'Super Admin',
          'Complete platform access',
          '2 users',
          ['Full Access', 'User Management', 'Settings'],
          const Color(0xFFEF4444),
        ),
        _buildRoleCard(
          'Operations Manager',
          'Day-to-day operations management',
          '5 users',
          ['Restaurants', 'Orders', 'Delivery'],
          const Color(0xFFF59E0B),
        ),
        _buildRoleCard(
          'Support Lead',
          'Customer and restaurant support',
          '8 users',
          ['Restaurants', 'Orders', 'Feedback'],
          const Color(0xFF10B981),
        ),
        _buildRoleCard(
          'Finance Admin',
          'Financial operations and reporting',
          '3 users',
          ['Payments', 'Settlements', 'Reports'],
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
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AirMenuTextStyle.normal.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                userCount,
                style: AirMenuTextStyle.caption.copyWith(
                  color: AirMenuColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AirMenuTextStyle.caption.copyWith(
              color: AirMenuColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: permissions.map((p) => _buildPermissionBadge(p)).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(onPressed: () {}, child: const Text('Users')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AirMenuTextStyle.caption.copyWith(
          color: const Color(0xFF374151),
          fontSize: 10,
        ),
      ),
    );
  }
}
