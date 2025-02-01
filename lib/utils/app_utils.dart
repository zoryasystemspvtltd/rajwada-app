import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AppUtils {
  static String getDateStringFromDate(DateTime date) {
    var formatterDate = DateFormat('MM/dd/yyyy');
    String actualDate = formatterDate.format(date);
    return actualDate;
  }

  static const Color backGroundColor= Colors.black /*Color(0XFF1E212D)*/;
  static const Color backGroundColorAppbar=  Color(0xFFEABF9F);
}
