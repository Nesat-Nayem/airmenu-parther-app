import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class UsersMobileListView extends StatelessWidget {
  const UsersMobileListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _buildUserCard(
          'Arun Kumar',
          'arun@airmenu.in',
          'A',
          const Color(0xFFFFCCCC),
          'Super Admin',
          '2 min ago',
          true,
        ),
        _buildUserCard(
          'Priya Sharma',
          'priya@airmenu.in',
          'P',
          const Color(0xFFFFD1DC),
          'Operations Manager',
          '1 hour ago',
          true,
        ),
        _buildUserCard(
          'Rahul Verma',
          'rahul@airmenu.in',
          'R',
          const Color(0xFFFFE4E1),
          'Support Lead',
          '3 hours ago',
          true,
        ),
        _buildUserCard(
          'Sneha Gupta',
          'sneha@airmenu.in',
          'S',
          const Color(0xFFFFE4E1),
          'Finance Admin',
          'Yesterday',
          true,
        ),
      ],
    );
  }

  Widget _buildUserCard(
    String name,
    String email,
    String initial,
    Color avatarColor,
    String role,
    String lastActive,
    bool isActive,
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
        children: [
          Row(
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
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.bold,
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
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: AirMenuTextStyle.caption.copyWith(
                    color: isActive
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                role,
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFF374151),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Active $lastActive',
                style: AirMenuTextStyle.caption.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.vpn_key_outlined,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
