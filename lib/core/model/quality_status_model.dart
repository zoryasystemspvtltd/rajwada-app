import 'dart:convert';

class QualityStatusModel {
  String? name;
  int? value;

  QualityStatusModel({
    this.name,
    this.value,
  });

  // Factory constructor to create an object from JSON
  factory QualityStatusModel.fromJson(Map<String, dynamic> json) {
    return QualityStatusModel(
      name: json["name"] ?? "",  // Default to empty string if null
      value: json["value"] ?? 0, // Default to 0 if null
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() => {
    "name": name,
    "value": value,
  };
}

// Convert JSON string to List<QualityStatusModel>
List<QualityStatusModel> qualityStatusModelFromJson(String str) {
  final dynamic jsonData = json.decode(str);

  if (jsonData is List) {
    return jsonData.map((item) => QualityStatusModel.fromJson(item)).toList();
  } else {
    throw Exception("Expected a list but received: $jsonData");
  }
}

// Convert List<QualityStatusModel> to JSON string
String qualityStatusModelToJson(List<QualityStatusModel> data) =>
    json.encode(data.map((x) => x.toJson()).toList());