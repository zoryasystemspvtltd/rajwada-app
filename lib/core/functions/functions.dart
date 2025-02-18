import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rajwada_app/core/model/challan_list.dart';
import '../../api_url.dart';
import '../model/asset_data_model.dart';
import '../model/challan_detailItem_model.dart';
import '../model/challan_detail_model.dart';
import '../model/challan_status_model.dart';
import '../model/project_detail_model.dart';
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

        return [const DropdownMenuItem<int>(value: -1, child: Text("--Select--")), ...dropdownItems];

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

        return [const DropdownMenuItem<int>(value: -1, child: Text("--Select--")), ...dropdownItems];
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

        return [const DropdownMenuItem<int>(value: -1, child: Text("--Select--")), ...dropdownItems];
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

        return [const DropdownMenuItem<int>(value: -1, child: Text("--Select--")), ...dropdownItems];
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

        return [const DropdownMenuItem<int>(value: -1, child: Text("--Select--")), ...dropdownItems];
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

        return [const DropdownMenuItem<int>(value: -1, child: Text("--Select--")), ...dropdownItems]; // Include default option
      } else {
        print('Failed to fetch quality status data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching quality status data: $e');
      return [];
    }
  }

  //Fetch Challan List
  static Future<ChallanListModel?> fetchChallanList({int currentPage = 1, int recordPerPage = 15}) async {
    try {
      String? token = await SharedPreference.getToken();

      if (token == null || token.isEmpty) {
        print("Error: Token is null or empty. User might not be logged in.");
        return null;
      }

      final Uri url = Uri.https(
        APIUrls.hostUrl,
        APIUrls.fetchChallanList,
        {
          "currentPage": currentPage.toString(),  // 👈 Adding query parameters
          "recordPerPage": recordPerPage.toString(),
        },
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get( // 🔹 Use POST instead of GET
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}'); // 👀 Check what API returns
        final jsonData = json.decode(response.body);
        ChallanListModel challanList = ChallanListModel.fromJson(jsonData);
        return challanList;
      } else {
        print('Challan list fetch failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during challan list fetch: $e');
      return null;
    }
  }

  //Fetch Challan Detail
  static Future<ChallanDetailModel?> fetchChallanDetail(int challanId) async {
    try {
      String? token = await SharedPreference.getToken();

      // If token is null, return a default list instead of null
      if (token == null) return null;

      final Uri url = Uri.https(
        APIUrls.hostUrl, // Authority (host)
        "${APIUrls.fetchChallanDetail}/$challanId", // Path
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse response into LoginDataModel
        final jsonData = json.decode(response.body);
        ChallanDetailModel challanDetail = ChallanDetailModel.fromJson(jsonData);
        return challanDetail; // Return detail
      } else {
        print('fetch Challan Detail failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during fetch Challan Detail: $e');
      return null;
    }
  }

  //Fetch Challan Detail Item
  static Future<ChallanDetailItemModel?> fetchChallanDetailItem(int challanId) async {
    try {
      String? token = await SharedPreference.getToken();

      // If token is null, return a default list instead of null
      if (token == null) return null;

      final Uri url = Uri.https(
        APIUrls.hostUrl, // Authority (host)
        APIUrls.fetchChallanDetailItem, // Path
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apioption': jsonEncode({
          "currentPage": 1,
          "recordPerPage": 0,
          "searchCondition": {
            "name": "headerId",
            "value": challanId
          }
        }),
      };

      final http.Response response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse response into LoginDataModel
        final jsonData = json.decode(response.body);
        ChallanDetailItemModel challanDetailItem = ChallanDetailItemModel.fromJson(jsonData);
        return challanDetailItem; // Return detail
      } else {
        print('fetch ChallanDetailItem failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during fetch ChallanDetailItem: $e');
      return null;
    }
  }

  // Function to fetch and parse the data from the API
  static Future<List<ChallanStatusModel>?> fetchChallanStatus() async {

    try {
      String? token = await SharedPreference.getToken();

      // If token is null, return a default list instead of null
      if (token == null) return null;

      final Uri url = Uri.https(
        APIUrls.hostUrl, // Authority (host)
        APIUrls.challanStatus, // Path
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse response into LoginDataModel
        return challanStatusModelFromJson(response.body);
      } else {
        print('fetch Challan Status failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during fetch Challan Status: $e');
      return null;
    }
  }

  // Fetch Project Detail
  static Future<ProjectDetailModel?> fetchProjectDetail(String projectId) async {
    try {
      String? token = await SharedPreference.getToken();

      // If token is null, return a default list instead of null
      if (token == null) return null;

      final Uri url = Uri.https(
        APIUrls.hostUrl, // Authority (host)
        "${APIUrls.fetchProjectDetail}/$projectId", // Path
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Parse response into LoginDataModel
        final jsonData = json.decode(response.body);
        ProjectDetailModel projectDetail = ProjectDetailModel.fromJson(jsonData);
        return projectDetail; // Return detail
      } else {
        print('fetch ProjectDetail failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during fetch ProjectDetail: $e');
      return null;
    }
  }

}