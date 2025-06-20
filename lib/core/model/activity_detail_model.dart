import 'dart:convert';

ActivityDetailModel activityDetailModelFromJson(String str) => ActivityDetailModel.fromJson(json.decode(str));

String activityDetailModelToJson(ActivityDetailModel data) => json.encode(data.toJson());

class ActivityDetailModel {
  final String? description;
  final String? type;
  final dynamic isSubSubType;
  final String? photoUrl;
  final dynamic documentLinks;
  final dynamic notes;
  final dynamic userId;
  final dynamic curingDate;
  final dynamic isCuringDone;
  final dynamic isCancelled;
  final dynamic isCompleted;
  final dynamic isOnHold;
  final dynamic isAbandoned;
  final dynamic isQcApproved;
  final dynamic qcApprovedDate;
  final dynamic qcApprovedBy;
  final dynamic qcRemarks;
  final dynamic isApproved;
  final dynamic approvedDate;
  final dynamic approvedBy;
  final dynamic hodRemarks;
  final dynamic actualItems;
  final dynamic priorityStatus;
  final dynamic workflowState;
  final dynamic approvalStatus;
  final double? costEstimate;
  final double? actualCost;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? duration;
  final int? progressPercentage;
  final String? items;
  final dynamic actualStartDate;
  final dynamic actualEndDate;
  final int? projectId;
  final dynamic project;
  final int? parentId;
  final dynamic parent;
  final dynamic parentName;
  final int? dependencyId;
  final dynamic dependency;
  final int? towerId;
  final dynamic tower;
  final int? floorId;
  final dynamic floor;
  final int? flatId;
  final dynamic flat;
  final int? contractorId;
  final dynamic contractor;
  final int? id;
  final String? name;
  final int? status;
  final DateTime? date;
  final String? member;
  final String? key;

  ActivityDetailModel({
    this.description,
    this.type,
    this.isSubSubType,
    this.photoUrl,
    this.documentLinks,
    this.notes,
    this.userId,
    this.curingDate,
    this.isCuringDone,
    this.isCancelled,
    this.isCompleted,
    this.isOnHold,
    this.isAbandoned,
    this.isQcApproved,
    this.qcApprovedDate,
    this.qcApprovedBy,
    this.qcRemarks,
    this.isApproved,
    this.approvedDate,
    this.approvedBy,
    this.hodRemarks,
    this.actualItems,
    this.priorityStatus,
    this.workflowState,
    this.approvalStatus,
    this.costEstimate,
    this.actualCost,
    this.startDate,
    this.endDate,
    this.duration,
    this.progressPercentage,
    this.items,
    this.actualStartDate,
    this.actualEndDate,
    this.projectId,
    this.project,
    this.parentId,
    this.parent,
    this.parentName,
    this.dependencyId,
    this.dependency,
    this.towerId,
    this.tower,
    this.floorId,
    this.floor,
    this.flatId,
    this.flat,
    this.contractorId,
    this.contractor,
    this.id,
    this.name,
    this.status,
    this.date,
    this.member,
    this.key,
  });

  factory ActivityDetailModel.fromJson(Map<String, dynamic> json) => ActivityDetailModel(
    description: json["description"],
    type: json["type"],
    isSubSubType: json["isSubSubType"],
    photoUrl: json["photoUrl"],
    documentLinks: json["documentLinks"],
    notes: json["notes"],
    userId: json["userId"],
    curingDate: json["curingDate"],
    isCuringDone: json["isCuringDone"],
    isCancelled: json["isCancelled"],
    isCompleted: json["isCompleted"],
    isOnHold: json["isOnHold"],
    isAbandoned: json["isAbandoned"],
    isQcApproved: json["isQCApproved"],
    qcApprovedDate: json["qcApprovedDate"],
    qcApprovedBy: json["qcApprovedBy"],
    qcRemarks: json["qcRemarks"],
    isApproved: json["isApproved"],
    approvedDate: json["approvedDate"],
    approvedBy: json["approvedBy"],
    hodRemarks: json["hodRemarks"],
    actualItems: json["actualItems"],
    priorityStatus: json["priorityStatus"],
    workflowState: json["workflowState"],
    approvalStatus: json["approvalStatus"],
    costEstimate: json["costEstimate"],
    actualCost: json["actualCost"],
    startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
    endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
    duration: json["duration"],
    progressPercentage: json["progressPercentage"],
    items: json["items"],
    actualStartDate: json["actualStartDate"],
    actualEndDate: json["actualEndDate"],
    projectId: json["projectId"],
    project: json["project"],
    parentId: json["parentId"],
    parent: json["parent"],
    parentName: json["parentName"],
    dependencyId: json["dependencyId"],
    dependency: json["dependency"],
    towerId: json["towerId"],
    tower: json["tower"],
    floorId: json["floorId"],
    floor: json["floor"],
    flatId: json["flatId"],
    flat: json["flat"],
    contractorId: json["contractorId"],
    contractor: json["contractor"],
    id: json["id"],
    name: json["name"],
    status: json["status"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    member: json["member"],
    key: json["key"],
  );

  Map<String, dynamic> toJson() => {
    "description": description,
    "type": type,
    "isSubSubType": isSubSubType,
    "photoUrl": photoUrl,
    "documentLinks": documentLinks,
    "notes": notes,
    "userId": userId,
    "curingDate": curingDate,
    "isCuringDone": isCuringDone,
    "isCancelled": isCancelled,
    "isCompleted": isCompleted,
    "isOnHold": isOnHold,
    "isAbandoned": isAbandoned,
    "isQCApproved": isQcApproved,
    "qcApprovedDate": qcApprovedDate,
    "qcApprovedBy": qcApprovedBy,
    "qcRemarks": qcRemarks,
    "isApproved": isApproved,
    "approvedDate": approvedDate,
    "approvedBy": approvedBy,
    "hodRemarks": hodRemarks,
    "actualItems": actualItems,
    "priorityStatus": priorityStatus,
    "workflowState": workflowState,
    "approvalStatus": approvalStatus,
    "costEstimate": costEstimate,
    "actualCost": actualCost,
    "startDate": startDate?.toIso8601String(),
    "endDate": endDate?.toIso8601String(),
    "duration": duration,
    "progressPercentage": progressPercentage,
    "items": items,
    "actualStartDate": actualStartDate,
    "actualEndDate": actualEndDate,
    "projectId": projectId,
    "project": project,
    "parentId": parentId,
    "parent": parent,
    "parentName": parentName,
    "dependencyId": dependencyId,
    "dependency": dependency,
    "towerId": towerId,
    "tower": tower,
    "floorId": floorId,
    "floor": floor,
    "flatId": flatId,
    "flat": flat,
    "contractorId": contractorId,
    "contractor": contractor,
    "id": id,
    "name": name,
    "status": status,
    "date": date?.toIso8601String(),
    "member": member,
    "key": key,
  };
}
