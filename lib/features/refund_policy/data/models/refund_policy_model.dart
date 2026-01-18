class RefundPolicyModel {
  final String content;

  RefundPolicyModel({required this.content});

  factory RefundPolicyModel.fromJson(Map<String, dynamic> json) {
    return RefundPolicyModel(content: json['content'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'content': content};
  }
}
