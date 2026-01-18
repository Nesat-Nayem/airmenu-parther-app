part of 'privacy_policy_bloc.dart';

abstract class PrivacyPolicyState {}

class PrivacyPolicyInitial extends PrivacyPolicyState {}

class PrivacyPolicyLoading extends PrivacyPolicyState {}

class PrivacyPolicyLoaded extends PrivacyPolicyState {
  final String content;

  PrivacyPolicyLoaded(this.content);
}

class PrivacyPolicyEmpty extends PrivacyPolicyState {
  final String message;

  PrivacyPolicyEmpty(this.message);
}

class PrivacyPolicyError extends PrivacyPolicyState {
  final String message;

  PrivacyPolicyError(this.message);
}

class PrivacyPolicyUpdating extends PrivacyPolicyState {
  final String content;

  PrivacyPolicyUpdating(this.content);
}

class PrivacyPolicyUpdated extends PrivacyPolicyState {
  final String content;
  final String message;

  PrivacyPolicyUpdated(this.content, this.message);
}

class PrivacyPolicyGenerating extends PrivacyPolicyState {
  final String currentContent;

  PrivacyPolicyGenerating(this.currentContent);
}
