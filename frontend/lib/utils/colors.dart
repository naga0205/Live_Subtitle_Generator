import 'package:flutter/material.dart';

hasStringToColor(String hexcolor) {
  hexcolor = hexcolor.toUpperCase().replaceAll("#", "");
  if (hexcolor.length == 6) {
    hexcolor = "FF" + hexcolor;
  }
  return Color(int.parse(hexcolor, radix: 16));
}
