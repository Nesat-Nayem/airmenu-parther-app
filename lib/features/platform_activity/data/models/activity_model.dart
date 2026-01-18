class PlatformActivityResponse {
  final List<ActivityModel> activities;
  final ActivitySummary summary;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PlatformActivityResponse({
    required this.activities,
    required this.summary,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PlatformActivityResponse.fromJson(Map<String, dynamic> json) {
    return PlatformActivityResponse(
      activities:
          (json['activities'] as List<dynamic>?)
              ?.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: ActivitySummary.fromJson(json['summary'] ?? {}),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class ActivityModel {
  final String id;
  final String actorId;
  final String actorName;
  final String actorRole;
  final String action;
  final String entityType;
  final String entityId;
  final String entityName;
  final String description;
  final Map<String, dynamic> metadata;
  final String timestamp;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  ActivityModel({
    required this.id,
    required this.actorId,
    required this.actorName,
    required this.actorRole,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    required this.description,
    required this.metadata,
    required this.timestamp,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['_id'] ?? '',
      actorId: json['actorId'] ?? '',
      actorName: json['actorName'] ?? '',
      actorRole: json['actorRole'] ?? '',
      action: json['action'] ?? '',
      entityType: json['entityType'] ?? '',
      entityId: json['entityId'] ?? '',
      entityName: json['entityName'] ?? '',
      description: json['description'] ?? '',
      metadata: json['metadata'] ?? {},
      timestamp: json['timestamp'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class ActivitySummary {
  final int totalActivities;
  final int todayActivities;
  final int weeklyActivities;
  final Map<String, int> actionBreakdown;
  final Map<String, int> entityTypeBreakdown;

  ActivitySummary({
    required this.totalActivities,
    required this.todayActivities,
    required this.weeklyActivities,
    required this.actionBreakdown,
    required this.entityTypeBreakdown,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      totalActivities: json['totalActivities'] ?? 0,
      todayActivities: json['todayActivities'] ?? 0,
      weeklyActivities: json['weeklyActivities'] ?? 0,
      actionBreakdown: Map<String, int>.from(json['actionBreakdown'] ?? {}),
      entityTypeBreakdown: Map<String, int>.from(
        json['entityTypeBreakdown'] ?? {},
      ),
    );
  }
}
