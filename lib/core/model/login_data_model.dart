import 'dart:convert';

LoginDataModel loginDataModelFromJson(String str) =>
    LoginDataModel.fromJson(json.decode(str));

String loginDataModelToJson(LoginDataModel data) =>
    json.encode(data.toJson());

class LoginDataModel {
  String? tokenType;
  String? accessToken;
  int? expiresIn;
  String? refreshToken;

  LoginDataModel({
    this.tokenType,
    this.accessToken,
    this.expiresIn,
    this.refreshToken,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) => LoginDataModel(
    tokenType: json["tokenType"],
    accessToken: json["accessToken"],
    expiresIn: json["expiresIn"],
    refreshToken: json["refreshToken"],
  );

  Map<String, dynamic> toJson() => {
    "tokenType": tokenType,
    "accessToken": accessToken,
    "expiresIn": expiresIn,
    "refreshToken": refreshToken,
  };
}