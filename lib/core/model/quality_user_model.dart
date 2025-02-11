import 'dart:convert';

/// Converts JSON string to `QualityUserModel`
QualityUserModel qualityUserModelFromJson(String str) =>
    QualityUserModel.fromJson(json.decode(str));

/// Converts `QualityUserModel` to JSON string
String qualityUserModelToJson(QualityUserModel data) =>
    json.encode(data.toJson());

/// Quality User Model representing API response
class QualityUserModel {
  final int totalRecords;
  final List<Item> items;

  QualityUserModel({
    required this.totalRecords,
    required this.items,
  });

  /// Factory method to create `QualityUserModel` from JSON
  factory QualityUserModel.fromJson(Map<String, dynamic> json) {
    return QualityUserModel(
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
}

/// Represents an individual user item
class Item {
  final int id;
  final String? firstName;
  final String? lastName;
  final bool disable;
  final String? photoUrl;
  final String? department;
  final String? name;
  final String? address;
  final dynamic roles;
  final dynamic privileges;
  final String? phoneNumber;
  final String? email;
  final dynamic parentId;
  final String? member;
  final String? key;

  Item({
    required this.id,
    this.firstName,
    this.lastName,
    this.disable = false,
    this.photoUrl,
    this.department,
    this.name,
    this.address,
    this.roles,
    this.privileges,
    this.phoneNumber,
    this.email,
    this.parentId,
    this.member,
    this.key,
  });

  /// Factory method to create `Item` from JSON
  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"] ?? 0,
    firstName: json["firstName"],
    lastName: json["lastName"],
    disable: json["disable"] ?? false,
    photoUrl: json["photoUrl"],
    department: json["department"],
    name: json["name"],
    address: json["address"],
    roles: json["roles"],
    privileges: json["privileges"],
    phoneNumber: json["phoneNumber"],
    email: json["email"],
    parentId: json["parentId"],
    member: json["member"],
    key: json["key"],
  );

  /// Converts `Item` to JSON
  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "disable": disable,
    "photoUrl": photoUrl,
    "department": department,
    "name": name,
    "address": address,
    "roles": roles,
    "privileges": privileges,
    "phoneNumber": phoneNumber,
    "email": email,
    "parentId": parentId,
    "member": member,
    "key": key,
  };
}
