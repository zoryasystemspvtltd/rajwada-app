import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rajwada_app/core/model/challan_list.dart';
import 'package:rajwada_app/core/model/comment_model.dart';
import '../../api_url.dart';
import '../model/activity_detail_model.dart';
import '../model/activity_sub_detail_model.dart';
import '../model/activity_tracking_response.dart';
import '../model/asset_data_model.dart';
import '../model/challan_detailItem_model.dart';
import '../model/challan_detail_model.dart';
import '../model/challan_status_model.dart';
import '../model/event_data_model.dart';
import '../model/project_detail_model.dart';
import '../model/quality_status_model.dart';
import '../model/quality_user_model.dart';
import '../model/supplier_data_model.dart';
import '../model/uom_data_model.dart';
import '../model/user_project_model.dart';
import '../service/shared_preference.dart';

class RestFunction{

  static Future<Map<String, dynamic>> fetchAssignForApprovalUsersDropdown() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return {};

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
            value: user.id,
            child: Text(user.name ?? "Unknown", style: const TextStyle(fontSize: 14)),
          );
        }).toList();

        return {
          "userModel": userModel,
          "dropdownItems": [
            const DropdownMenuItem<int>(
              value: -1,
              child: Text("--Select--", style: TextStyle(fontSize: 14)),
            ),
            ...dropdownItems
          ]
        };
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching approval user data: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> fetchQualityUsersDropdown() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return {};

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
            value: user.id,
            child: Text(user.name ?? "Unknown", style: const TextStyle(fontSize: 14)),
          );
        }).toList();

        return {
          "userModel": userModel,
          "dropdownItems": [
            const DropdownMenuItem<int>(
              value: -1,
              child: Text("--Select--", style: TextStyle(fontSize: 14)),
            ),
            ...dropdownItems
          ]
        };
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching quality user data: $e');
      return {};
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
  static Future<List<DropdownMenuItem<int>>> fetchAndStoreQualityStatusData() async {
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

  //Fetch Search List
  static Future<ChallanListModel?> fetchSearchList(int currentPage, int recordPerPage, String keyword) async {
    try {
      String? token = await SharedPreference.getToken();

      if (token == null || token.isEmpty) {
        print("Error: Token is null or empty. User might not be logged in.");
        return null;
      }

      final Uri url = Uri.https(
        APIUrls.hostUrl,
        APIUrls.fetchSearchList,
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apioption': jsonEncode({
          "currentPage": currentPage.toString(),
          "recordPerPage": recordPerPage.toString(),
          "search": keyword
        }),
      };

      final http.Response response = await http.get( // 🔹 Use POST instead of GET
        url,
        headers: headers,
      );

      if (kDebugMode) {
        print('Response Body: ${response.statusCode}');
        print("Page Number: ${currentPage.toString()}");
        print("Keyword: $keyword");
      } // 👀 Check what API returns

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Response Body: ${response.body}');
          print("Page Number: ${currentPage.toString()}");
        } // 👀 Check what API returns
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

  //Fetch Challan List
  static Future<ChallanListModel?> fetchChallanList(int currentPage, int recordPerPage) async {
    try {
      String? token = await SharedPreference.getToken();

      if (token == null || token.isEmpty) {
        print("Error: Token is null or empty. User might not be logged in.");
        return null;
      }

      final Uri url = Uri.https(
        APIUrls.hostUrl,
        APIUrls.fetchChallanList,
      );


      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apioption': jsonEncode({
          "currentPage": currentPage.toString(),
          "recordPerPage": recordPerPage.toString(),
        }),
      };

      final http.Response response = await http.get( // 🔹 Use POST instead of GET
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Response Body: ${response.body}');
          print("Page Number: ${currentPage.toString()}");
        } // 👀 Check what API returns
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

  // Fetch Calender Events
  static Future<List<EventModel>?> fetchCalenderActivity({required String startDate, required String endDate}) async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return null;

      final Uri url = Uri.parse('https://65.0.190.66/api/report/$startDate/$endDate');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return eventModelFromJson(response.body); // ✅ Using your helper function
      } else {
        print('fetch Activity failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during fetch Activity: $e');
      return null;
    }
  }

  static Future<ActivitySubDetailModel?> fetchSubActivityList(int subActivityId) async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return null;

      final Uri url = Uri.https(
        APIUrls.hostUrl,
        APIUrls.fetchSubActivity,
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apioption': jsonEncode({
          "recordPerPage": 0,
          "searchCondition": {
            "name": "Type",
            "value": "Sub Task",
            "and":{
              "name": "parentId",
              "value": subActivityId
            }
          }
        }),
      };

      final http.Response response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse the response as a list of ActivitySubDetailModel
        return activitySubDetailModelFromJson(response.body);
      } else {
        print('fetch Activity failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during fetch Activity: $e');
      return null;
    }
  }

  static Future<ActivityDetailModel?> fetchSubActivity(int subActivityId) async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return null;

      final Uri url = Uri.https(
        APIUrls.hostUrl,
        "${APIUrls.fetchSubActivity}/$subActivityId", // fixed path construction
      );

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apioption': jsonEncode({
          "recordPerPage": 0,
          "searchCondition": {
            "name": "activityId",
            "value": subActivityId,
            "and": {
              "name": "date",
              "value": "2025-05-23T18:30:00.000Z",
              "operator": "greaterThan",
              "and": {
                "name": "date",
                "value": "2025-05-24T18:29:59.999Z",
                "operator": "lessThan"
              }
            }
          }
        }),
      };

      final http.Response response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return activityDetailModelFromJson(response.body); // fixed incorrect function used
      } else {
        print('fetch Activity failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during fetch Activity: $e');
      return null;
    }
  }

  static Future<ActivityTrackingResponse?> fetchActivityTracking(int subActivityId) async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return null;

      final Uri url = Uri.https(
        APIUrls.hostUrl,
        APIUrls.fetchActivityTracking,
        {
          'apioption': jsonEncode({
            "recordPerPage": 0,
            "searchCondition": {
              "name": "activityId",
              "value": subActivityId,
              "and": {
                "name": "date",
                "value": "2025-05-23T18:30:00.000Z",
                "operator": "greaterThan",
                "and": {
                  "name": "date",
                  "value": "2025-05-24T18:29:59.999Z",
                  "operator": "lessThan"
                }
              }
            }
          }),
        },
      );

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return ActivityTrackingResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to fetch activity: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Exception: $e\n$stackTrace');
      return null;
    }
  }

}