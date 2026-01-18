part of 'terms_conditions_bloc.dart';

abstract class TermsConditionsEvent {}

class LoadTermsConditions extends TermsConditionsEvent {}

class UpdateTermsConditions extends TermsConditionsEvent {
  final String content;
  UpdateTermsConditions(this.content);
}

class GenerateTermsConditions extends TermsConditionsEvent {
  final String platformName;
  GenerateTermsConditions(this.platformName);
}

class UpdateLocalContent extends TermsConditionsEvent {
  final String content;
  UpdateLocalContent(this.content);
}
