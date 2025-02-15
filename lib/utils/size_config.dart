
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class SizeConfig {
  late MediaQueryData _mediaQueryData;
  static double screenWidth = 0.0;
  static double screenHeight = 0.0;
  static double blockSizeHorizontal = 0.0;
  static double blockSizeVertical = 0.0;

  static double _safeAreaHorizontal = 0.0;
  static double _safeAreaVertical = 0.0;
  static double safeBlockHorizontal = 0.0;
  static double safeBlockVertical = 0.0;
  static double scaleFactor = 0.0;

  static final SizeConfig _singleton = SizeConfig._internal();

  factory SizeConfig() {
    return _singleton;
  }

  SizeConfig._internal();

  Future init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
    scaleFactor = _mediaQueryData.textScaleFactor;

    if (screenWidth >= 600) {
      safeBlockHorizontal = safeBlockHorizontal - 2;
      safeBlockVertical = safeBlockVertical - 1.50;
    }

    if (kDebugMode) {
      print("screenWidth==>$screenWidth");
      print("screenHeight==>$screenHeight");
      print("blockSizeHorizontal==>$blockSizeHorizontal");
      print("blockSizeVertical==>$blockSizeVertical");
      print("safeBlockHorizontal==>$safeBlockHorizontal");
      print("safeBlockVertical==>$safeBlockVertical");
      print("textScaleFactor==>${_mediaQueryData.textScaleFactor}");
    }

    return Future.value();
  }
}