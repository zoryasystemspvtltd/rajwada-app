import 'dart:convert';

SupplierDataModel supplierDataModelFromJson(String str) => SupplierDataModel.fromJson(json.decode(str));

String supplierDataModelToJson(SupplierDataModel data) => json.encode(data.toJson());

class SupplierDataModel {
  final int? totalRecords;
  final List<Item> items;

  SupplierDataModel({
    required this.totalRecords,
    required this.items,
  });

  /// Factory method to create `QualityUserModel` from JSON
  factory SupplierDataModel.fromJson(Map<String, dynamic> json) {
    return SupplierDataModel(
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
  dynamic phoneNumber;
  dynamic address;
  dynamic panNo;
  dynamic gstNo;
  dynamic licenceNo;
  dynamic effectiveStartDate;
  dynamic effectiveEndDate;
  dynamic spoc;
  int? id;
  String? name;
  int? status;
  DateTime? date;
  String? member;
  String? key;

  Item({
    this.code,
    this.phoneNumber,
    this.address,
    this.panNo,
    this.gstNo,
    this.licenceNo,
    this.effectiveStartDate,
    this.effectiveEndDate,
    this.spoc,
    this.id,
    this.name,
    this.status,
    this.date,
    this.member,
    this.key,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    code: json["code"],
    phoneNumber: json["phoneNumber"],
    address: json["address"],
    panNo: json["panNo"],
    gstNo: json["gstNo"],
    licenceNo: json["licenceNo"],
    effectiveStartDate: json["effectiveStartDate"],
    effectiveEndDate: json["effectiveEndDate"],
    spoc: json["spoc"],
    id: json["id"],
    name: json["name"],
    status: json["status"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    member: json["member"],
    key: json["key"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "phoneNumber": phoneNumber,
    "address": address,
    "panNo": panNo,
    "gstNo": gstNo,
    "licenceNo": licenceNo,
    "effectiveStartDate": effectiveStartDate,
    "effectiveEndDate": effectiveEndDate,
    "spoc": spoc,
    "id": id,
    "name": name,
    "status": status,
    "date": date?.toIso8601String(),
    "member": member,
    "key": key,
  };
}