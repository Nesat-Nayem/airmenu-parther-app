class HelpSupportModel {
  final String content;
  HelpSupportModel({required this.content});
  factory HelpSupportModel.fromJson(Map<String, dynamic> json) =>
      HelpSupportModel(content: json['content'] ?? '');
  Map<String, dynamic> toJson() => {'content': content};
}
