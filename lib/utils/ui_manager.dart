// Imports are maintained, only need flutter/material and dart:math
import 'dart:math';
import 'package:flutter/material.dart';

// Alternative Name: LayoutManager (Focuses on Spacing and Sizing)
class UIManager {
  
  // ===============================================
  // 1. SPACING CONSTANTS (Defined as doubles)
  // These doubles are used by the helper functions below.
  // ===============================================

  static const double spaceTiny = 5.0;
  static const double spaceSmall = 10.0;
  static const double spaceRegular = 15.0;
  static const double spaceSmallRegular = 20.0;
  static const double spaceMedium = 30.0;
  static const double spaceLarge = 35.0;
  static const double spaceHuge = 300.0;

  // ===============================================
  // 2. SPACING WIDGET GENERATORS (Functions for better performance)
  // ===============================================

  /// Returns a vertical SizedBox with the given height.
  static Widget verticalSpace(double height) => SizedBox(height: height);

  /// Returns a horizontal SizedBox with the given width.
  static Widget horizontalSpace(double width) => SizedBox(width: width);

  // Quick access to commonly used spaces:
  static Widget get verticalSpaceTiny => verticalSpace(spaceTiny);
  static Widget get verticalSpaceSmall => verticalSpace(spaceSmall);
  static Widget get verticalSpaceRegular => verticalSpace(spaceRegular);
  static Widget get verticalSpaceMedium => verticalSpace(spaceMedium);
  static Widget get verticalSpaceLarge => verticalSpace(spaceLarge);
  
  static Widget get horizontalSpaceTiny => horizontalSpace(spaceTiny);
  static Widget get horizontalSpaceSmall => horizontalSpace(spaceSmall);
  static Widget get horizontalSpaceRegular => horizontalSpace(spaceRegular);
  static Widget get horizontalSpaceMedium => horizontalSpace(spaceMedium);
  static Widget get horizontalSpaceLarge => horizontalSpace(spaceLarge);

  // ===============================================
  // 3. MEDIA QUERY HELPERS (Screen Geometry)
  // ===============================================

  /// Returns the total screen width.
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Returns the total screen height.
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Returns a fractional part of the screen width (e.g., 0.5 for half, 0.25 for a quarter).
  static double screenWidthFraction(
    BuildContext context, {
    double fraction = 1,
  }) =>
      screenWidth(context) * fraction;

  /// Returns a fractional part of the screen height (e.g., 0.5 for half, 0.25 for a quarter).
  static double screenHeightFraction(
    BuildContext context, {
    double fraction = 1,
  }) =>
      screenHeight(context) * fraction;

  // Convenience getters (using the new fractional helpers)
  static double halfScreenWidth(BuildContext context) =>
      screenWidthFraction(context, fraction: 0.5);

  static double halfScreenHeight(BuildContext context) =>
      screenHeightFraction(context, fraction: 0.5);
      
  // ===============================================
  // 4. DIVIDERS & MISC UI
  // ===============================================

  /// A standard grey divider for separating list items.
  static Widget listDivider = const Divider(
    color: Colors.grey,
    thickness: 1,
  );

  /// Returns a Divider wrapped in vertical space.
  static Widget spacedDivider({required double spaceHeight}) {
    return Column(
      children: <Widget>[
        verticalSpace(spaceTiny), // Top buffer
        Divider(height: spaceHeight, color: Colors.grey),
        verticalSpace(spaceTiny), // Bottom buffer
      ],
    );
  }

  // ===============================================
  // 5. RESPONSIVE TEXT SIZE
  // ===============================================
  
  /// Calculates a responsive font size based on screen width, 
  /// with an optional maximum size cap.
  static double getResponsiveFontSize(
    BuildContext context, {
    required double baseSize, // The desired size in a standard view
    double maxScale = 100, // Maximum allowed size
  }) {
    // Calculates a size relative to the screen width, then caps it at the max.
    // The formula (baseSize / 100) is a quick way to scale the base size.
    var calculatedSize = screenWidthFraction(context, fraction: 0.01) * baseSize;

    return min(calculatedSize, maxScale);
  }
}
