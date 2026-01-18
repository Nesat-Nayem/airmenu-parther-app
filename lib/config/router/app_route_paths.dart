// Define an enum for your routes
enum AppRoutes {
  loginAndSignUp,
  signOut,
  settings,
  dashboard,
  myKyc,
  purchasePackage,
  platformActivity,
  aiPredictions,
  aiSuggestions,
  category,
  banner,
  restaurants,
  payments,
  malls,
  orders,
  kitchenPanel,
  onboardingPipeline,
  vendorKycList,
  tableBookings,
  addTableInfo,
  staffManagement,
  adminStaffManagement,
  exclusiveOffers,

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
  reports,
  coupons,
  inventory,
  tables,
  myAccount,
  marketing,
  // New admin features
  adminDashboard,
  adminOrders,
  adminInventory,
  adminSettings,
  externalIntegrations,
  landmark,
  deliveryPartner,
  riders,
  theatre,
  hotel,
  // New vendor features
  menu,
  purchaseOrder,
  hotelRooms,
  feedbackRating,
}

extension RouterExt on AppRoutes {
  // Provide the path for each route
  String get path {
    switch (this) {
      case AppRoutes.tables:
        return "/tables";
      case AppRoutes.loginAndSignUp:
        return "/login";
      case AppRoutes.signOut:
        return "/sign-out";
      case AppRoutes.settings:
        return "/settings";
      case AppRoutes.dashboard:
        return "/dashboard";
      case AppRoutes.myKyc:
        return "/kyc";
      case AppRoutes.purchasePackage:
        return "/package-purchase";
      case AppRoutes.platformActivity:
        return "/platform-activity";
      case AppRoutes.aiPredictions:
        return "/ai-predictions";
      case AppRoutes.aiSuggestions:
        return "/ai-suggestions";
      case AppRoutes.category:
        return "/apps/category";
      case AppRoutes.banner:
        return "/banner";
      case AppRoutes.restaurants:
        return "/restaurants";
      case AppRoutes.payments:
        return "/payments";
      case AppRoutes.malls:
        return "/malls";
      case AppRoutes.orders:
        return "/order";
      case AppRoutes.kitchenPanel:
        return "/kitchen";
      case AppRoutes.onboardingPipeline:
        return "/onboarding-pipeline";
      case AppRoutes.vendorKycList:
        return "/partner-kyc-desk";
      case AppRoutes.tableBookings:
        return "/table-booking";
      case AppRoutes.addTableInfo:
        return "/add-table-info";
      case AppRoutes.staffManagement:
        return "/staff-management";
      case AppRoutes.adminStaffManagement:
        return "/admin-staff-management";
      case AppRoutes.exclusiveOffers:
        return "/exclusive-offers";

      case AppRoutes.trialCodes:
        return "/trial-codes";
      case AppRoutes.contacts:
        return "/apps/contacts";
      case AppRoutes.pricing:
        return "/pricing";
      case AppRoutes.blog:
        return "/blog";
      case AppRoutes.qrCodes:
        return "/qrcodes";
      case AppRoutes.tableManagement:
        return "/table-management";
      case AppRoutes.faq:
        return "/faq";
      case AppRoutes.privacyPolicy:
        return "/privacy-policy";
      case AppRoutes.refundPolicy:
        return "/refund-policy";
      case AppRoutes.termsConditions:
        return "/terms-conditions";
      case AppRoutes.helpSupport:
        return "/help-support";
      case AppRoutes.reports:
        return "/reports";
      case AppRoutes.coupons:
        return "/coupons";
      case AppRoutes.inventory:
        return "/inventory";
      case AppRoutes.myAccount:
        return "/my-account";
      case AppRoutes.marketing:
        return "/marketing";
      // New admin features
      case AppRoutes.adminDashboard:
        return "/admin-dashboard";
      case AppRoutes.adminOrders:
        return "/admin-orders";
      case AppRoutes.adminInventory:
        return "/admin-inventory";
      case AppRoutes.adminSettings:
        return "/admin-settings";
      case AppRoutes.externalIntegrations:
        return "/external-integrations";
      case AppRoutes.landmark:
        return "/landmark";
      case AppRoutes.deliveryPartner:
        return "/delivery-partner";
      case AppRoutes.riders:
        return "/riders";
      case AppRoutes.theatre:
        return "/theatre";
      case AppRoutes.hotel:
        return "/hotel";
      // New vendor features
      case AppRoutes.menu:
        return "/menu";
      case AppRoutes.purchaseOrder:
        return "/purchase-order";
      case AppRoutes.hotelRooms:
        return "/hotel-rooms";
      case AppRoutes.feedbackRating:
        return "/feedback-rating";
    }
  }
}
