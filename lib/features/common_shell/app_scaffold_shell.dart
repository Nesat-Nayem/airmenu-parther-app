import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item.dart';
import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item_config.dart';
import 'package:airmenuai_partner_app/core/enums/user_role.dart';
import 'package:airmenuai_partner_app/core/services/role_service.dart';
import 'package:airmenuai_partner_app/features/common_shell/widgets/modern_nav_menu.dart';
import 'package:airmenuai_partner_app/features/common_shell/widgets/profile_menu.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class AppScaffoldShell extends StatefulWidget {
  final Widget child;
  final List<NavMenuItem>? navMenuItemList;
  final NavMenuItem selectedNavMenuItem;

  const AppScaffoldShell({
    super.key,
    required this.child,
    this.navMenuItemList,
    required this.selectedNavMenuItem,
  });

  @override
  State<AppScaffoldShell> createState() => _AppScaffoldShellState();
}

class _AppScaffoldShellState extends State<AppScaffoldShell> {
  static const Color _backgroundColor = Colors.white;

  // Initialize with empty lists to prevent late initialization error
  List<NavMenuItemConfig<NavMenuItem>> _navMenuItemConfigList = [];
  List<NavMenuItemConfig<NavMenuItem>> _utilityNavMenuItemConfigList = [];

  @override
  void initState() {
    super.initState();
    // Call async method without awaiting in initState
    _updateMenuConfig();
  }

  void _updateMenuConfig() async {
    // Get current user's role
    final userRole = await RoleService.getUserRole();
    final user = await RoleService.getCurrentUser();

    // Check role types
    final isVendor = userRole == UserRole.vendor;
    final isAdmin = userRole == UserRole.admin;

    // Check features from packageFeatures array
    bool hasFeature(String feature) {
      if (user?.packageFeatures == null) return false;
      return user?.packageFeatures?.contains(feature) == true;
    }

    // Check permissions (you can customize this logic)
    bool hasPermission(String permission) {
      // For now, admins have all permissions
      if (isAdmin) return true;
      // Add your permission checking logic here
      //TODO: Implement permission checking logic
      return hasFeature(permission);
    }

    final filteredRoutes = sideNavRoutes.where((item) {
      return _shouldShowMenuItem(
        item,
        isAdmin: isAdmin,
        isVendor: isVendor,
        hasFeature: hasFeature,
        hasPermission: hasPermission,
      );
    }).toList();

    setState(() {
      _navMenuItemConfigList = filteredRoutes
          .map((e) => e.toNavMenuItemConfig())
          .toList();
      _utilityNavMenuItemConfigList = utilityNavMenuItem
          .map((e) => e.toNavMenuItemConfig())
          .toList();
    });
  }

  bool _shouldShowMenuItem(
    NavMenuItem item, {
    required bool isAdmin,
    required bool isVendor,
    required bool Function(String) hasFeature,
    required bool Function(String) hasPermission,
  }) {
    // ===== ADMIN-ONLY FEATURES =====
    // Only SuperAdmin should see these:
    // Onboarding, SuperAdmin Dashboard, Restaurant Overview, Menu Audit,
    // Live Orders (admin), Payments, Offers (admin), User Settings,
    // Inventory (admin), External Integrations, Landmark, Delivery Partner,
    // Riders, Theatre, Hotel

    if (isAdmin) {
      switch (item) {
        case NavMenuItem.onboardingPipeline:
        case NavMenuItem.adminDashboard:
        case NavMenuItem.restaurants:
        case NavMenuItem.adminOrders:
        case NavMenuItem.payments:
        case NavMenuItem.exclusiveOffers:
        case NavMenuItem.adminInventory:
        case NavMenuItem.adminSettings:
        case NavMenuItem.externalIntegrations:
        case NavMenuItem.landmark:
        case NavMenuItem.deliveryPartner:
        case NavMenuItem.riders:
        case NavMenuItem.theatre:
        case NavMenuItem.hotel:
          return true;
        default:
          return false; // Admin ONLY sees the above items
      }
    }

    // ===== VENDOR-ONLY FEATURES =====
    // Vendor should see:
    // Dashboard, Live Orders, Menu, Inventory, Purchase Order, Kitchen Panel,
    // Tables and QR, Hotel Rooms, Staff Management, Offers, Feedback & Rating,
    // Report, Settings

    if (isVendor) {
      switch (item) {
        case NavMenuItem.dashboard:
          return true;
        case NavMenuItem.orders:
          return hasFeature('orders');
        case NavMenuItem.menu:
          return true;
        case NavMenuItem.inventory:
          return true;
        case NavMenuItem.purchaseOrder:
          return true;
        case NavMenuItem.kitchenPanel:
          return true;
        case NavMenuItem.tables:
          return true;
        case NavMenuItem.hotelRooms:
          return true;
        case NavMenuItem.staffManagement:
          return true;
        case NavMenuItem.coupons:
          return true;
        case NavMenuItem.feedbackRating:
          return true;
        case NavMenuItem.reports:
          return true;
        case NavMenuItem.settings:
          return true;
        default:
          return false; // Vendor ONLY sees the above items
      }
    }

    // Default: hide items for unknown roles
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: isMobile
          ? ModernNavMenu(
              navMenuItemConfigList: _navMenuItemConfigList,
              utilityNavMenuItemConfigList: _utilityNavMenuItemConfigList,
              selectedNavMenuItem: widget.selectedNavMenuItem,
              onSelectNavMenu: (navMenuItem) =>
                  _handleNavMenuSelection(context, navMenuItem),
              onSelectFooterNavMenu: (footerNavMenuItem) =>
                  _handleNavMenuSelection(context, footerNavMenuItem),
            )
          : null,
      appBar: isMobile
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Builder(
                builder: (context) => Container(
                  width: double.infinity,
                  height: kToolbarHeight,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: AirMenuColors.primary,
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      const ProfileMenu(),
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Side Navigation (Desktop/Tablet)
          if (!isMobile)
            ModernNavMenu(
              navMenuItemConfigList: _navMenuItemConfigList,
              utilityNavMenuItemConfigList: _utilityNavMenuItemConfigList,
              selectedNavMenuItem: widget.selectedNavMenuItem,
              onSelectNavMenu: (navMenuItem) =>
                  _handleNavMenuSelection(context, navMenuItem),
              onSelectFooterNavMenu: (footerNavMenuItem) =>
                  _handleNavMenuSelection(context, footerNavMenuItem),
            ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                if (!isMobile)
                  Container(
                    width: double.infinity,
                    height: kToolbarHeight + 8,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // Page title on the left - uses selectedNavMenuItem label
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getPageTitle(widget.selectedNavMenuItem),
                                  style: AirMenuTextStyle.headingH3.copyWith(
                                    color: AirMenuColors.neutral.shade10,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Sparkles icon with rotation (matching HTML)
                                Transform.rotate(
                                  angle: 0.08, // ~4.5 degrees rotation
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 18,
                                    color: AirMenuColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getPageSubtitle(widget.selectedNavMenuItem),
                              style: AirMenuTextStyle.caption.copyWith(
                                color: AirMenuColors.neutral.shade5,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Global search bar in the middle
                        Container(
                          width: 200,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Icon(
                                Icons.search,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Search anything...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '⌘K',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Notification bell
                        Stack(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDC2626),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        const ProfileMenu(),
                      ],
                    ),
                  ),
                // Main content area
                Expanded(
                  child: Container(
                    color: _backgroundColor,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavMenuSelection(BuildContext context, NavMenuItem menuItem) {
    _navigateToRoute(context, menuItem);
  }

  void _navigateToRoute(BuildContext context, NavMenuItem menuItem) {
    switch (menuItem) {
      case NavMenuItem.dashboard:
        GoRouter.of(context).go(AppRoutes.dashboard.path);
        break;
      case NavMenuItem.myKyc:
        GoRouter.of(context).go(AppRoutes.myKyc.path);
        break;
      case NavMenuItem.purchasePackage:
        GoRouter.of(context).go(AppRoutes.purchasePackage.path);
        break;
      case NavMenuItem.platformActivity:
        GoRouter.of(context).go(AppRoutes.platformActivity.path);
        break;
      case NavMenuItem.aiPredictions:
        GoRouter.of(context).go(AppRoutes.aiPredictions.path);
        break;
      case NavMenuItem.aiSuggestions:
        GoRouter.of(context).go(AppRoutes.aiSuggestions.path);
        break;
      case NavMenuItem.category:
        GoRouter.of(context).go(AppRoutes.category.path);
        break;
      case NavMenuItem.banner:
        GoRouter.of(context).go(AppRoutes.banner.path);
        break;
      case NavMenuItem.restaurants:
        GoRouter.of(context).go(AppRoutes.restaurants.path);
        break;
      case NavMenuItem.malls:
        GoRouter.of(context).go(AppRoutes.malls.path);
        break;
      case NavMenuItem.orders:
        GoRouter.of(context).go(AppRoutes.orders.path);
        break;
      case NavMenuItem.kitchenPanel:
        GoRouter.of(context).go(AppRoutes.kitchenPanel.path);
        break;
      case NavMenuItem.tables:
        GoRouter.of(context).go(AppRoutes.tables.path);
        break;
      case NavMenuItem.onboardingPipeline:
        GoRouter.of(context).go(AppRoutes.onboardingPipeline.path);
        break;
      case NavMenuItem.staffManagement:
        GoRouter.of(context).go(AppRoutes.staffManagement.path);
        break;
      case NavMenuItem.adminStaffManagement:
        GoRouter.of(context).go(AppRoutes.adminStaffManagement.path);
        break;
      case NavMenuItem.exclusiveOffers:
        GoRouter.of(context).go(AppRoutes.exclusiveOffers.path);
        break;
      case NavMenuItem.payments:
        GoRouter.of(context).go(AppRoutes.payments.path);
        break;

      case NavMenuItem.trialCodes:
        GoRouter.of(context).go(AppRoutes.trialCodes.path);
        break;
      case NavMenuItem.contacts:
        GoRouter.of(context).go(AppRoutes.contacts.path);
        break;
      case NavMenuItem.pricing:
        GoRouter.of(context).go(AppRoutes.pricing.path);
        break;
      case NavMenuItem.blog:
        GoRouter.of(context).go(AppRoutes.blog.path);
        break;
      case NavMenuItem.qrCodes:
        GoRouter.of(context).go(AppRoutes.qrCodes.path);
        break;
      case NavMenuItem.tableManagement:
        GoRouter.of(context).go(AppRoutes.tableManagement.path);
        break;
      case NavMenuItem.faq:
        GoRouter.of(context).go(AppRoutes.faq.path);
        break;
      case NavMenuItem.privacyPolicy:
        GoRouter.of(context).go(AppRoutes.privacyPolicy.path);
        break;
      case NavMenuItem.refundPolicy:
        GoRouter.of(context).go(AppRoutes.refundPolicy.path);
        break;
      case NavMenuItem.termsConditions:
        GoRouter.of(context).go(AppRoutes.termsConditions.path);
        break;
      case NavMenuItem.helpSupport:
        GoRouter.of(context).go(AppRoutes.helpSupport.path);
        break;
      case NavMenuItem.reports:
        GoRouter.of(context).go(AppRoutes.reports.path);
        break;
      case NavMenuItem.coupons:
        GoRouter.of(context).go(AppRoutes.coupons.path);
        break;
      case NavMenuItem.inventory:
        GoRouter.of(context).go(AppRoutes.inventory.path);
        break;
      case NavMenuItem.myAccount:
        GoRouter.of(context).go(AppRoutes.myAccount.path);
        break;

      case NavMenuItem.marketing:
        GoRouter.of(context).go(AppRoutes.marketing.path);
        break;
      case NavMenuItem.signOut:
        GoRouter.of(context).go(AppRoutes.loginAndSignUp.path);
        break;
      case NavMenuItem.settings:
        GoRouter.of(context).go(AppRoutes.settings.path);
        break;
      // New admin features
      case NavMenuItem.adminDashboard:
        GoRouter.of(context).go(AppRoutes.adminDashboard.path);
        break;
      case NavMenuItem.adminOrders:
        GoRouter.of(context).go(AppRoutes.adminOrders.path);
        break;
      case NavMenuItem.adminInventory:
        GoRouter.of(context).go(AppRoutes.adminInventory.path);
        break;
      case NavMenuItem.adminSettings:
        GoRouter.of(context).go(AppRoutes.adminSettings.path);
        break;
      case NavMenuItem.externalIntegrations:
        GoRouter.of(context).go(AppRoutes.externalIntegrations.path);
        break;
      case NavMenuItem.landmark:
        GoRouter.of(context).go(AppRoutes.landmark.path);
        break;
      case NavMenuItem.deliveryPartner:
        GoRouter.of(context).go(AppRoutes.deliveryPartner.path);
        break;
      case NavMenuItem.riders:
        GoRouter.of(context).go(AppRoutes.riders.path);
        break;
      case NavMenuItem.theatre:
        GoRouter.of(context).go(AppRoutes.theatre.path);
        break;
      case NavMenuItem.hotel:
        GoRouter.of(context).go(AppRoutes.hotel.path);
        break;
      // New vendor features
      case NavMenuItem.menu:
        GoRouter.of(context).go(AppRoutes.menu.path);
        break;
      case NavMenuItem.purchaseOrder:
        GoRouter.of(context).go(AppRoutes.purchaseOrder.path);
        break;
      case NavMenuItem.hotelRooms:
        GoRouter.of(context).go(AppRoutes.hotelRooms.path);
        break;
      case NavMenuItem.feedbackRating:
        GoRouter.of(context).go(AppRoutes.feedbackRating.path);
        break;
    }
  }

  // Helper methods for header page title
  String _getPageTitle(NavMenuItem item) {
    switch (item) {
      case NavMenuItem.dashboard:
        return 'Dashboard';
      case NavMenuItem.orders:
        return 'Live Orders';
      case NavMenuItem.kitchenPanel:
        return 'Kitchen Display System';
      case NavMenuItem.tables:
        return 'Tables & QR';
      case NavMenuItem.onboardingPipeline:
        return 'Onboarding Pipeline 🚀';
      case NavMenuItem.restaurants:
        return 'Restaurants';
      case NavMenuItem.category:
        return 'Categories';
      case NavMenuItem.malls:
        return 'Malls';
      case NavMenuItem.banner:
        return 'Banners';
      case NavMenuItem.staffManagement:
        return 'Staff Management';
      case NavMenuItem.adminStaffManagement:
        return 'Admin Staff Management';
      case NavMenuItem.exclusiveOffers:
        return 'Exclusive Offers';
      case NavMenuItem.payments:
        return 'Payments & Settlements';

      case NavMenuItem.trialCodes:
        return 'Trial Codes';
      case NavMenuItem.platformActivity:
        return 'Platform Activity';
      case NavMenuItem.aiPredictions:
        return 'AI Predictions';
      case NavMenuItem.aiSuggestions:
        return 'AI Suggestions';
      default:
        return item.toString().split('.').last;
    }
  }

  String _getPageSubtitle(NavMenuItem item) {
    switch (item) {
      case NavMenuItem.dashboard:
        return 'Overview and analytics';
      case NavMenuItem.orders:
        return 'Real-time order management';
      case NavMenuItem.kitchenPanel:
        return 'KDS and station management';
      case NavMenuItem.tables:
        return 'Manage tables and QR codes';
      case NavMenuItem.onboardingPipeline:
        return 'Track restaurant onboarding progress';
      case NavMenuItem.restaurants:
        return 'Manage your restaurants';
      case NavMenuItem.category:
        return 'Organize menu categories';
      case NavMenuItem.malls:
        return 'Mall management';
      case NavMenuItem.banner:
        return 'Promotional banners';
      case NavMenuItem.payments:
        return 'Manage payouts and disputes';
      case NavMenuItem.aiPredictions:
        return 'AI-powered insights';
      case NavMenuItem.aiSuggestions:
        return 'Smart recommendations';
      case NavMenuItem.platformActivity:
        return 'System activity logs';
      default:
        return '';
    }
  }
}
