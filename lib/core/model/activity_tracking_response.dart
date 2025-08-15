import 'dart:convert';

class ActivityTrackingResponse {
  final int totalRecords;
  final List<ActivityItem> items;

  ActivityTrackingResponse({required this.totalRecords, required this.items});

  factory ActivityTrackingResponse.fromJson(Map<String, dynamic> json) {
    return ActivityTrackingResponse(
      totalRecords: json['totalRecords'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((item) => ActivityItem.fromJson(item))
          .toList(),
    );
  }
}

class ActivityItem {
  final int manPower;
  final bool isOnHold;
  final bool isCancelled;
  final bool isCuringDone;
  final double cost;
  final String? item; // <-- new: raw JSON string from API
  final int activityId;
  final dynamic activity; // nullable
  final int id;
  final String name;
  final int status;
  final String date;
  final String member;
  final String key;

  ActivityItem({
    required this.manPower,
    required this.isOnHold,
    required this.isCancelled,
    required this.isCuringDone,
    required this.cost,
    required this.item,
    required this.activityId,
    required this.activity,
    required this.id,
    required this.name,
    required this.status,
    required this.date,
    required this.member,
    required this.key,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      manPower: json['manPower'] ?? 0,
      isOnHold: json['isOnHold'] ?? false,
      isCancelled: json['isCancelled'] ?? false,
      isCuringDone: json['isCuringDone'] ?? false,
      cost: (json['cost'] ?? 0).toDouble(),
      item: json['item'], // string from API
      activityId: json['activityId'] ?? 0,
      activity: json['activity'], // can be null
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? 0,
      date: json['date'] ?? '',
      member: json['member'] ?? '',
      key: json['key'] ?? '',
    );
  }
}