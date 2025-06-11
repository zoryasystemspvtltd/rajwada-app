
import 'dart:convert';

class ImageGalleryModel {
  final int? totalRecords;
  final List<Item>? items;

  ImageGalleryModel({this.totalRecords, this.items});

  factory ImageGalleryModel.fromJson(Map<String, dynamic> json) {
    return ImageGalleryModel(
      totalRecords: json['totalRecords'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => Item.fromJson(item))
          .toList(),
    );
  }
}

class Item {
  final String? module;
  final String? file;
  final String? parentId;
  final dynamic itemId;
  final dynamic tag;
  final int? id;
  final dynamic name;
  final int? status;
  final DateTime? date;
  final String? member;
  final String? key;

  Item({
    this.module,
    this.file,
    this.parentId,
    this.itemId,
    this.tag,
    this.id,
    this.name,
    this.status,
    this.date,
    this.member,
    this.key,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      module: json['module'],
      file: json['file'],
      parentId: json['parentId'],
      itemId: json['itemId'],
      tag: json['tag'],
      id: json['id'],
      name: json['name'],
      status: json['status'],
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      member: json['member'],
      key: json['key'],
    );
  }
}