import 'dart:async';
import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart' as http;
import 'package:rajwada_app/core/service/shared_preference.dart';

import '../../api_url.dart';

// Login Model
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

// Function to call API and update SharedPreferences
Future<void> fetchLoginData() async {
  try {

    final Uri url = Uri.https(
      APIUrls.hostUrl, // Authority (host)
      APIUrls.refreshToken,
    );

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LoginDataModel().accessToken}',
    };

    final String rawBody = jsonEncode({
      'refreshToken': LoginDataModel().refreshToken,
    });

    var response = await http.post(
      Uri.parse("https://65.0.190.66/api/identity/refresh"),
      body: jsonEncode({"username": "yourUsername", "password": "yourPassword"}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      LoginDataModel loginData =
      LoginDataModel.fromJson(jsonDecode(response.body));

      await SharedPreference.saveToken(loginData.accessToken ?? '');

      print("✅ Login token updated: ${loginData.accessToken}");
    } else {
      print("❌ Login API failed: ${response.statusCode}");
    }
  } catch (e) {
    print("⚠️ API Error: $e");
  }
}

// Background Service
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  Timer.periodic(const Duration(minutes: 4), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        await fetchLoginData();
      }
    }
  });
}

// Required for iOS background execution
@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  fetchLoginData();
  return true;
}
