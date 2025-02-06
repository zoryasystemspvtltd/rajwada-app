import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AppUtils {
  static String getDateStringFromDate(DateTime date) {
    var formatterDate = DateFormat('MM/dd/yyyy');
    String actualDate = formatterDate.format(date);
    return actualDate;
  }
}
