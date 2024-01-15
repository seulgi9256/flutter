import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Color buttonColor = '#E94293'.toColor();
Color bgColor = "#F8F8F8".toColor();
Color subTitleColor = "#808080".toColor();
Color borderColor = "#DFDFDF".toColor();
Color regularBlack = "#000000".toColor();
Color blueGray50 = "#ebecef".toColor();
Color regularWhite = "#FFFFFF".toColor();
Color lightGray = "#F8F8F8".toColor();
Color lightGreen = "#FBD9E8".toColor();
Color tabbarBackground = "#F6F6F6".toColor();
Color dividerColor = "#F1F1F1".toColor();
Color darkGray = "#696969".toColor();
Color gray = "#F1F1F1".toColor();
Color black40 = "#808080".toColor();
Color black20 = "#DCDCDC".toColor();
Color redColor = "#FF3E3E".toColor();
Color lightColor = "#F4F4F4".toColor();

extension ColorExtension on String {
  toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}
