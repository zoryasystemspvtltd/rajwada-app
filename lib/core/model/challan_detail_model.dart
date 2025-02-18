import 'dart:convert';

ChallanDetailModel challanDetailModelFromJson(String str) => ChallanDetailModel.fromJson(json.decode(str));

String challanDetailModelToJson(ChallanDetailModel data) => json.encode(data.toJson());

class ChallanDetailModel {
  String? inChargeName;
  String? inChargeId;
  String? projectId;
  String? projectName;
  String? vechileNo;
  String? trackingNo;
  String? documentDate;
  String? supplierId;
  String? supplierName;
  dynamic remarks;
  dynamic isApproved;
  dynamic approvedDate;
  dynamic approvedBy;
  dynamic approvedRemarks;
  int? id;
  dynamic name;
  int? status;
  DateTime? date;
  String? member;
  String? key;

  ChallanDetailModel({
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

  factory ChallanDetailModel.fromJson(Map<String, dynamic> json) => ChallanDetailModel(
    inChargeName: json["inChargeName"],
    inChargeId: json["inChargeId"],
    projectId: json["projectId"],
    projectName: json["projectName"],
    vechileNo: json["vechileNo"],
    trackingNo: json["trackingNo"],
    documentDate: json["documentDate"],
    supplierId: json["supplierId"],
    supplierName: json["supplierName"],
    remarks: json["remarks"],
    isApproved: json["isApproved"],
    approvedDate: json["approvedDate"],
    approvedBy: json["approvedBy"],
    approvedRemarks: json["approvedRemarks"],
    id: json["id"],
    name: json["name"],
    status: json["status"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    member: json["member"],
    key: json["key"],
  );

  Map<String, dynamic> toJson() => {
    "inChargeName": inChargeName,
    "inChargeId": inChargeId,
    "projectId": projectId,
    "projectName": projectName,
    "vechileNo": vechileNo,
    "trackingNo": trackingNo,
    "documentDate": documentDate,
    "supplierId": supplierId,
    "supplierName": supplierName,
    "remarks": remarks,
    "isApproved": isApproved,
    "approvedDate": approvedDate,
    "approvedBy": approvedBy,
    "approvedRemarks": approvedRemarks,
    "id": id,
    "name": name,
    "status": status,
    "date": date?.toIso8601String(),
    "member": member,
    "key": key,
  };
}