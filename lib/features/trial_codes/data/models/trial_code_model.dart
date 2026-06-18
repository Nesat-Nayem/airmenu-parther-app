class TrialCodeModel {
  final String code;
  final int validDays;
  final int? maxUses;
  final int usedCount;
  final bool isActive;
  final DateTime? expiresAt;

  const TrialCodeModel({
    required this.code,
    required this.validDays,
    this.maxUses,
    this.usedCount = 0,
    this.isActive = true,
    this.expiresAt,
  });

  factory TrialCodeModel.fromJson(Map<String, dynamic> json) {
    return TrialCodeModel(
      code: (json['code'] ?? '').toString(),
      validDays: (json['validDays'] as num?)?.toInt() ?? 0,
      maxUses: (json['maxUses'] as num?)?.toInt(),
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toCreateJson() => {
    'code': code.toUpperCase(),
    'validDays': validDays,
    if (maxUses != null) 'maxUses': maxUses,
    'isActive': isActive,
    if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
  };

  Map<String, dynamic> toUpdateJson() => {
    if (validDays > 0) 'validDays': validDays,
    if (maxUses != null) 'maxUses': maxUses,
    'isActive': isActive,
    if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
  };
}
