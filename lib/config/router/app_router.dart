import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:airmenuai_partner_app/config/router/nav_menu/nav_menu_item.dart';
import 'package:airmenuai_partner_app/config/router/token_check.dart';
import 'package:airmenuai_partner_app/features/admin_staff_management/presentation/views/admin_staff_management_page.dart';
import 'package:airmenuai_partner_app/features/ai_predictions/presentation/views/ai_predictions_page.dart';
import 'package:airmenuai_partner_app/features/ai_suggestions/presentation/views/ai_suggestions_page.dart';
import 'package:airmenuai_partner_app/features/banner/presentation/views/banner_page.dart';
import 'package:airmenuai_partner_app/features/blog/presentation/views/blog_page.dart';
import 'package:airmenuai_partner_app/features/category/presentation/pages/category_page.dart';
import 'package:airmenuai_partner_app/features/common_shell/app_scaffold_shell.dart';
import 'package:airmenuai_partner_app/features/contacts/presentation/views/contacts_page.dart';
import 'package:airmenuai_partner_app/features/coupons/presentation/views/coupons_page.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:airmenuai_partner_app/features/exclusive_offers/presentation/views/exclusive_offers_page.dart';
import 'package:airmenuai_partner_app/features/faq/presentation/views/faq_page.dart';

import 'package:airmenuai_partner_app/features/help_support/presentation/pages/help_support_page.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/views/inventory_page.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/pages/kitchen_panel_page.dart';
import 'package:airmenuai_partner_app/features/login/presentation/views/login.dart';
import 'package:airmenuai_partner_app/features/malls/presentation/views/malls_page.dart';
import 'package:airmenuai_partner_app/features/my_account/presentation/views/my_account_page.dart';
import 'package:airmenuai_partner_app/features/my_kyc/presentation/views/my_kyc_page.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/pages/order_page.dart';
import 'package:airmenuai_partner_app/features/platform_activity/presentation/pages/platform_activity_page.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/presentation/pages/privacy_policy_page.dart';
import 'package:airmenuai_partner_app/features/pricing/presentation/views/pricing_page.dart';
import 'package:airmenuai_partner_app/features/purchase_package/presentation/views/purchase_package_page.dart';
import 'package:airmenuai_partner_app/features/qr_codes/presentation/views/qr_codes_page.dart';
import 'package:airmenuai_partner_app/features/refund_policy/presentation/pages/refund_policy_page.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/views/reports_page.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/pages/restaurants_page.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/pages/restaurant_details_page.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'package:airmenuai_partner_app/features/payments/presentation/pages/payments_page.dart';
import 'package:airmenuai_partner_app/features/settings/presentation/views/settings_page.dart';
import 'package:airmenuai_partner_app/features/staff_management/presentation/views/staff_management_page.dart';
import 'package:airmenuai_partner_app/features/tables/presentation/pages/tables_page.dart';
import 'package:airmenuai_partner_app/features/table_management/presentation/views/table_management_page.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/presentation/pages/terms_conditions_page.dart';
import 'package:airmenuai_partner_app/features/trial_codes/presentation/views/trial_codes_page.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/pages/onboarding_pipeline_page.dart';

import 'package:airmenuai_partner_app/features/marketing/presentation/pages/marketing_page.dart';
import 'package:airmenuai_partner_app/utils/keys/airmenu_keys.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/admin_settings/presentation/pages/admin_settings_page.dart';
import 'package:airmenuai_partner_app/features/admin_orders/presentation/pages/admin_orders_page.dart';
import 'package:airmenuai_partner_app/features/admin_inventory/presentation/pages/admin_inventory_page.dart';
import 'package:airmenuai_partner_app/features/external_integrations/presentation/pages/external_integrations_page.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/pages/landmark_page.dart';
import 'package:airmenuai_partner_app/features/delivery_partner/presentation/pages/delivery_partner_page.dart';
import 'package:airmenuai_partner_app/features/riders/presentation/pages/riders_page.dart';
import 'package:airmenuai_partner_app/features/theatre/presentation/pages/theatre_page.dart';
import 'package:airmenuai_partner_app/features/hotel/presentation/pages/hotel_page.dart';
import 'package:airmenuai_partner_app/features/menu/presentation/pages/menu_page.dart';
import 'package:airmenuai_partner_app/features/purchase_order/presentation/pages/purchase_order_page.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/presentation/pages/hotel_rooms_page.dart';
import 'package:airmenuai_partner_app/features/feedback_rating/presentation/pages/feedback_rating_page.dart';
import 'package:go_router/go_router.dart';

final _sectionNavigatorKey = GlobalKey<NavigatorState>();

NavMenuItem selectedNavMenuItem = NavMenuItem.dashboard;

class AppRouter {
  final GoRouter _router;

  AppRouter()
    : _router = GoRouter(
        initialLocation: AppRoutes.loginAndSignUp.path,
        redirect: (context, state) async {
          final isAuth = await tokenCheck();
          final isLoginRoute =
              state.matchedLocation == AppRoutes.loginAndSignUp.path;
          final currentPath = state.matchedLocation;

          // Debug logging
          debugPrint(
            '🔄 Router redirect check: isAuth=$isAuth, isLoginRoute=$isLoginRoute, currentPath=$currentPath',
          );

          // If user is authenticated and trying to access login, redirect to dashboard
          if (isAuth && isLoginRoute) {
            debugPrint(
              '✅ Authenticated user on login page, redirecting to dashboard',
            );
            return AppRoutes.dashboard.path;
          }

          // If user is not authenticated and trying to access protected routes, redirect to login
          if (!isAuth && !isLoginRoute) {
            debugPrint(
              '❌ Not authenticated, redirecting to login from $currentPath',
            );
            return AppRoutes.loginAndSignUp.path;
          }

          debugPrint('✅ No redirect needed');
          return null; // No redirect needed
        },
        routes: [
          transitionGoRoute(
            path: AppRoutes.loginAndSignUp.path,
            pageBuilder: (context, state) => LoginScreen(),
          ),
          ShellRoute(
            navigatorKey: _sectionNavigatorKey,
            builder: (context, state, child) {
              return AppScaffoldShell(
                key: AirMenuKey.appScaffoldShell,
                selectedNavMenuItem: selectedNavMenuItem,
                child: child,
              );
            },
            routes: [
              transitionGoRoute(
                path: AppRoutes.dashboard.path,
                pageBuilder: (context, state) => const DashboardPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.dashboard;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.myKyc.path,
                pageBuilder: (context, state) => const MyKycPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.myKyc;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.purchasePackage.path,
                pageBuilder: (context, state) => const PurchasePackagePage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.purchasePackage;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.platformActivity.path,
                pageBuilder: (context, state) => const PlatformActivityPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.platformActivity;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.aiPredictions.path,
                pageBuilder: (context, state) => const AiPredictionsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.aiPredictions;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.aiSuggestions.path,
                pageBuilder: (context, state) => const AiSuggestionsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.aiSuggestions;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.category.path,
                pageBuilder: (context, state) => const CategoryPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.category;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.banner.path,
                pageBuilder: (context, state) => const BannerPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.banner;
                  return null;
                },
              ),
              transitionGoRoute(
                path: '/restaurants/details',
                pageBuilder: (context, state) {
                  final restaurant = state.extra as RestaurantModel;
                  return RestaurantDetailsPage(restaurant: restaurant);
                },
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.restaurants;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.restaurants.path,
                pageBuilder: (context, state) => const RestaurantsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.restaurants;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.payments.path,
                pageBuilder: (context, state) => const PaymentsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.payments;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.malls.path,
                pageBuilder: (context, state) => const MallsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.malls;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.orders.path,
                pageBuilder: (context, state) => const OrdersPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.orders;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.kitchenPanel.path,
                pageBuilder: (context, state) => const KitchenPanelPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.kitchenPanel;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.tables.path,
                pageBuilder: (context, state) => const TablesPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.tables;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.onboardingPipeline.path,
                pageBuilder: (context, state) => const OnboardingPipelinePage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.onboardingPipeline;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.staffManagement.path,
                pageBuilder: (context, state) => const StaffManagementPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.staffManagement;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.adminStaffManagement.path,
                pageBuilder: (context, state) =>
                    const AdminStaffManagementPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.adminStaffManagement;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.exclusiveOffers.path,
                pageBuilder: (context, state) => const ExclusiveOffersPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.exclusiveOffers;
                  return null;
                },
              ),

              transitionGoRoute(
                path: AppRoutes.trialCodes.path,
                pageBuilder: (context, state) => const TrialCodesPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.trialCodes;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.contacts.path,
                pageBuilder: (context, state) => const ContactsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.contacts;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.pricing.path,
                pageBuilder: (context, state) => const PricingPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.pricing;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.blog.path,
                pageBuilder: (context, state) => const BlogPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.blog;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.qrCodes.path,
                pageBuilder: (context, state) => const QrCodesPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.qrCodes;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.tableManagement.path,
                pageBuilder: (context, state) => const TableManagementPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.tableManagement;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.faq.path,
                pageBuilder: (context, state) => const FaqPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.faq;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.privacyPolicy.path,
                pageBuilder: (context, state) => const PrivacyPolicyPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.privacyPolicy;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.refundPolicy.path,
                pageBuilder: (context, state) => const RefundPolicyPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.refundPolicy;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.termsConditions.path,
                pageBuilder: (context, state) => const TermsConditionsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.termsConditions;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.helpSupport.path,
                pageBuilder: (context, state) => const HelpSupportPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.helpSupport;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.reports.path,
                pageBuilder: (context, state) => const ReportsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.reports;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.coupons.path,
                pageBuilder: (context, state) => const CouponsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.coupons;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.inventory.path,
                pageBuilder: (context, state) => const InventoryPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.inventory;
                  return null;
                },
              ),

              transitionGoRoute(
                path: AppRoutes.marketing.path,
                pageBuilder: (context, state) => const MarketingPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.marketing;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.myAccount.path,
                pageBuilder: (context, state) => const MyAccountPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.myAccount;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.settings.path,
                pageBuilder: (context, state) => const SettingsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.settings;
                  return null;
                },
              ),
              // NEW ADMIN PAGES
              transitionGoRoute(
                path: AppRoutes
                    .adminDashboard
                    .path, // Assuming duplicate path with dashboard but distinct Enum
                pageBuilder: (context, state) =>
                    const DashboardPage(), // Reusing DashboardPage for admin
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.adminDashboard;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.adminOrders.path,
                pageBuilder: (context, state) => const AdminOrdersPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.adminOrders;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.adminInventory.path,
                pageBuilder: (context, state) => const AdminInventoryPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.adminInventory;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.adminSettings.path,
                pageBuilder: (context, state) => const AdminSettingsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.adminSettings;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.externalIntegrations.path,
                pageBuilder: (context, state) =>
                    const ExternalIntegrationsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.externalIntegrations;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.landmark.path,
                pageBuilder: (context, state) => const LandmarkPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.landmark;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.deliveryPartner.path,
                pageBuilder: (context, state) => const DeliveryPartnerPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.deliveryPartner;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.riders.path,
                pageBuilder: (context, state) => const RidersPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.riders;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.theatre.path,
                pageBuilder: (context, state) => const TheatrePage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.theatre;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.hotel.path,
                pageBuilder: (context, state) => const HotelPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.hotel;
                  return null;
                },
              ),
              // NEW VENDOR PAGES
              transitionGoRoute(
                path: AppRoutes.menu.path,
                pageBuilder: (context, state) => const MenuPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.menu;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.purchaseOrder.path,
                pageBuilder: (context, state) => const PurchaseOrderPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.purchaseOrder;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.hotelRooms.path,
                pageBuilder: (context, state) => const HotelRoomsPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.hotelRooms;
                  return null;
                },
              ),
              transitionGoRoute(
                path: AppRoutes.feedbackRating.path,
                pageBuilder: (context, state) => const FeedbackRatingPage(),
                redirect: (context, state) {
                  selectedNavMenuItem = NavMenuItem.feedbackRating;
                  return null;
                },
              ),
            ],
          ),
        ],
      );

  GoRouter get router => _router;
}

GoRoute transitionGoRoute({
  required String path,
  required Widget Function(BuildContext, GoRouterState) pageBuilder,
  GoRouterRedirect? redirect,
}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) {
      return CustomTransitionPage<void>(
        key: state.pageKey,
        transitionDuration: const Duration(milliseconds: 0),
        child: pageBuilder(context, state),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    },
    redirect: redirect,
  );
}
