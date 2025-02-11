
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../api_url.dart';
import '../model/login_data_model.dart';
import '../model/user_privilege_model.dart';
import '../service/shared_preference.dart';

class AuthService {

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
        LoginDataModel loginData = loginDataModelFromJson(response.body);

        // Store access token in SharedPreferences
        await SharedPreference.saveToken(loginData.accessToken ?? '');

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

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse response into UserPrivilegeModel
        UserPrivilegeModel userPrivileges = userPrivilegeModelFromJson(response.body);

        // Store user privileges in SharedPreferences
        await saveUserPrivileges(response.body);

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


