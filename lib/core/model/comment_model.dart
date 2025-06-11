
import 'dart:convert';

class CommentModel {
  int? totalRecords;
  List<CommentModelItem>? items;

  CommentModel({this.totalRecords, this.items});

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      totalRecords: json['totalRecords'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CommentModelItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalRecords': totalRecords,
    'items': items?.map((item) => item.toJson()).toList(),
  };
}

class CommentModelItem {
  String? remarks;
  int? activityId;
  dynamic activity;
  int? id;
  String? name;
  int? status;
  String? date;
  String? member;
  String? key;

  CommentModelItem({
    this.remarks,
    this.activityId,
    this.activity,
    this.id,
    this.name,
    this.status,
    this.date,
    this.member,
    this.key,
  });

  factory CommentModelItem.fromJson(Map<String, dynamic> json) {
    return CommentModelItem(
      remarks: json['remarks'],
      activityId: json['activityId'],
      activity: json['activity'],
      id: json['id'],
      name: json['name'],
      status: json['status'],
      date: json['date'],
      member: json['member'],
      key: json['key'],
    );
  }

  Map<String, dynamic> toJson() => {
    'remarks': remarks,
    'activityId': activityId,
    'activity': activity,
    'id': id,
    'name': name,
    'status': status,
    'date': date,
    'member': member,
    'key': key,
  };
}