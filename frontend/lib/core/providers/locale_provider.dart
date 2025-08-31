import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale(AppConstants.defaultLocale);

  Locale get locale => _locale;

  void setLocale(String languageCode) {
    if (languageCode.isEmpty) return;
    _locale = Locale(languageCode);
    notifyListeners();
  }
}




