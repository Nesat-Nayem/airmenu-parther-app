import 'package:flutter/material.dart';

/// A <E> generic enum is required that exhaustively represents all the menu
/// options.
class NavMenuItemConfig<E extends Enum> {
  NavMenuItemConfig({
    this.key,
    required this.type,
    this.contentSpacing = 15.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.iconSize = 14.0,
    this.padding = const EdgeInsets.only(
      left: 15.0,
      right: 15.0,
    ),
    this.iconData,
    required this.title,
    this.contentPadding = const EdgeInsets.only(
      left: 15,
      right: 15,
    ),
    this.activeColor = const Color(0xFFe6e6e6),
    this.inactiveColor,
    this.activeContentColor = const Color(0xFF303030),
    Color? inactiveContentColor,
    this.height = 50.0,
  }) : inactiveContentColor = inactiveContentColor ?? Colors.grey.shade700;

  /// Key for Widget
  Key? key;

  /// An Enum that represents the item.
  final E type;

  /// Background border radius
  final BorderRadius borderRadius;

  /// Spacing between icon and text for content
  final double contentSpacing;

  /// Padding of content view items
  final EdgeInsets contentPadding;

  /// Item icon size
  final double iconSize;

  /// Item `IconData`
  final IconData? iconData;

  /// Item title text
  final String title;

  /// Background color when selected
  final Color activeColor;

  /// Background color when not selected
  final Color? inactiveColor;

  /// Color of icon and text when selected
  final Color activeContentColor;

  /// Color of icon and text when not selected
  final Color inactiveContentColor;

  /// Padding applied to item's content view
  final EdgeInsets padding;

  /// The height of the item
  final double height;
}
