import 'dart:convert';

AssetDataModel assetDataModelFromJson(String str) => AssetDataModel.fromJson(json.decode(str));

String assetDataModelToJson(AssetDataModel data) => json.encode(data.toJson());

class AssetDataModel {
  final int totalRecords;
  final List<Item> items;

  AssetDataModel({
    required this.totalRecords,
    required this.items,
  });

  /// Factory method to create `QualityUserModel` from JSON
  factory AssetDataModel.fromJson(Map<String, dynamic> json) {
    return AssetDataModel(
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
  int? uomId;
  dynamic uomName;
  int? typeId;
  dynamic typeName;
  int? groupId;
  dynamic groupName;
  int? id;
  String? name;
  int? status;
  DateTime? date;
  String? member;
  String? key;

  Item({
    this.code,
    this.uomId,
    this.uomName,
    this.typeId,
    this.typeName,
    this.groupId,
    this.groupName,
    this.id,
    this.name,
    this.status,
    this.date,
    this.member,
    this.key,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    code: json["code"],
    uomId: json["uomId"],
    uomName: json["uomName"],
    typeId: json["typeId"],
    typeName: json["typeName"],
    groupId: json["groupId"],
    groupName: json["groupName"],
    id: json["id"],
    name: json["name"],
    status: json["status"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    member: json["member"],
    key: json["key"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "uomId": uomId,
    "uomName": uomName,
    "typeId": typeId,
    "typeName": typeName,
    "groupId": groupId,
    "groupName": groupName,
    "id": id,
    "name": name,
    "status": status,
    "date": date?.toIso8601String(),
    "member": member,
    "key": key,
  };
}