import 'package:flutter/material.dart';

class Palette {

  /// argb(255, 70, 70, 70)
  static final Color on464646 = Color(0xff464646);

  /// argb(255, 105, 154, 208)
  static final Color on699ad0 = Color(0xff699ad0);

  /// argb(217, 242, 242, 242)
  static final Color on85f2f2f2 = Color(0xd9f2f2f2);

  /// 50: Color(0x4bffffff)
  /// 100: Color(0x50ffffff)
  /// 200: Color(0x55ffffff)
  /// 300: Color(0x5affffff)
  /// 400: Color(0x5effffff)
  /// 500: Color(0xffffffff)
  /// 600: Color(0xffe6e6e6)
  /// 700: Color(0xffcccccc)
  /// 800: Color(0xffb3b3b3)
  /// 900: Color(0xff999999)
  static const MaterialColor weatherColor = MaterialColor(
    0xffffffff,
    <int, Color>{
      50: Color(0x4bffffff),
      100: Color(0x50ffffff),
      200: Color(0x55ffffff),
      300: Color(0x5affffff),
      400: Color(0x5effffff),
      500: Color(0xffffffff),
      600: Color(0xffe6e6e6),
      700: Color(0xffcccccc),
      800: Color(0xffb3b3b3),
      900: Color(0xff999999),
    },
  );
}