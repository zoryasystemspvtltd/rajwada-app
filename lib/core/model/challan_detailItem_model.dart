import 'dart:convert';

ChallanDetailItemModel challanDetailItemModelFromJson(String str) => ChallanDetailItemModel.fromJson(json.decode(str));

String challanDetailItemModelToJson(ChallanDetailItemModel data) => json.encode(data.toJson());

class ChallanDetailItemModel {
  final int totalRecords;
  final List<ChallanDetailItem> items;

  ChallanDetailItemModel({
    required this.totalRecords,
    required this.items,
  });

  factory ChallanDetailItemModel.fromJson(Map<String, dynamic> json) => ChallanDetailItemModel(
    totalRecords: json["totalRecords"],
    items: json["items"] != null
        ? List<ChallanDetailItem>.from(json["items"].map((x) => ChallanDetailItem.fromJson(x)))
        : [], // Ensure it's never null
  );

  Map<String, dynamic> toJson() => {
    "totalRecords": totalRecords,
    "items": items,
  };
}

class ChallanDetailItem {
  String? itemId;
  String? quantity;
  String? price;
  String? uomId;
  String? uomName;
  dynamic qualityStatus;
  dynamic qualityRemarks;
  String? receiverStatus;
  String? receiverRemarks;
  int? headerId;
  int? id;
  String? name;
  int? status;
  DateTime? date;
  String? member;
  String? key;

  ChallanDetailItem({
    this.itemId,
    this.quantity,
    this.price,
    this.uomId,
    this.uomName,
    this.qualityStatus,
    this.qualityRemarks,
    this.receiverStatus,
    this.receiverRemarks,
    this.headerId,
    this.id,
    this.name,
    this.status,
    this.date,
    this.member,
    this.key,
  });

  factory ChallanDetailItem.fromJson(Map<String, dynamic> json) => ChallanDetailItem(
    itemId: json["itemId"],
    quantity: json["quantity"],
    price: json["price"],
    uomId: json["uomId"],
    uomName: json["uomName"],
    qualityStatus: json["qualityStatus"],
    qualityRemarks: json["qualityRemarks"],
    receiverStatus: json["receiverStatus"],
    receiverRemarks: json["receiverRemarks"],
    headerId: json["headerId"],
    id: json["id"],
    name: json["name"],
    status: json["status"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    member: json["member"],
    key: json["key"],
  );

  Map<String, dynamic> toJson() => {
    "itemId": itemId,
    "quantity": quantity,
    "price": price,
    "uomId": uomId,
    "uomName": uomName,
    "qualityStatus": qualityStatus,
    "qualityRemarks": qualityRemarks,
    "receiverStatus": receiverStatus,
    "receiverRemarks": receiverRemarks,
    "headerId": headerId,
    "id": id,
    "name": name,
    "status": status,
    "date": date?.toIso8601String(),
    "member": member,
    "key": key,
  };
}