import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item_config.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:flutter/material.dart';

// Enum for main side navigation items
enum NavMenuItem {
  // === ADMIN FEATURES ===
  onboardingPipeline, // Onboarding
  adminDashboard, // SuperAdmin Dashboard
  restaurants, // Restaurant Overview
  adminOrders, // Admin Live Orders
  payments, // Payments
  exclusiveOffers, // Offers (Admin)
  adminSettings, // User Settings (Admin)
  externalIntegrations, // External Integrations
  landmark, // Landmark
  deliveryPartner, // Delivery Partner
  riders, // Riders
  theatre, // Theatre
  hotel, // Hotel
  // === VENDOR FEATURES ===
  dashboard, // Dashboard
  orders, // Vendor Live Orders
  menu, // Menu
  purchaseOrder, // Purchase Order
  kitchenPanel, // Kitchen Panel
  tables, // Tables and QR
  hotelRooms, // Hotel Rooms
  staffManagement, // Staff Management
  coupons, // Offers (Vendor coupons)
  feedbackRating, // Feedback & Rating
  reports, // Report
  settings, // Settings
  inventory, // Inventory
  // === LEGACY/UTILITY (keep for compatibility) ===
  myKyc,
  purchasePackage,
  platformActivity,
  aiPredictions,
  aiSuggestions,
  category,
  banner,
  malls,
  adminStaffManagement,
  trialCodes,
  contacts,
  pricing,
  blog,
  qrCodes,
  tableManagement,
  faq,
  privacyPolicy,
  refundPolicy,
  termsConditions,
  helpSupport,
  myAccount,
  signOut,
  marketing,
}

// Main side navigation routes - ordered by role and importance
const List<NavMenuItem> sideNavRoutes = [
  // Admin features
  NavMenuItem.adminDashboard,
  NavMenuItem.onboardingPipeline,
  NavMenuItem.restaurants,
  NavMenuItem.adminOrders,
  NavMenuItem.payments,
  NavMenuItem.marketing,
  NavMenuItem.adminSettings,
  NavMenuItem.externalIntegrations,
  NavMenuItem.landmark,
  NavMenuItem.deliveryPartner,
  NavMenuItem.riders,
  NavMenuItem.theatre,
  NavMenuItem.hotel,

  // Vendor features (in order: Dashboard, Live Orders, Menu, Inventory, Purchase Order, Kitchen Panel, Tables & QR, Hotel Rooms, Staff Management, Offers, Feedback & Rating, Report, Settings)
  NavMenuItem.dashboard,
  NavMenuItem.orders,
  NavMenuItem.menu,
  NavMenuItem.inventory,
  NavMenuItem.kitchenPanel,
  NavMenuItem.tables,
  NavMenuItem.hotelRooms,
  NavMenuItem.staffManagement,
  NavMenuItem.coupons,
  NavMenuItem.feedbackRating,
  NavMenuItem.reports,
  NavMenuItem.settings,
];

// Footer navigation routes
const List<NavMenuItem> utilityNavMenuItem = [
  // NavMenuItem.myAccount,
  // NavMenuItem.settings,
  // NavMenuItem.signOut,
];

// Extension for main navigation items
extension NavMenuItemExtension on NavMenuItem {
  NavMenuItemConfig<NavMenuItem> toNavMenuItemConfig() {
    return NavMenuItemConfig(
      key: getKey(),
      type: this,
      iconSize: 24,
      iconData: getIcon(),
      title: getTitle(),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      borderRadius: BorderRadius.circular(8),
      activeColor: const Color(0xFFE0E6ED), // Light gray/blueish background
      activeContentColor: AirMenuColors.black, // Dark text for active
      inactiveColor: Colors.transparent, // Transparent for inactive
      inactiveContentColor: AirMenuColors.black,
    ); // Dark text for inactive
  }

  IconData getIcon() {
    switch (this) {
      // Admin features
      case NavMenuItem.onboardingPipeline:
        return Icons.rocket_launch_rounded;
      case NavMenuItem.adminDashboard:
        return Icons.dashboard_rounded;
      case NavMenuItem.restaurants:
        return Icons.storefront_rounded;
      case NavMenuItem.adminOrders:
        return Icons.receipt_long_rounded;
      case NavMenuItem.payments:
        return Icons.payment_rounded;
      case NavMenuItem.exclusiveOffers:
        return Icons.local_offer_rounded;
      case NavMenuItem.adminSettings:
        return Icons.settings_rounded;
      case NavMenuItem.externalIntegrations:
        return Icons.integration_instructions_rounded;
      case NavMenuItem.landmark:
        return Icons.place_rounded;
      case NavMenuItem.deliveryPartner:
        return Icons.local_shipping_rounded;
      case NavMenuItem.riders:
        return Icons.two_wheeler_rounded;
      case NavMenuItem.theatre:
        return Icons.theaters_rounded;
      case NavMenuItem.hotel:
        return Icons.hotel_rounded;

      // Vendor features
      case NavMenuItem.dashboard:
        return Icons.dashboard_rounded;
      case NavMenuItem.orders:
        return Icons.receipt_long_rounded;
      case NavMenuItem.menu:
        return Icons.restaurant_menu_rounded;
      case NavMenuItem.purchaseOrder:
        return Icons.shopping_cart_rounded;
      case NavMenuItem.kitchenPanel:
        return Icons.kitchen_rounded;
      case NavMenuItem.tables:
        return Icons.table_bar_rounded;
      case NavMenuItem.hotelRooms:
        return Icons.bed_rounded;
      case NavMenuItem.staffManagement:
        return Icons.groups_rounded;
      case NavMenuItem.coupons:
        return Icons.confirmation_number_rounded;
      case NavMenuItem.feedbackRating:
        return Icons.star_rounded;
      case NavMenuItem.reports:
        return Icons.bar_chart_rounded;
      case NavMenuItem.settings:
        return Icons.settings_rounded;
      case NavMenuItem.inventory:
        return Icons.inventory_2_rounded;

      // Legacy/Utility items
      case NavMenuItem.myKyc:
        return Icons.verified_user_rounded;
      case NavMenuItem.purchasePackage:
        return Icons.card_giftcard_rounded;
      case NavMenuItem.platformActivity:
        return Icons.timeline_rounded;
      case NavMenuItem.aiPredictions:
        return Icons.auto_graph_rounded;
      case NavMenuItem.aiSuggestions:
        return Icons.psychology_rounded;
      case NavMenuItem.category:
        return Icons.category_rounded;
      case NavMenuItem.banner:
        return Icons.image_rounded;
      case NavMenuItem.malls:
        return Icons.business_rounded;
      case NavMenuItem.adminStaffManagement:
        return Icons.manage_accounts_rounded;
      case NavMenuItem.trialCodes:
        return Icons.confirmation_number_rounded;
      case NavMenuItem.contacts:
        return Icons.contacts_rounded;
      case NavMenuItem.pricing:
        return Icons.attach_money_rounded;
      case NavMenuItem.blog:
        return Icons.article_rounded;
      case NavMenuItem.qrCodes:
      case NavMenuItem.tableManagement:
        return Icons.qr_code_rounded;
      case NavMenuItem.faq:
        return Icons.help_outline_rounded;
      case NavMenuItem.privacyPolicy:
        return Icons.privacy_tip_rounded;
      case NavMenuItem.refundPolicy:
        return Icons.currency_exchange_rounded;
      case NavMenuItem.termsConditions:
        return Icons.description_rounded;
      case NavMenuItem.helpSupport:
        return Icons.support_agent_rounded;
      case NavMenuItem.marketing:
        return Icons.campaign_rounded;
      case NavMenuItem.myAccount:
        return Icons.account_circle_rounded;
      case NavMenuItem.signOut:
        return Icons.logout_rounded;
    }
  }

  String getTitle() {
    switch (this) {
      // Admin features
      case NavMenuItem.onboardingPipeline:
        return 'Onboarding';
      case NavMenuItem.adminDashboard:
        return 'Dashboard';
      case NavMenuItem.restaurants:
        return 'Restaurants Overview';
      case NavMenuItem.adminOrders:
        return 'Live Orders';
      case NavMenuItem.payments:
        return 'Payments';
      case NavMenuItem.exclusiveOffers:
        return 'Offers';
      case NavMenuItem.adminSettings:
        return 'User Settings';
      case NavMenuItem.externalIntegrations:
        return 'External Integrations';
      case NavMenuItem.landmark:
        return 'Landmark';
      case NavMenuItem.deliveryPartner:
        return 'Delivery Partner';
      case NavMenuItem.riders:
        return 'Riders';
      case NavMenuItem.theatre:
        return 'Theatre';
      case NavMenuItem.hotel:
        return 'Hotel';

      // Vendor features
      case NavMenuItem.dashboard:
        return 'Dashboard';
      case NavMenuItem.orders:
        return 'Live Orders';
      case NavMenuItem.menu:
        return 'Menu';
      case NavMenuItem.purchaseOrder:
        return 'Purchase Order';
      case NavMenuItem.kitchenPanel:
        return 'Kitchen Panel';
      case NavMenuItem.tables:
        return 'Tables & QR';
      case NavMenuItem.hotelRooms:
        return 'Hotel Rooms';
      case NavMenuItem.staffManagement:
        return 'Staff Management';
      case NavMenuItem.coupons:
        return 'Offers';
      case NavMenuItem.feedbackRating:
        return 'Feedback & Rating';
      case NavMenuItem.reports:
        return 'Reports';
      case NavMenuItem.settings:
        return 'Settings';
      case NavMenuItem.inventory:
        return 'Inventory';

      // Legacy items
      case NavMenuItem.myKyc:
        return 'My KYC';
      case NavMenuItem.purchasePackage:
        return 'Purchase Package';
      case NavMenuItem.platformActivity:
        return 'Platform Activity';
      case NavMenuItem.aiPredictions:
        return 'AI Predictions';
      case NavMenuItem.aiSuggestions:
        return 'AI Suggestions';
      case NavMenuItem.category:
        return 'Category';
      case NavMenuItem.banner:
        return 'Banner';
      case NavMenuItem.malls:
        return 'Malls';
      case NavMenuItem.adminStaffManagement:
        return 'Admin Staff Management';
      case NavMenuItem.trialCodes:
        return 'Trial Codes';
      case NavMenuItem.contacts:
        return 'Contacts';
      case NavMenuItem.pricing:
        return 'Pricing';
      case NavMenuItem.blog:
        return 'Blog';
      case NavMenuItem.qrCodes:
        return 'Table QR Codes';
      case NavMenuItem.tableManagement:
        return 'Table Management';
      case NavMenuItem.faq:
        return 'FAQ';
      case NavMenuItem.privacyPolicy:
        return 'Privacy Policy';
      case NavMenuItem.refundPolicy:
        return 'Refund Policy';
      case NavMenuItem.termsConditions:
        return 'Terms Conditions';
      case NavMenuItem.helpSupport:
        return 'Help & Support';
      case NavMenuItem.marketing:
        return 'Offers';
      case NavMenuItem.myAccount:
        return 'My Account';
      case NavMenuItem.signOut:
        return 'Sign Out';
    }
  }

  Key getKey() {
    return Key('${name.toLowerCase()}-nav-menu');
  }
}
