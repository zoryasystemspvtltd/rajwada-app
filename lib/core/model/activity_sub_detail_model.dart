import 'dart:convert';

ActivitySubDetailModel activitySubDetailModelFromJson(String str) =>
    ActivitySubDetailModel.fromJson(json.decode(str));

String activitySubDetailModelToJson(List<ActivitySubDetailModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ActivitySubDetailModel {
  final int? totalRecords;
  final List<Item>? items;

  ActivitySubDetailModel({
    this.totalRecords,
    this.items,
  });

  factory ActivitySubDetailModel.fromJson(Map<String, dynamic> json) {
    List<Item>? parsedItems;

    if (json["items"] is String) {
      // items is a stringified JSON list, decode and parse each item
      final decodedItems = jsonDecode(json["items"]);
      if (decodedItems is List) {
        parsedItems = decodedItems.map<Item>((x) => Item.fromJson(x)).toList();
      }
    } else if (json["items"] is List) {
      // items is already a list, parse normally
      parsedItems = (json["items"] as List)
          .map<Item>((x) => Item.fromJson(x))
          .toList();
    } else {
      parsedItems = null;
    }

    return ActivitySubDetailModel(
      totalRecords: json["totalRecords"],
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() => {
    "totalRecords": totalRecords,
    "items": items != null
        ? List<dynamic>.from(items!.map((x) => x.toJson()))
        : null,
  };
}

class Item {
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
  final String? workflowState;
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
  final Item? parent;
  final String? parentName;
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

  Item({
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

  factory Item.fromJson(Map<String, dynamic> json) => Item(
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
    parent: json["parent"] == null ? null : Item.fromJson(json["parent"]),
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
    "parent": parent?.toJson(),
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