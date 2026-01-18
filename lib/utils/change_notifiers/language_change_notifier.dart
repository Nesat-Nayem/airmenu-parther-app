import 'package:flutter/material.dart';

class LanguageChangeNotifier extends ChangeNotifier {
  String _locale = "en";

  String get locale => _locale;

  set locale(String value) {
    _locale = value;
  }
}
