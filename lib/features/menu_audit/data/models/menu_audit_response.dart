import 'package:equatable/equatable.dart';

class MenuAuditStats extends Equatable {
  final MenuAuditSummary? summary;
  final List<MenuAuditIssue> issues;

  const MenuAuditStats({this.summary, this.issues = const []});

  MenuAuditStats copyWith({
    MenuAuditSummary? summary,
    List<MenuAuditIssue>? issues,
  }) {
    return MenuAuditStats(
      summary: summary ?? this.summary,
      issues: issues ?? this.issues,
    );
  }

  factory MenuAuditStats.fromJson(Map<String, dynamic> json) {
    return MenuAuditStats(
      summary: json['summary'] != null
          ? MenuAuditSummary.fromJson(json['summary'])
          : null,
      issues: json['issues'] != null
          ? (json['issues'] as List)
                .map((e) => MenuAuditIssue.fromJson(e))
                .toList()
          : [],
    );
  }

  @override
  List<Object?> get props => [summary, issues];
}

class MenuAuditSummary extends Equatable {
  final int totalIssues;
  final int missingImages;
  final int missingPrices;
  final int unmappedItems;

  const MenuAuditSummary({
    this.totalIssues = 0,
    this.missingImages = 0,
    this.missingPrices = 0,
    this.unmappedItems = 0,
  });

  MenuAuditSummary copyWith({
    int? totalIssues,
    int? missingImages,
    int? missingPrices,
    int? unmappedItems,
  }) {
    return MenuAuditSummary(
      totalIssues: totalIssues ?? this.totalIssues,
      missingImages: missingImages ?? this.missingImages,
      missingPrices: missingPrices ?? this.missingPrices,
      unmappedItems: unmappedItems ?? this.unmappedItems,
    );
  }

  factory MenuAuditSummary.fromJson(Map<String, dynamic> json) {
    return MenuAuditSummary(
      totalIssues: json['totalIssues'] ?? 0,
      missingImages: json['missingImages'] ?? 0,
      missingPrices: json['missingPrices'] ?? 0,
      unmappedItems: json['unmappedItems'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    totalIssues,
    missingImages,
    missingPrices,
    unmappedItems,
  ];
}

class MenuAuditIssue extends Equatable {
  final String? restaurantId;
  final String? restaurantName;
  final String? itemId;
  final String? itemName;
  final String? issueDescription;
  final String? category; // "Media", "Pricing", etc. (Info only)
  final String? severity; // "High", "Medium", "Low"
  final String? actionUrl;

  const MenuAuditIssue({
    this.restaurantId,
    this.restaurantName,
    this.itemId,
    this.itemName,
    this.issueDescription,
    this.category,
    this.severity,
    this.actionUrl,
  });

  MenuAuditIssue copyWith({
    String? restaurantId,
    String? restaurantName,
    String? itemId,
    String? itemName,
    String? issueDescription,
    String? category,
    String? severity,
    String? actionUrl,
  }) {
    return MenuAuditIssue(
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      issueDescription: issueDescription ?? this.issueDescription,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  factory MenuAuditIssue.fromJson(Map<String, dynamic> json) {
    return MenuAuditIssue(
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
      itemId: json['itemId'],
      itemName: json['itemName'],
      issueDescription: json['issueDescription'],
      category: json['category'],
      severity: json['severity'],
      actionUrl: json['actionUrl'],
    );
  }

  @override
  List<Object?> get props => [
    restaurantId,
    restaurantName,
    itemId,
    itemName,
    issueDescription,
    category,
    severity,
    actionUrl,
  ];
}
