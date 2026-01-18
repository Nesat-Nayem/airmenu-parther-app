import 'package:flutter/widgets.dart';

class AirMenuKey {
  static Key appScaffoldShell = UniqueKey();
  static Login loginScreenKey = Login();
  static Dashboard dashboardKey = Dashboard();
  static HelpSupport helpSupportKey = HelpSupport();
  static PrivacyPolicy privacyPolicyKey = PrivacyPolicy();
  static RefundPolicy refundPolicyKey = RefundPolicy();
  static TermsConditions termsConditionsKey = TermsConditions();
  static Restaurants restaurantsKey = Restaurants();
}

class Login {
  Key loginScreen = UniqueKey();
  Key loginDesktopView = UniqueKey();
}

class Dashboard {
  Key dashboardResponsiveScreen = UniqueKey();
}

class HelpSupport {
  Key helpSupportResponsiveScreen = UniqueKey();
}

class PrivacyPolicy {
  Key privacyPolicyResponsiveScreen = UniqueKey();
}

class RefundPolicy {
  Key refundPolicyResponsiveScreen = UniqueKey();
}

class TermsConditions {
  Key termsConditionsResponsiveScreen = UniqueKey();
}

class Restaurants {
  Key restaurantsResponsiveScreen = UniqueKey();
}
