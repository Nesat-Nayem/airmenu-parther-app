class PrivacyPolicyModel {
  final String content;

  PrivacyPolicyModel({required this.content});

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(content: json['content'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'content': content};
  }
}
