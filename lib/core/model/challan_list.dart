import 'dart:convert';

ChallanListModel challanListModelFromJson(String str) => ChallanListModel.fromJson(json.decode(str));

String challanListModelToJson(ChallanListModel data) => json.encode(data.toJson());

class ChallanListModel {
  final int totalRecords;
  final List<ChallanItem> items;

  ChallanListModel({
    required this.totalRecords,
    required this.items,
  });

  // Factory constructor to create an object from JSON
  factory ChallanListModel.fromJson(Map<String, dynamic> json) {
    return ChallanListModel(
      totalRecords: json["totalRecords"] ?? 0, // Ensure it's never null
      items: (json["items"] as List?)?.map((x) => ChallanItem.fromJson(x)).toList() ?? [],
    );
  }

  // factory ChallanListModel.fromJson(Map<String, dynamic> json) {
  //   return ChallanListModel(
  //     totalRecords: json["totalRecords"],
  //     items: json["items"] != null
  //         ? List<ChallanItem>.from(json["items"].map((x) => ChallanItem.fromJson(x)))
  //         : [], // Ensure it's never null
  //   );
  // }


  // Convert object to JSON
  Map<String, dynamic> toJson() => {
    "totalRecords": totalRecords,
    "items": items,
  };

  // factory ChallanListModel.fromJson(Map<String, dynamic> json) => ChallanListModel(
  //   totalRecords: json["totalRecords"],
  //   items: json["items"] == null ? [] : List<ChallanItem>.from(json["items"]!.map((x) => ChallanItem.fromJson(x))),
  // );
  //
  // Map<String, dynamic> toJson() => {
  //   "totalRecords": totalRecords,
  //   "items":  List<dynamic>.from(ChallanItem.map((x) => x.toJson())),
  // };
}

class ChallanItem {
  String? inChargeName; // ✅ Change to String?
  String? inChargeId;
  String? projectId;
  String? projectName;
  String? vechileNo;
  String? trackingNo;
  DateTime? documentDate;
  String? supplierId;
  String? supplierName;
  dynamic remarks;
  bool? isApproved;
  DateTime? approvedDate;
  String? approvedBy;
  String? approvedRemarks;
  int? id;
  dynamic name;
  int? status;
  DateTime? date;
  String? member;
  String? key;

  ChallanItem({
    this.inChargeName,
    this.inChargeId,
    this.projectId,
    this.projectName,
    this.vechileNo,
    this.trackingNo,
    this.documentDate,
    this.supplierId,
    this.supplierName,
    this.remarks,
    this.isApproved,
    this.approvedDate,
    this.approvedBy,
    this.approvedRemarks,
    this.id,
    this.name,
    this.status,
    this.date,
    this.member,
    this.key,
  });

  factory ChallanItem.fromJson(Map<String, dynamic> json) => ChallanItem(
    inChargeName: json["inChargeName"] ?? "", // ✅ Store as a String to avoid type errors
    inChargeId: json["inChargeId"] ?? "",
    projectId: json["projectId"] ?? "",
    projectName: json["projectName"] ?? "",
    vechileNo: json["vechileNo"] ?? "",
    trackingNo: json["trackingNo"] ?? "",
    documentDate: json["documentDate"] != null ? DateTime.tryParse(json["documentDate"]) : null,
    supplierId: json["supplierId"] ?? "",
    supplierName: json["supplierName"] ?? "",
    remarks: json["remarks"],
    isApproved: json["isApproved"],
    approvedDate: json["approvedDate"] != null ? DateTime.tryParse(json["approvedDate"]) : null,
    approvedBy: json["approvedBy"] ?? "",
    approvedRemarks: json["approvedRemarks"] ?? "",
    id: json["id"] ?? 0,
    name: json["name"],
    status: json["status"] ?? 0,
    date: json["date"] != null ? DateTime.tryParse(json["date"]) : null,
    member: json["member"] ?? "",
    key: json["key"] ?? "", // Ensure this doesn't crash if null
  );

  Map<String, dynamic> toJson() => {
    "inChargeName": inChargeName,
    "inChargeId": inChargeId,
    "projectId": projectId,
    "projectName": projectName,
    "vechileNo": vechileNo,
    "trackingNo": trackingNo,
    "documentDate": documentDate?.toIso8601String(),
    "supplierId": supplierId,
    "supplierName": supplierNameValues.reverse[supplierName],
    "remarks": remarks,
    "isApproved": isApproved,
    "approvedDate": approvedDate?.toIso8601String(),
    "approvedBy": approvedBy,
    "approvedRemarks": approvedRemarks,
    "id": id,
    "name": name,
    "status": status,
    "date": date?.toIso8601String(),
    "member": member,
    "key": keyValues.reverse[key],
  };
}

enum InChargeName { QC_ENGINEER_JACOB, ENGINEER_ADAM }

final Map<String, InChargeName> inChargeNameValues = {
  "QC Engineer Jacob": InChargeName.QC_ENGINEER_JACOB,
  "Engineer Adam": InChargeName.ENGINEER_ADAM,
};

enum Key {
  THE_1536_B022_C5_C9_4358_BB6_A_466_F2075_B7_D4
}

final keyValues = EnumValues({
  "1536B022-C5C9-4358-BB6A-466F2075B7D4": Key.THE_1536_B022_C5_C9_4358_BB6_A_466_F2075_B7_D4
});

enum SupplierName {
  SUPPLIER_1
}

final supplierNameValues = EnumValues({
  "Supplier 1": SupplierName.SUPPLIER_1
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}