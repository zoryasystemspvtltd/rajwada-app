import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_url.dart';
import '../model/asset_data_model.dart';
import '../model/quality_status_model.dart';
import '../model/quality_user_model.dart';
import '../model/supplier_data_model.dart';
import '../model/uom_data_model.dart';
import '../model/user_project_model.dart';
import '../service/shared_preference.dart';

class RestFunction{

  // Fetch quality user data
  static Future<List<DropdownMenuItem<int>>> fetchQualityUsersDropdown() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return [];

      final Uri url = Uri.https(APIUrls.hostUrl, APIUrls.qualityUser);
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        QualityUserModel userModel = qualityUserModelFromJson(response.body);

        List<DropdownMenuItem<int>> dropdownItems = userModel.items.map((user) {
          return DropdownMenuItem<int>(
            value: user.id, // ID
            child: Text(user.name ?? "Unknown"), // Name
          );
        }).toList();

        return [DropdownMenuItem<int>(value: -1, child: Text("--Select--")), ...dropdownItems];

        // Convert list of users to DropdownMenuItems
        return userModel.items.map((user) {
          return DropdownMenuItem<int>(
            value: user.id,
            child: Text(user.name ?? "Unknown"), // Display user name
          );
        }).toList(); // ✅ Ensure correct type
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching quality user data: $e');
      return [];
    }
  }

  // Fetch user project data
  static Future<List<DropdownMenuItem<int>>> fetchAndStoreUserProjectData() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return [];

      final Uri url = Uri.https(
        APIUrls.hostUrl, // Base host URL
        APIUrls.userProject, // API endpoint
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(url, headers: headers);

      // Check if response is successful
      if (response.statusCode == 200) {
        // Parse JSON and return the model
        UserProjectModel projectModel = userProjectModelFromJson(response.body);

        List<DropdownMenuItem<int>> dropdownItems = projectModel.items.map((user) {
          return DropdownMenuItem<int>(
            value: user.id, // ID
            child: Text(user.name ?? "Unknown"), // Name
          );
        }).toList();

        return [DropdownMenuItem<int>(value: -1, child: Text("--Select--")), ...dropdownItems];
      } else {
        print('Failed to fetch user project data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching user project data: $e');
      return [];
    }
  }

  // Fetch supplier data
  static Future<List<DropdownMenuItem<int>>> fetchAndStoreSupplierData() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return [];

      final Uri url = Uri.https(
        APIUrls.hostUrl, // Base host URL
        APIUrls.supplier, // API endpoint
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(url, headers: headers);

      // Check if response is successful
      if (response.statusCode == 200) {
        // Parse JSON and return the model
        SupplierDataModel supplierModel = supplierDataModelFromJson(response.body);

        List<DropdownMenuItem<int>> dropdownItems = supplierModel.items.map((user) {
          return DropdownMenuItem<int>(
            value: user.id, // ID
            child: Text(user.name ?? "Unknown"), // Name
          );
        }).toList();

        return [DropdownMenuItem<int>(value: -1, child: Text("--Select--")), ...dropdownItems];
      } else {
        print('Failed to fetch supplier data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching supplier data: $e');
      return [];
    }
  }

  // Fetch uom data
  static Future<List<DropdownMenuItem<int>>> fetchAndStoreUOMData() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return [];

      final Uri url = Uri.https(
        APIUrls.hostUrl, // Base host URL
        APIUrls.uom, // API endpoint
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(url, headers: headers);

      // Check if response is successful
      if (response.statusCode == 200) {
        // Parse JSON and return the model
        UomDataModel uomModel = uomDataModelFromJson(response.body);

        List<DropdownMenuItem<int>> dropdownItems = uomModel.items.map((user) {
          return DropdownMenuItem<int>(
            value: user.id, // ID
            child: Text(user.name ?? "Unknown"), // Name
          );
        }).toList();

        return [DropdownMenuItem<int>(value: -1, child: Text("--Select--")), ...dropdownItems];
      } else {
        print('Failed to fetch uom data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching uom data: $e');
      return [];
    }
  }

  // Fetch asset data
  static Future<List<DropdownMenuItem<int>>> fetchAndStoreAssetData() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return [];

      final Uri url = Uri.https(
        APIUrls.hostUrl, // Base host URL
        APIUrls.asset, // API endpoint
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(url, headers: headers);

      // Check if response is successful
      if (response.statusCode == 200) {
        // Parse JSON and return the model
        AssetDataModel assetModel = assetDataModelFromJson(response.body);

        List<DropdownMenuItem<int>> dropdownItems = assetModel.items.map((user) {
          return DropdownMenuItem<int>(
            value: user.id, // ID
            child: Text(user.name ?? "Unknown"), // Name
          );
        }).toList();

        return [DropdownMenuItem<int>(value: -1, child: Text("--Select--")), ...dropdownItems];
      } else {
        print('Failed to fetch asset data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching asset data: $e');
      return [];
    }
  }

  // Fetch quality status data
  Future<List<DropdownMenuItem<int>>> fetchAndStoreQualityStatusData() async {
    try {
      String? token = await SharedPreference.getToken();

      // If token is null, return a default list instead of null
      if (token == null) return [];

      final Uri url = Uri.https(
        APIUrls.hostUrl, // Base host URL
        APIUrls.qualityStatus, // API endpoint
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(url, headers: headers);

      // Check if response is successful
      if (response.statusCode == 200) {
        // Parse JSON and return the model
        List<QualityStatusModel> data = qualityStatusModelFromJson(response.body);
        // Convert to dropdown items with id as value
        List<DropdownMenuItem<int>> dropdownItems = data.map((item) {
          return DropdownMenuItem<int>(
            value: item.value, // ID
            child: Text(item.name ?? "Unknown"), // Name
          );
        }).toList();

        return [DropdownMenuItem<int>(value: -1, child: Text("--Select--")), ...dropdownItems]; // Include default option
      } else {
        print('Failed to fetch quality status data: ${response.statusCode}');
        return [];;
      }
    } catch (e) {
      print('Error fetching quality status data: $e');
      return [];;
    }
  }

}