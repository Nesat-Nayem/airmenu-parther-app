part of 'privacy_policy_bloc.dart';

abstract class PrivacyPolicyEvent {}

class LoadPrivacyPolicy extends PrivacyPolicyEvent {}

class UpdatePrivacyPolicy extends PrivacyPolicyEvent {
  final String content;

  UpdatePrivacyPolicy(this.content);
}

class GeneratePrivacyPolicy extends PrivacyPolicyEvent {
  final String platformName;

  GeneratePrivacyPolicy(this.platformName);
}

class UpdateLocalContent extends PrivacyPolicyEvent {
  final String content;

  UpdateLocalContent(this.content);
}
