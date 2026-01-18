part of 'help_support_bloc.dart';

abstract class HelpSupportState {}

class HelpSupportInitial extends HelpSupportState {}

class HelpSupportLoading extends HelpSupportState {}

class HelpSupportLoaded extends HelpSupportState {
  final String content;
  HelpSupportLoaded(this.content);
}

class HelpSupportEmpty extends HelpSupportState {
  final String message;
  HelpSupportEmpty(this.message);
}

class HelpSupportError extends HelpSupportState {
  final String message;
  HelpSupportError(this.message);
}

class HelpSupportUpdating extends HelpSupportState {
  final String content;
  HelpSupportUpdating(this.content);
}

class HelpSupportUpdated extends HelpSupportState {
  final String content;
  final String message;
  HelpSupportUpdated(this.content, this.message);
}

class HelpSupportGenerating extends HelpSupportState {
  final String currentContent;
  HelpSupportGenerating(this.currentContent);
}
