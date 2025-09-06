import 'dart:convert';

List<EventModel> eventModelFromJson(String str) => List<EventModel>.from(json.decode(str).map((x) => EventModel.fromJson(x)));

String eventModelToJson(List<EventModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventModel {
  final DateTime date;
  final bool isCuringDone;
  final List<Activity> activities;

  EventModel({
    required this.date,
    required this.isCuringDone,
    required this.activities,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    date: DateTime.parse(json["date"]),
    isCuringDone: json["isCuringDone"] ?? false, // <-- Fix here
    activities: List<Activity>.from(
      (json["activities"] ?? []).map((x) => Activity.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "isCuringDone": isCuringDone,
    "activities": List<dynamic>.from(activities.map((x) => x.toJson())),
  };
}

class Activity {
  final int id;
  final String name;

  Activity({
    required this.id,
    required this.name,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    id: json["id"],
    name: json["name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

enum Name {
  BRICK_WORK_D_F1_1,
  BRICK_WORK_PROJECT_1_B_F1_1,
  CEMENT_WORK_D_F1_1,
  HACKING_D_F1_1,
  HACKING_F_F1_1,
  HACKING_PROJECT_1_B_F1_1,
  HACKING_PROJECT_2_C_F1_1,
  PAINTING_F_F1_1,
  PAINTING_OUTSIDE_TOWER_E_FLOOR_1_FLAT_1,
  PLUMBING_WORK_TOWER_E_FLOOR_1_FLAT_1,
  PUTTY_WORK_PROJECT_2_C_F1_1,
  PUTTY_WORK_TOWER_E_FLOOR_1_FLAT_1
}

final nameValues = EnumValues({
  "Brick Work-D-F1-1": Name.BRICK_WORK_D_F1_1,
  "Brick Work-Project-1-B-F1-1": Name.BRICK_WORK_PROJECT_1_B_F1_1,
  "Cement Work-D-F1-1": Name.CEMENT_WORK_D_F1_1,
  "Hacking-D-F1-1": Name.HACKING_D_F1_1,
  "Hacking-F-F1-1": Name.HACKING_F_F1_1,
  "Hacking-Project-1-B-F1-1": Name.HACKING_PROJECT_1_B_F1_1,
  "Hacking-Project-2-C-F1-1": Name.HACKING_PROJECT_2_C_F1_1,
  "Painting-F-F1-1": Name.PAINTING_F_F1_1,
  "Painting Outside-Tower E-Floor 1-Flat 1": Name.PAINTING_OUTSIDE_TOWER_E_FLOOR_1_FLAT_1,
  "Plumbing Work-Tower E-Floor 1-Flat 1": Name.PLUMBING_WORK_TOWER_E_FLOOR_1_FLAT_1,
  "PuttyWork-Project-2-C-F1-1": Name.PUTTY_WORK_PROJECT_2_C_F1_1,
  "Putty Work-Tower E-Floor 1-Flat 1": Name.PUTTY_WORK_TOWER_E_FLOOR_1_FLAT_1
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