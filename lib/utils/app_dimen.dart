import 'dart:collection';
import 'size_config.dart';

class AppDimenHelper {
  static final AppDimenHelper _singleton = AppDimenHelper._internal();

  factory AppDimenHelper() {
    return _singleton;
  }

  AppDimenHelper._internal();

  Future init() {
    _generateHorizontalDimens();
    _generateVerticalDimens();
    return Future.value();
  }

  ///HORIZONTAL SPACE scaleFactor==>4.23
  final double _horizontalScaleFactor = 4.23;

  _generateHorizontalDimens() {
    for (int i = 0; i < _sizes.length; i++) {
      double generatedSize =
          (_sizes[i] / _horizontalScaleFactor) * SizeConfig.safeBlockHorizontal;
      _mapHorizontalDimens[_sizes[i]] = generatedSize;
    }
  }

  ///Vertical SPACE scaleFactor==>7.76
  final double _verticalScaleFactor = 7.76;

  _generateVerticalDimens() {
    for (int i = 0; i < _sizes.length; i++) {
      double generatedSize =
          (_sizes[i] / _verticalScaleFactor) * SizeConfig.safeBlockVertical;
      _mapVerticalDimens[_sizes[i]] = generatedSize;
    }
  }
}

double hDimen(int dimen) {
  if (!_mapHorizontalDimens.containsKey(dimen)) {
    return dimen.toDouble();
  }
  return _mapHorizontalDimens[dimen];
}

double vDimen(int dimen) {
  if (!_mapVerticalDimens.containsKey(dimen)) {
    return dimen.toDouble();
  }
  return _mapVerticalDimens[dimen];
}

HashMap _mapHorizontalDimens = HashMap<int, double>();
HashMap _mapVerticalDimens = HashMap<int, double>();

List<int> _sizes = [
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  23,
  24,
  25,
  26,
  27,
  28,
  29,
  30,
  31,
  32,
  33,
  34,
  35,
  36,
  37,
  38,
  39,
  40,
  41,
  42,
  43,
  44,
  45,
  46,
  48,
  49,
  50,
  52,
  53,
  54,
  55,
  56,
  57,
  58,
  59,
  60,
  61,
  62,
  63,
  64,
  65,
  66,
  67,
  68,
  69,
  70,
  72,
  74,
  73,
  75,
  80,
  81,
  82,
  83,
  84,
  85,
  86,
  87,
  88,
  89,
  90,
  91,
  92,
  93,
  94,
  95,
  96,
  97,
  98,
  99,
  100,
  105,
  106,
  107,
  108,
  109,
  110,
  120,
  130,
  131,
  132,
  133,
  134,
  135,
  136,
  137,
  138,
  139,
  140,
  141,
  142,
  143,
  144,
  145,
  146,
  147,
  148,
  149,
  150,
  151,
  152,
  153,
  154,
  155,
  156,
  157,
  158,
  159,
  160,
  162,
  164,
  165,
  168,
  170,
  175,
  180,
  182,
  185,
  186,
  187,
  188,
  189,
  190,
  191,
  192,
  193,
  194,
  195,
  196,
  197,
  198,
  199,
  200,
  205,
  210,
  212,
  213,
  214,
  215,
  216,
  217,
  218,
  219,
  220,
  225,
  230,
  235,
  240,
  245,
  250,
  255,
  260,
  265,
  270,
  275,
  280,
  285,
  290,
  295,
  300,
  305,
  310,
  315,
  316,
  317,
  318,
  319,
  320,
  325,
  330,
  340,
  345,
  346,
  347,
  348,
  349,
  350,
  355,
  360,
  365,
  370,
  375,
  380,
  385,
  390,
  395,
  400,
  410,
  420,
  430,
  440,
  450,
  455,
  460,
  470,
  480,
  490,
  500,
];