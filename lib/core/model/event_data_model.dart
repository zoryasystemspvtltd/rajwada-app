import 'dart:convert';

EventModel eventModelFromJson(String str) => EventModel.fromJson(json.decode(str));

String eventModelToJson(EventModel data) => json.encode(data.toJson());

class EventModel {
  int? totalRecords;
  List<Item>? items;

  EventModel({
    this.totalRecords,
    this.items,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    totalRecords: json["totalRecords"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "totalRecords": totalRecords,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Item {
  String? description;
  Type? type;
  String? photoUrl;
  dynamic documentLinks;
  dynamic notes;
  dynamic userId;
  dynamic priorityStatus;
  WorkflowState? workflowState;
  dynamic approvalStatus;
  double? costEstimate;
  double? actualCost;
  DateTime? startDate;
  DateTime? endDate;
  dynamic actualStartDate;
  dynamic actualEndDate;
  int? duration;
  int? progressPercentage;
  String? items;
  int? projectId;
  dynamic project;
  int? parentId;
  Item? parent;
  String? parentName;
  int? dependencyId;
  dynamic dependency;
  int? towerId;
  dynamic tower;
  int? floorId;
  dynamic floor;
  int? flatId;
  dynamic flat;
  dynamic contractorId;
  dynamic contractor;
  int? id;
  String? name;
  int? status;
  DateTime? date;
  String? member;
  String? key;

  Item({
    this.description,
    this.type,
    this.photoUrl,
    this.documentLinks,
    this.notes,
    this.userId,
    this.priorityStatus,
    this.workflowState,
    this.approvalStatus,
    this.costEstimate,
    this.actualCost,
    this.startDate,
    this.endDate,
    this.actualStartDate,
    this.actualEndDate,
    this.duration,
    this.progressPercentage,
    this.items,
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
    description: json["description"] ?? "",  // Provide a default empty string
    type: typeValues.map[json["type"]],  // Remove `!` to prevent crash on null
    photoUrl: json["photoUrl"],
    documentLinks: json["documentLinks"],
    notes: json["notes"],
    userId: json["userId"],
    priorityStatus: json["priorityStatus"],
    workflowState: json["workflowState"] != null ? workflowStateValues.map[json["workflowState"]] : null, // Safe null check
    approvalStatus: json["approvalStatus"],
    costEstimate: json["costEstimate"]?.toDouble() ?? 0.0, // Ensure it's a double to avoid type errors
    actualCost: json["actualCost"]?.toDouble() ?? 0.0,
    startDate: json["startDate"] != null ? DateTime.tryParse(json["startDate"]) : null,
    endDate: json["endDate"] != null ? DateTime.tryParse(json["endDate"]) : null,
    actualStartDate: json["actualStartDate"],
    actualEndDate: json["actualEndDate"],
    duration: json["duration"] ?? 0,
    progressPercentage: json["progressPercentage"] ?? 0,
    items: json["items"] ?? "[]", // Default to empty JSON array if null
    projectId: json["projectId"],
    project: json["project"],
    parentId: json["parentId"],
    parent: json["parent"] != null ? Item.fromJson(json["parent"]) : null,
    parentName: json["parentName"] ?? "",
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
    name: json["name"] ?? "Unknown", // Provide a fallback name
    status: json["status"] ?? 0,
    date: json["date"] != null ? DateTime.tryParse(json["date"]) : null,
    member: json["member"], // No force unwrap
    key: json["key"], // No force unwrap
  );

  Map<String, dynamic> toJson() => {
    "description": description,
    "type": typeValues.reverse[type],
    "photoUrl": photoUrl,
    "documentLinks": documentLinks,
    "notes": notes,
    "userId": userId,
    "priorityStatus": priorityStatus,
    "workflowState": workflowStateValues.reverse[workflowState],
    "approvalStatus": approvalStatus,
    "costEstimate": costEstimate,
    "actualCost": actualCost,
    "startDate": startDate?.toIso8601String(),
    "endDate": endDate?.toIso8601String(),
    "actualStartDate": actualStartDate,
    "actualEndDate": actualEndDate,
    "duration": duration,
    "progressPercentage": progressPercentage,
    "items": items,
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
    "member": memberValues.reverse[member],
    "key": keyValues.reverse[key],
  };
}

enum Key {
  THE_1536_B022_C5_C9_4358_BB6_A_466_F2075_B7_D4
}

final keyValues = EnumValues({
  "1536B022-C5C9-4358-BB6A-466F2075B7D4": Key.THE_1536_B022_C5_C9_4358_BB6_A_466_F2075_B7_D4
});

enum Member {
  A_BOSE_CIVILHEAD_COM
}

final memberValues = EnumValues({
  "a.bose@civilhead.com": Member.A_BOSE_CIVILHEAD_COM
});

enum Type {
  MAIN_TASK,
  SUB_TASK
}

final typeValues = EnumValues({
  "Main Task": Type.MAIN_TASK,
  "Sub Task": Type.SUB_TASK
});

enum WorkflowState {
  NEW
}

final workflowStateValues = EnumValues({
  "New": WorkflowState.NEW
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