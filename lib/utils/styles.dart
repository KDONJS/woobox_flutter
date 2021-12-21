import 'package:WooBox/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

var textFiledBorderStyle = OutlineInputBorder(borderRadius: BorderRadius.circular(32.0), borderSide: BorderSide(width: 1, color: editTextBackgroundColor));

const drawerTextStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black);

var buttonCornerRadius = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)));

BoxDecoration boxDecoration({double radius = 8, Color color = viewLineColor, Color bgColor = whiteColor}) {
  return BoxDecoration(color: bgColor, border: Border.all(color: color), borderRadius: BorderRadius.all(Radius.circular(radius)));
}

RoundedRectangleBorder roundedRectangleBorder(double radius, {Color color = viewLineColor}) {
  return RoundedRectangleBorder(side: BorderSide(color: color), borderRadius: BorderRadius.all(Radius.circular(radius)));
}

BoxDecoration boxDecorationSoftUI({darkMode = false, radius = 40.0}) {
  return BoxDecoration(
    color: darkMode ? darkBgColor : lightBgColor,
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    boxShadow: [
      BoxShadow(color: darkMode ? Colors.black54 : Colors.grey[500], offset: Offset(4.0, 4.0), blurRadius: 15.0, spreadRadius: 1.0),
      BoxShadow(color: darkMode ? Colors.grey[800] : Colors.white, offset: Offset(-4.0, -4.0), blurRadius: 15.0, spreadRadius: 1.0),
    ],
  );
}
