class ApiEndpoints {
  static const String login = "/auth/signin";

  // Platform Activity endpoints
  static const String platformActivitiesAll = "/activities/all";

  //Partner Kyc Desk
  static const String kycAll = "/kyc/all";
  static const String kycMyKyc = "/kyc/my-kyc";
  static const String kycStats = "/kyc/stats";
  static String kycReview(String id) => "/kyc/review/$id";
  static const String kycDelete = "/kyc";

  // KYC Adobe Sign endpoints
  static String kycAdminSigningView(String id) => "/kyc/$id/adobe/admin-view";
  static String kycAdobeSync(String id) => "/kyc/$id/adobe/sync";

  // Policy Pages endpoints
  static const String privacyPolicy = "/privacy-policy";
  static const String refundPolicy = "/refund-policy";
  static const String termsConditions = "/terms-conditions";
  static const String helpSupport = "/help-support";
  static const String generateDocument = "/ai/generate-document";
  // Order endpoints
  static const String orders = "/orders";
  static const String orderStats = "/orders/order-stats";
  static const String kitchenOrders = "/orders/kitchen";
  static const String kitchenStats = "/orders/kitchen/stats";
  static String orderStartPrep(String id) => "/orders/$id/start";
  static String orderMarkReady(String id) => "/orders/$id/ready";
  static String orderCancel(String id) => "/orders/$id/cancel";

  // Kitchen Load endpoints
  static String kitchenStatsComparison(String hotelId) =>
      "/kitchen-load/stats-comparison/$hotelId";
  static String kitchenConfig(String hotelId) => "/kitchen-config/$hotelId";

  // Cart endpoints
  static const String cart = "/cart";

  // Table Bookings endpoints
  static const String tableBookings = "/table-bookings";
  static const String tableBookingsAdmin = "/table-bookings/admin";
  static String tableBookingsCancel(String id) => "/table-bookings/$id/cancel";
  static String tableBookingsAvailableTables(String hotelId) =>
      "/table-bookings/hotel/$hotelId/available-tables";
  static String tableBookingsAssignTable(String id) =>
      "/table-bookings/$id/assign-table";
  static String tableBookingsUnassignTable(String id) =>
      "/table-bookings/$id/unassign-table";

  // Hotels endpoints
  static const String hotels = "/hotels";

  // Hotel Booking Settings endpoints
  static String hotelBookingSettings(String hotelId) =>
      "/hotel-booking-settings/$hotelId?includeDraft=true";
  static String hotelBookingSettingsSaveDraft(String hotelId) =>
      "/hotel-booking-settings/$hotelId?saveAsDraft=true";
  static String hotelBookingSettingsSaveLive(String hotelId) =>
      "/hotel-booking-settings/$hotelId";
  static String hotelBookingSettingsPublishDraft(String hotelId) =>
      "/hotel-booking-settings/$hotelId/publish-draft";

  // Admin Dashboard endpoints
  static const String adminDashboard = "/dashboard/admin";
  static const String adminTopRestaurants = "/dashboard/admin/top-restaurants";
  // Vendor Dashboard endpoints
  static const String vendorDashboardStats = "/orders/dashboard-stats";
  // Note: orderStats is already defined as "/orders/order-stats"
  static const String vendorOrdersOverTime =
      "/orders/stats/distribution"; // Pending
  static const String vendorCategoryPerformance =
      "/orders/stats/categories"; // Pending
  static const String vendorRecentOrders = "/orders/recent"; // Pending
  static const String vendorBranches = "/hotels"; // Changed from /hotels/list
  static const String adminOrdersByType =
      "/dashboard/admin/charts/orders-by-type";
  static const String adminKitchenLoad = "/dashboard/admin/charts/kitchen-load";
  static const String adminRestaurantPerformance =
      "/dashboard/admin/charts/restaurant-performance";
  static const String adminRiderSLA = "/dashboard/admin/charts/rider-sla";
  static const String adminAlerts = "/dashboard/admin/alerts";
  static const String adminActivities = "/dashboard/admin/activities";

  // Admin Restaurants endpoints
  static const String adminRestaurants = "/restaurants/admin";
  static const String adminRestaurantStats = "/restaurants/admin/stats";
  static String adminRestaurantDetails(String id) => "/restaurants/admin/$id";
  static String adminRestaurantUpdateStatus(String id) =>
      "/restaurants/admin/$id/status";

  // Places endpoints
  static const String placesAutocomplete = "/places/autocomplete";

  // Marketing/Offers endpoints
  static const String couponsAdmin = "/coupons/admin";
  static const String couponsVendor = "/coupons/vendor";
  static const String coupons = "/coupons";
  static String couponById(String id) => "/coupons/$id";
  static String couponAdminById(String id) => "/coupons/admin/$id";

  // Hotel Offers endpoints
  static String hotelOffers(String hotelId) => "/hotel-offers/hotel/$hotelId";
  static const String hotelOffersCreate = "/hotel-offers/create";
  static String hotelOfferById(String id) => "/hotel-offers/$id";
  static String hotelOfferToggleStatus(String id) =>
      "/hotel-offers/$id/toggle-status";

  // Combos endpoints
  static String combos(String hotelId) => "/combos/hotel/$hotelId";
  static const String combosCreate = "/combos/create";
  static String comboById(String id) => "/combos/$id";
  static String comboToggleStatus(String id) => "/combos/$id/toggle-status";

  // Hotel Buffets endpoints
  static String hotelBuffets(String hotelId) => "/hotels/$hotelId/buffets";
  static String hotelBuffet(String hotelId, String buffetId) => "/hotels/$hotelId/buffets/$buffetId";

  // Hotel Gallery endpoints
  static String hotelGallery(String hotelId) => "/hotels/$hotelId/gallery";
  static String hotelGalleryImage(String hotelId) => "/hotels/$hotelId/gallery/remove";

  // Hotel Reviews endpoints
  static String hotelReviews(String hotelId) => "/hotels/$hotelId/reviews";

  // Hotel Offers endpoints (restaurant offers)
  static String hotelOffersData(String hotelId) => "/hotels/$hotelId/offers";

  // Hotel About Info endpoints
  static String hotelAboutInfo(String hotelId) => "/hotels/$hotelId/about";

  // Menu endpoints
  static String hotelMenu(String hotelId) => "/hotels/$hotelId/menu";
  static String menuCategories(String hotelId) => "/hotels/$hotelId/menu-categories";
  static String menuCategory(String hotelId, String categoryName) =>
      "/hotels/$hotelId/menu-categories/$categoryName";
  static String menuCategoryItems(String hotelId, String categoryName) =>
      "/hotels/$hotelId/menu-categories/$categoryName/items";
  static String foodItem(String hotelId, String foodId) =>
      "/hotels/$hotelId/food/$foodId";
  static String menuSettings(String hotelId) => "/hotels/$hotelId/menu-settings";

  // AI Menu endpoints
  static const String extractMenuFromImage = "/ai/extract-menu-from-image";
  static const String importExtractedMenu = "/ai/import-extracted-menu";

  // Kitchen Management endpoints
  static String kitchenStations(String hotelId) => "/kitchen/stations/hotel/$hotelId";
  static String kitchenStation(String stationId) => "/kitchen/stations/$stationId";
  static String kitchenStationAdjust(String stationId) => "/kitchen/stations/$stationId/adjust-slots";
  static String kitchenConfiguration(String hotelId) => "/kitchen-config/$hotelId";
  static String kitchenConfigurationReset(String hotelId) => "/kitchen/config/$hotelId/reset";
  static String kitchenStatus(String hotelId) => "/kitchen-load/status/$hotelId";
  static String kitchenInitialize(String hotelId) => "/kitchen/stations/$hotelId/initialize";
}
