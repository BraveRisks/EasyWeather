import 'package:flutter/material.dart';

class DarkMode with ChangeNotifier {

  var isDark = false;

  void change() {
    isDark = !isDark;
    notifyListeners();
  }
}