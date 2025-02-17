import 'dart:convert';

List<ChallanStatusModel> challanStatusModelFromJson(String str) => List<ChallanStatusModel>.from(json.decode(str).map((x) => ChallanStatusModel.fromJson(x)));

String challanStatusModelToJson(List<ChallanStatusModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChallanStatusModel {
  String? name;
  int? value;

  ChallanStatusModel({
    this.name,
    this.value,
  });

  // Factory constructor to create an object from JSON
  factory ChallanStatusModel.fromJson(Map<String, dynamic> json) => ChallanStatusModel(
    name: json["name"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "value": value,
  };
}