part of 'refund_policy_bloc.dart';

abstract class RefundPolicyState {}

class RefundPolicyInitial extends RefundPolicyState {}

class RefundPolicyLoading extends RefundPolicyState {}

class RefundPolicyLoaded extends RefundPolicyState {
  final String content;

  RefundPolicyLoaded(this.content);
}

class RefundPolicyEmpty extends RefundPolicyState {
  final String message;

  RefundPolicyEmpty(this.message);
}

class RefundPolicyError extends RefundPolicyState {
  final String message;

  RefundPolicyError(this.message);
}

class RefundPolicyUpdating extends RefundPolicyState {
  final String content;

  RefundPolicyUpdating(this.content);
}

class RefundPolicyUpdated extends RefundPolicyState {
  final String content;
  final String message;

  RefundPolicyUpdated(this.content, this.message);
}

class RefundPolicyGenerating extends RefundPolicyState {
  final String currentContent;

  RefundPolicyGenerating(this.currentContent);
}
