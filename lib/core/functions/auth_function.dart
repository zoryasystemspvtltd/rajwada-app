
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../api_url.dart';
import '../model/login_data_model.dart';
import '../model/user_privilege_model.dart';
import '../service/shared_preference.dart';

class AuthService {

  Future<LoginDataModel> parseJson(String responseBody) async {
    return compute(_parseJson, responseBody);
  }

  LoginDataModel _parseJson(String responseBody) {
    return LoginDataModel.fromJson(jsonDecode(responseBody));
  }

  Future<UserPrivilegeModel> parsePrivilegeJson(String responseBody) async {
    return compute(_parsePrivilegeJson, responseBody);
  }

  UserPrivilegeModel _parsePrivilegeJson(String responseBody) {
    return UserPrivilegeModel.fromJson(jsonDecode(responseBody));
  }

  //Login Service
  Future<LoginDataModel?> login(String email, String password) async {
    try {
      final Uri url = Uri.https(
        APIUrls.hostUrl, // Authority (host)
        APIUrls.loginUrl, // Path
        {
          'useCookies': 'false',
          'useSessionCookies': 'false',
        }, // Query parameters
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      final String rawBody = jsonEncode({
        'email': email,
        'password': password,
      });

      final http.Response response = await http.post(
        url,
        headers: headers,
        body: rawBody, // Pass raw JSON as string
      );

      if (response.statusCode == 200) {
        // Parse response into LoginDataModel
        LoginDataModel loginData = await parseJson(response.body);

        // Store access token in SharedPreferences
        await SharedPreference.saveToken(loginData.accessToken ?? '');
        await SharedPreference.saveRefreshToken(loginData.refreshToken ?? "");
        await SharedPreference.saveTokenExpiry(DateTime.now().millisecondsSinceEpoch + (1000 * 1000));

        // Fetch and store user privileges
        await fetchAndStoreUserPrivileges();

        return loginData;
      } else {
        print('Login failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // Fetch user privileges after login
  Future<UserPrivilegeModel?> fetchAndStoreUserPrivileges() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return null;

      final Uri url = Uri.https(
        APIUrls.hostUrl, // Authority (host)
        APIUrls.userPrivileges,
      );

      print("Token Value for Privilage: $token");

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse response into UserPrivilegeModel
        UserPrivilegeModel userPrivileges = _parsePrivilegeJson(response.body);;

        // Store user privileges in SharedPreferences
        await saveUserPrivileges(response.body);
        // startTokenRefreshTimer(); // Start the timer after login

        return userPrivileges;
      } else {
        print('Failed to fetch user privileges: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching user privileges: $e');
      return null;
    }
  }

  // void startTokenRefreshTimer() {
  //   Timer.periodic(const Duration(minutes: 55), (timer) async {
  //     await checkAndRefreshToken();
  //   });
  // }



  static Future<LoginDataModel?> fetchRefreshTokenData() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return null;

      String? refreshToken = await SharedPreference.getRefreshToken();
      if (refreshToken == null) return null;

      final Uri url = Uri.https(
        APIUrls.hostUrl, // Authority (host)
        APIUrls.refreshToken,
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final String rawBody = jsonEncode({
        'refreshToken': refreshToken,
      });

      if(kDebugMode){
        print("Access Token For Refresh: $token");
        print("Refresh Token For Refresh: $refreshToken");
      }

      var response = await http.post(
        url,
        body: rawBody,
        headers: headers,
      );

      if (response.statusCode == 200) {
        LoginDataModel loginData =
        LoginDataModel.fromJson(jsonDecode(response.body));

        await SharedPreference.saveToken(loginData.accessToken ?? '');
        await SharedPreference.saveRefreshToken(loginData.refreshToken ?? "");
        await SharedPreference.saveTokenExpiry(DateTime.now().millisecondsSinceEpoch + (1000 * 1000));

        print("✅ Token value updated: ${loginData.accessToken}");
        return loginData;
      } else {
        print("❌ Token Refresh API failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("⚠️ API Error for refresh Data: $e");
      return null;
    }
  }

  // Store user privileges in SharedPreferences
  Future<void> saveUserPrivileges(String privileges) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPrivileges', privileges);
  }

  // Retrieve user privileges from SharedPreferences
  Future<UserPrivilegeModel?> getUserPrivileges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('userPrivileges');

    if (data != null) {
      return userPrivilegeModelFromJson(data);
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    String? token = await SharedPreference.getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout function (clears token)
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }

}


