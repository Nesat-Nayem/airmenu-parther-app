class TermsConditionsModel {
  final String content;

  TermsConditionsModel({required this.content});

  factory TermsConditionsModel.fromJson(Map<String, dynamic> json) {
    return TermsConditionsModel(content: json['content'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'content': content};
  }
}
