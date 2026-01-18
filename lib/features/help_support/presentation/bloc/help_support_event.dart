part of 'help_support_bloc.dart';

abstract class HelpSupportEvent {}

class LoadHelpSupport extends HelpSupportEvent {}

class UpdateHelpSupport extends HelpSupportEvent {
  final String content;
  UpdateHelpSupport(this.content);
}

class GenerateHelpSupport extends HelpSupportEvent {
  final String platformName;
  GenerateHelpSupport(this.platformName);
}

class UpdateLocalContent extends HelpSupportEvent {
  final String content;
  UpdateLocalContent(this.content);
}
