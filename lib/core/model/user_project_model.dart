import 'dart:convert';

UserProjectModel userProjectModelFromJson(String str) =>
    UserProjectModel.fromJson(json.decode(str));

String userProjectModelToJson(UserProjectModel data) =>
    json.encode(data.toJson());

class UserProjectModel {
  final int? totalRecords;
  final List<Item> items;

  UserProjectModel({
    required this.totalRecords,
    required this.items,
  });

  /// Factory method to create `QualityUserModel` from JSON
  factory UserProjectModel.fromJson(Map<String, dynamic> json) {
    return UserProjectModel(
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

  // factory UserProjectModel.fromJson(Map<String, dynamic> json) => UserProjectModel(
  //   totalRecords: json["totalRecords"],
  //   items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
  // );
  //
  // Map<String, dynamic> toJson() => {
  //   "totalRecords": totalRecords,
  //   "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  // };
}

class Item {
  String? code;
  String? startFinYear;
  dynamic belongTo;
  String? zone;
  dynamic address1;
  dynamic address2;
  dynamic address3;
  String? country;
  String? state;
  String? city;
  dynamic pinCode;
  dynamic latitude;
  dynamic longitude;
  dynamic phoneNumber;
  dynamic contactName;
  String? blueprint;
  int? status;
  dynamic workflowState;
  dynamic approvalStatus;
  double? budgetAmount;
  double? budgetAllocationAmount;
  double? totalCost;
  DateTime? planStartDate;
  DateTime? planEndDate;
  DateTime? completionCertificateDate;
  dynamic parentId;
  dynamic parentName;
  int? companyId;
  String? companyName;
  int? id;
  String? name;
  DateTime? date;
  String? member;
  String? key;

  Item({
    this.code,
    this.startFinYear,
    this.belongTo,
    this.zone,
    this.address1,
    this.address2,
    this.address3,
    this.country,
    this.state,
    this.city,
    this.pinCode,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.contactName,
    this.blueprint,
    this.status,
    this.workflowState,
    this.approvalStatus,
    this.budgetAmount,
    this.budgetAllocationAmount,
    this.totalCost,
    this.planStartDate,
    this.planEndDate,
    this.completionCertificateDate,
    this.parentId,
    this.parentName,
    this.companyId,
    this.companyName,
    this.id,
    this.name,
    this.date,
    this.member,
    this.key,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    code: json["code"],
    startFinYear: json["startFinYear"],
    belongTo: json["belongTo"],
    zone: json["zone"],
    address1: json["address1"],
    address2: json["address2"],
    address3: json["address3"],
    country: json["country"],
    state: json["state"],
    city: json["city"],
    pinCode: json["pinCode"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    phoneNumber: json["phoneNumber"],
    contactName: json["contactName"],
    blueprint: json["blueprint"],
    status: json["status"],
    workflowState: json["workflowState"],
    approvalStatus: json["approvalStatus"],
    budgetAmount: json["budgetAmount"],
    budgetAllocationAmount: json["budgetAllocationAmount"],
    totalCost: json["totalCost"],
    planStartDate: json["planStartDate"] == null ? null : DateTime.parse(json["planStartDate"]),
    planEndDate: json["planEndDate"] == null ? null : DateTime.parse(json["planEndDate"]),
    completionCertificateDate: json["completionCertificateDate"] == null ? null : DateTime.parse(json["completionCertificateDate"]),
    parentId: json["parentId"],
    parentName: json["parentName"],
    companyId: json["companyId"],
    companyName: json["companyName"],
    id: json["id"],
    name: json["name"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    member: json["member"],
    key: json["key"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "startFinYear": startFinYear,
    "belongTo": belongTo,
    "zone": zone,
    "address1": address1,
    "address2": address2,
    "address3": address3,
    "country": country,
    "state": state,
    "city": city,
    "pinCode": pinCode,
    "latitude": latitude,
    "longitude": longitude,
    "phoneNumber": phoneNumber,
    "contactName": contactName,
    "blueprint": blueprint,
    "status": status,
    "workflowState": workflowState,
    "approvalStatus": approvalStatus,
    "budgetAmount": budgetAmount,
    "budgetAllocationAmount": budgetAllocationAmount,
    "totalCost": totalCost,
    "planStartDate": planStartDate?.toIso8601String(),
    "planEndDate": planEndDate?.toIso8601String(),
    "completionCertificateDate": completionCertificateDate?.toIso8601String(),
    "parentId": parentId,
    "parentName": parentName,
    "companyId": companyId,
    "companyName": companyName,
    "id": id,
    "name": name,
    "date": date?.toIso8601String(),
    "member": member,
    "key": key,
  };
}