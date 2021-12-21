import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  Locale locale = Locale('en');
  var selectedLanguageCode = 'en';
  Color color;
  var wishListCount = 0;

  AppState(lang, Color aColor) {
    selectedLanguageCode = lang;
    color = aColor;
  }

  Locale get getLocale => locale;

  get getSelectedLanguageCode => selectedLanguageCode;

  get getWishListCount => wishListCount;

  setLocale(locale) => this.locale = locale;

  setSelectedLanguageCode(code) => this.selectedLanguageCode = code;

  changeLocale(Locale l) {
    locale = l;
    notifyListeners();
  }

  changeLanguageCode(code) {
    selectedLanguageCode = code;
    notifyListeners();
  }

  changeWishListCount(count) {
    wishListCount = count;
    notifyListeners();
  }
}
