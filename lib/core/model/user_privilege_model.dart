
import 'dart:convert';

UserPrivilegeModel userPrivilegeModelFromJson(String str) => UserPrivilegeModel.fromJson(json.decode(str));

String userPrivilegeModelToJson(UserPrivilegeModel data) => json.encode(data.toJson());

class UserPrivilegeModel {
  String? email;
  String? firstName;
  String? lastName;
  bool? disable;
  String? photoUrl;
  String? department;
  dynamic address;
  String? phoneNumber;
  List<String>? roles;
  List<Privilege>? privileges;

  UserPrivilegeModel({
    this.email,
    this.firstName,
    this.lastName,
    this.disable,
    this.photoUrl,
    this.department,
    this.address,
    this.phoneNumber,
    this.roles,
    this.privileges,
  });

  factory UserPrivilegeModel.fromJson(Map<String, dynamic> json) => UserPrivilegeModel(
    email: json["email"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    disable: json["disable"],
    photoUrl: json["photoUrl"],
    department: json["department"],
    address: json["address"],
    phoneNumber: json["phoneNumber"],
    roles: json["roles"] == null ? [] : List<String>.from(json["roles"]!.map((x) => x)),
    privileges: json["privileges"] == null ? [] : List<Privilege>.from(json["privileges"]!.map((x) => Privilege.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "firstName": firstName,
    "lastName": lastName,
    "disable": disable,
    "photoUrl": photoUrl,
    "department": department,
    "address": address,
    "phoneNumber": phoneNumber,
    "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
    "privileges": privileges == null ? [] : List<dynamic>.from(privileges!.map((x) => x.toJson())),
  };
}

class Privilege {
  String? module;
  Name? name;
  String? type;

  Privilege({
    this.module,
    this.name,
    this.type,
  });

  factory Privilege.fromJson(Map<String, dynamic> json) => Privilege(
    module: json["module"],
    name: nameValues.map[json["name"]]!,
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "module": module,
    "name": nameValues.reverse[name],
    "type": type,
  };
}

enum Name {
  ADD,
  APPROVE,
  ASSIGN,
  DELETE,
  EDIT,
  LIST,
  VIEW
}

final nameValues = EnumValues({
  "add": Name.ADD,
  "approve": Name.APPROVE,
  "assign": Name.ASSIGN,
  "delete": Name.DELETE,
  "edit": Name.EDIT,
  "list": Name.LIST,
  "view": Name.VIEW
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