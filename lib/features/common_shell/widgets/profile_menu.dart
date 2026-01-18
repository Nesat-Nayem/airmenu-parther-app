import 'package:airmenuai_partner_app/core/models/user_model.dart';
import 'package:airmenuai_partner_app/core/network/auth_service.dart';
import 'package:airmenuai_partner_app/utils/services/user_service.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class ProfileMenu extends StatefulWidget {
  const ProfileMenu({super.key});

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  final UserService _userService = locator<UserService>();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final userName = user?.name ?? 'User';
    final userEmail = user?.email ?? 'user@example.com';
    final userImage = user?.img;

    final isMobile = Responsive.isMobile(context);

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        margin: isMobile
            ? const EdgeInsets.only(right: 16)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: isMobile
            ? const EdgeInsets.all(4)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AirMenuColors.primary.shade9,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AirMenuColors.primary.shade7, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AirMenuColors.primary,
              backgroundImage: userImage != null && userImage.isNotEmpty
                  ? CachedNetworkImageProvider(userImage)
                  : null,
              child: userImage == null || userImage.isEmpty
                  ? const Icon(Iconsax.user, color: Colors.white, size: 16)
                  : null,
            ),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userName,
                    style: AirMenuTextStyle.small.bold700().copyWith(
                      fontSize: 12,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    userEmail,
                    style: AirMenuTextStyle.caption.copyWith(
                      fontSize: 10,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: AirMenuColors.primary,
              ),
            ],
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Iconsax.user, color: AirMenuColors.primary, size: 20),
              const SizedBox(width: 12),
              Text('My Profile', style: AirMenuTextStyle.normal),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(
                Iconsax.setting_2,
                color: AirMenuColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text('Settings', style: AirMenuTextStyle.normal),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(
                Iconsax.logout,
                color: AirMenuColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: AirMenuTextStyle.normal.copyWith(
                  color: AirMenuColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        // Handle menu selection
        if (value == 'logout') {
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (confirmed == true && mounted) {
            // Perform logout
            final authService = locator<AuthService>();
            await authService.logout();

            // Navigate to login page using GoRouter
            if (mounted) {
              context.go(AppRoutes.loginAndSignUp.path);
            }
          }
        }
      },
    );
  }
}
