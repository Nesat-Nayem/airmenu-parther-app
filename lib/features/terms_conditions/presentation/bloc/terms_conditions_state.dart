part of 'terms_conditions_bloc.dart';

abstract class TermsConditionsState {}

class TermsConditionsInitial extends TermsConditionsState {}

class TermsConditionsLoading extends TermsConditionsState {}

class TermsConditionsLoaded extends TermsConditionsState {
  final String content;
  TermsConditionsLoaded(this.content);
}

class TermsConditionsEmpty extends TermsConditionsState {
  final String message;
  TermsConditionsEmpty(this.message);
}

class TermsConditionsError extends TermsConditionsState {
  final String message;
  TermsConditionsError(this.message);
}

class TermsConditionsUpdating extends TermsConditionsState {
  final String content;
  TermsConditionsUpdating(this.content);
}

class TermsConditionsUpdated extends TermsConditionsState {
  final String content;
  final String message;
  TermsConditionsUpdated(this.content, this.message);
}

class TermsConditionsGenerating extends TermsConditionsState {
  final String currentContent;
  TermsConditionsGenerating(this.currentContent);
}
