import 'dart:convert';

class ActivityTrackingResponse {
  final int totalRecords;
  final List<ActivityItem> items;

  ActivityTrackingResponse({required this.totalRecords, required this.items});

  factory ActivityTrackingResponse.fromJson(Map<String, dynamic> json) {
    return ActivityTrackingResponse(
      totalRecords: json['totalRecords'],
      items: (json['items'] as List)
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
  final String name;
  final int status;

  ActivityItem({
    required this.manPower,
    required this.isOnHold,
    required this.isCancelled,
    required this.isCuringDone,
    required this.cost,
    required this.name,
    required this.status,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      manPower: json['manPower'] ?? 0,
      isOnHold: json['isOnHold'] ?? false,
      isCancelled: json['isCancelled'] ?? false,
      isCuringDone: json['isCuringDone'] ?? false,
      cost: (json['cost'] ?? 0).toDouble(),
      name: json['name'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}