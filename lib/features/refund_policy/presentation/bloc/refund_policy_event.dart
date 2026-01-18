part of 'refund_policy_bloc.dart';

abstract class RefundPolicyEvent {}

class LoadRefundPolicy extends RefundPolicyEvent {}

class UpdateRefundPolicy extends RefundPolicyEvent {
  final String content;

  UpdateRefundPolicy(this.content);
}

class GenerateRefundPolicy extends RefundPolicyEvent {
  final String platformName;

  GenerateRefundPolicy(this.platformName);
}

class UpdateLocalContent extends RefundPolicyEvent {
  final String content;

  UpdateLocalContent(this.content);
}
