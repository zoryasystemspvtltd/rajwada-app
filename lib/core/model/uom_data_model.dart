import 'dart:convert';

UomDataModel uomDataModelFromJson(String str) => UomDataModel.fromJson(json.decode(str));

String uomDataModelToJson(UomDataModel data) => json.encode(data.toJson());

class UomDataModel {
  final int totalRecords;
  final List<Item> items;

  UomDataModel({
    required this.totalRecords,
    required this.items,
  });

  /// Factory method to create `QualityUserModel` from JSON
  factory UomDataModel.fromJson(Map<String, dynamic> json) {
    return UomDataModel(
      totalRecords: json["totalRecords"] ?? 0,
      items: (json["items"] as List<dynamic>?)
          ?.map((x) => Item.fromJson(x))
          .toList() ?? [],
    );
  }

  /// Converts `QualityUserModel` to JSON
  Map<String, dynamic> toJson() => {
    "totalRecords": totalRecords,
    "items": items.map((x) => x.toJson()).toList(),
  };
}

class Item {
  String? code;
  int? id;
  String? name;
  int? status;
  DateTime? date;
  String? member;
  String? key;

  Item({
    this.code,
    this.id,
    this.name,
    this.status,
    this.date,
    this.member,
    this.key,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    code: json["code"],
    id: json["id"],
    name: json["name"],
    status: json["status"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    member: json["member"],
    key: json["key"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "id": id,
    "name": name,
    "status": status,
    "date": date?.toIso8601String(),
    "member": member,
    "key": key,
  };
}