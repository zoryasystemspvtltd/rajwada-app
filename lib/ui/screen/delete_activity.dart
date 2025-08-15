import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

import '../../api_url.dart';
import '../../core/functions/functions.dart';
import '../../core/model/activity_tracking_response.dart';
import '../../core/service/shared_preference.dart';
import '../helper/app_colors.dart';


class DeleteActivityPage extends StatefulWidget {
  final int parentId;
  final DateTime selectedDate;

  const DeleteActivityPage({
    Key? key,
    required this.parentId,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<DeleteActivityPage> createState() => _DeleteActivityPageState();
}

class _DeleteActivityPageState extends State<DeleteActivityPage> {
  List<Map<String, dynamic>> itemList = [];
  bool isLoading = true;

  bool noWorkItems = false;
  double cost = 0.0;
  int manpower = 0;

  // Selected values

  @override
  void initState() {
    super.initState();
    // getAssets();
    // getUomData();
    fetchActivityTracking();
  }

  // Fetch activity tracking data
  // Example static maps (replace with API lookup if dynamic)
  final Map<String, String> itemNamesMap = {
    "1": "Brick",
    "2": "Sand",
    "3": "Pipe",
    "6": "Stone Chips",
    "5": "Turpentine",
    "4": "Cement"
  };

  final Map<String, String> uomNamesMap = {
    "1": "Per Piece",
    "2": "Sack",
    "3": "Jar"
  };

  Future<bool> deleteActivityItem(int id) async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return false;

      final Uri url = Uri.https(
        APIUrls.hostUrl,
        '/api/activitytracking/$id',
      );

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // success
        return true;
      } else {
        if (kDebugMode) {
          print("Delete failed with status: ${response.statusCode}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting activity item: $e");
      }
      return false;
    }
  }


  /// Build start & end of today's date
  Map<String, String> getTodayFilter() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0)
        .toUtc()
        .toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999)
        .toUtc()
        .toIso8601String();

    return {"start": startOfDay, "end": endOfDay};
  }

  Future<void> fetchActivityTracking() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return;

      // 📅 Calculate start & end of today (local → UTC)
      final now = DateTime.now();
      final startOfTodayUtc = DateTime(now.year, now.month, now.day).toUtc();
      final endOfTodayUtc = DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc();

      // 📝 Build apioption header like Postman
      final apiOptionJson = jsonEncode({
        "recordPerPage": 0,
        "searchCondition": {
          "name": "activityId",
          "value": widget.parentId,
          "and": {
            "name": "date",
            "value": startOfTodayUtc.toIso8601String(),
            "operator": "greaterThan",
            "and": {
              "name": "date",
              "value": endOfTodayUtc.toIso8601String(),
              "operator": "lessThan"
            }
          }
        }
      });

      final Uri url = Uri.https(APIUrls.hostUrl, APIUrls.fetchActivityTracking);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'apioption': apiOptionJson,
        },
      );

      print("📡 API URL: $url");
      print("📤 Sent apioption: $apiOptionJson");
      print("📥 Response Status: ${response.statusCode}");
      print("📥 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final responseData = ActivityTrackingResponse.fromJson(jsonResponse);

        for (var item in jsonResponse['items']) {
          print("Cost: ${item['cost']}, Manpower: ${item['manPower']}");
        }

        final Map<int, Map<String, dynamic>> groupedItems = {};

        for (final activity in responseData.items) {
          if (activity.item != null && activity.item!.isNotEmpty) {
            final decoded = jsonDecode(activity.item!);
            if (decoded is List) {
              if (!groupedItems.containsKey(activity.id)) {
                groupedItems[activity.id] = {
                  "id": activity.id,
                  "cost": activity.cost ?? 0.0,
                  "manPower": activity.manPower ?? 0,
                  "date": activity.date ?? "",
                  "details": <Map<String, dynamic>>[],
                };
              }

              for (var e in decoded) {
                if (e is Map) {
                  groupedItems[activity.id]!["details"].add({
                    "itemId": e["itemId"]?.toString() ?? "",
                    "itemName": itemNamesMap[e["itemId"]?.toString()] ?? "",
                    "quantity": e["quantity"]?.toString() ?? "",
                    "uomName": uomNamesMap[e["uomId"]?.toString()] ?? "",
                  });
                }
              }
            }
          }
        }

        // Convert to a list for UI
        final parsedItems = groupedItems.values.toList();

        setState(() {
          itemList = parsedItems;
          noWorkItems = parsedItems.isEmpty;
          cost = responseData.items.isNotEmpty ? responseData.items.first.cost ?? 0.0 : 0.0;
          manpower = responseData.items.isNotEmpty ? responseData.items.first.manPower ?? 0 : 0;
          isLoading = false;
        });

      } else {
        setState(() {
          isLoading = false;
          noWorkItems = true;
        });
      }
    } catch (e) {
      print("❌ Error fetching data: $e");
      setState(() {
        isLoading = false;
        noWorkItems = true;
      });
    }
  }

  String convertUtcIsoToIST(String? isoDateString) {
    if (isoDateString == null) return 'No Date';
    try {
      final dateTime = DateTime.parse(isoDateString);
      final utcDateTime = DateTime.utc(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
      );
      final istDate = utcDateTime.add(const Duration(hours: 5, minutes: 30));
      return DateFormat('dd/MM/yyyy HH:mm').format(istDate);
    } catch (e) {
      print('Error converting to IST: $e');
      return isoDateString;
    }
  }

  Widget buildWorkItemsTable() {
    return ListView.builder(
      itemCount: itemList.length,
      itemBuilder: (context, index) {
        final activity = itemList[index];
        final details = activity["details"] as List<Map<String, dynamic>>;

        // Get date string safely
        final rawDate = activity["date"] as String?;
        print("Date: \(rawDate)");
        print(details);
        print(activity);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Use your conversion function here
                Text(
                  "Date & Time: ${convertUtcIsoToIST(activity["date"])}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Cost: ${activity['cost']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Manpower: ${activity['manPower']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
                Table(
                  border: TableBorder.all(color: Colors.red, width: 1),
                  columnWidths: const {
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.red),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Text(
                            "Item",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Text(
                            "Quantity",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Text(
                            "UOM",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    for (var detail in details)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(detail["itemName"]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(detail["quantity"].toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(detail["uomName"]),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () async {
                    final success = await deleteActivityItem(activity["id"]);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Item deleted successfully")),
                      );
                      fetchActivityTracking();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to delete item")),
                      );
                    }
                  },
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
    return Scaffold(
        appBar: AppBar(
        title: const SizedBox(
          width: 160,
          child: Text("Delete Activity",
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              'Work Items For Date: $todayDate',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: buildWorkItemsTable(), // Your ListView.builder
          ),
        ],
      ),
    );
  }
}
/*
class _DeleteActivityPageState extends State<DeleteActivityPage> {
  bool isLoading = true;
  bool noWorkItems = false;

  String activityDate = '';
  double cost = 0.0;
  int manpower = 0;

  List<Map<String, dynamic>> itemList = [];
  List<ActivityData> activities = []; // store all activities with their own items

  // Dropdown data from API
  List<DropdownMenuItem<int>> assetsDataItems = [];
  List<DropdownMenuItem<int>> uomDataItems = [];

  // Selected values
  int? selectedAssetId;
  int? selectedUomId;
  final TextEditingController quantityController = TextEditingController();
  int? editingIndex;


  @override
  void initState() {
    super.initState();

    // Format and assign date
    activityDate = DateFormat('dd-MM-yyyy').format(widget.selectedDate);
    print(activityDate);

    getAssets();
    getUomData();
    fetchActivityTracking();
  }

  // Fetch Assets for Item dropdown
  Future<void> getAssets() async {
    List<DropdownMenuItem<int>> items =
    await RestFunction.fetchAndStoreAssetData();
    if (mounted) {
      setState(() {
        assetsDataItems = items;
      });
    }
  }

  // Fetch UOMs for UOM dropdown
  Future<void> getUomData() async {
    List<DropdownMenuItem<int>> items =
    await RestFunction.fetchAndStoreUOMData();
    if (mounted) {
      setState(() {
        uomDataItems = items;
      });
    }
  }

  // Fetch activity tracking data
  // Example static maps (replace with API lookup if dynamic)
  final Map<String, String> itemNamesMap = {
    "1": "Brick",
    "2": "Sand",
    "3": "Pipe",
    "6": "Stone Chips",
    "5": "Turpentine",
    "4": "Cement"
  };

  final Map<String, String> uomNamesMap = {
    "1": "Per Piece",
    "2": "Sack",
    "3": "Jar"
  };

  Future<bool> deleteActivityItem(int id) async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return false;

      final Uri url = Uri.https(
        APIUrls.hostUrl,
        '/api/activitytracking/$id',
      );

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // success
        return true;
      } else {
        if (kDebugMode) {
          print("Delete failed with status: ${response.statusCode}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting activity item: $e");
      }
      return false;
    }
  }

  Future<void> fetchActivityTracking() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return;

      // 📅 Calculate start & end of today (local → UTC)
      final now = DateTime.now();
      final startOfTodayUtc = DateTime(now.year, now.month, now.day).toUtc();
      final endOfTodayUtc = DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc();

      // 📝 Build apioption header like Postman
      final apiOptionJson = jsonEncode({
        "recordPerPage": 0,
        "searchCondition": {
          "name": "activityId",
          "value": widget.parentId,
          "and": {
            "name": "date",
            "value": startOfTodayUtc.toIso8601String(),
            "operator": "greaterThan",
            "and": {
              "name": "date",
              "value": endOfTodayUtc.toIso8601String(),
              "operator": "lessThan"
            }
          }
        }
      });

      final Uri url = Uri.https(APIUrls.hostUrl, APIUrls.fetchActivityTracking);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'apioption': apiOptionJson,
        },
      );

      print("📡 API URL: $url");
      print("📤 Sent apioption: $apiOptionJson");
      print("📥 Response Status: ${response.statusCode}");
      print("📥 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final responseData = ActivityTrackingResponse.fromJson(jsonResponse);

        final parsedItems = <Map<String, dynamic>>[];

        for (final activity in responseData.items) {
          if (activity.item != null && activity.item!.isNotEmpty) {
            final decoded = jsonDecode(activity.item!);
            if (decoded is List) {
              for (var e in decoded) {
                if (e is Map) {
                  parsedItems.add({
                    "id": activity.id,
                    "itemName": itemNamesMap[e["itemId"]?.toString()] ?? "",
                    "quantity": e["quantity"]?.toString() ?? "",
                    "uomName": uomNamesMap[e["uomId"]?.toString()] ?? "",
                  });
                }
              }
            }
          }
        }

        setState(() {
          itemList = parsedItems;
          noWorkItems = parsedItems.isEmpty;
          cost = responseData.items.isNotEmpty ? responseData.items.first.cost ?? 0.0 : 0.0;
          manpower = responseData.items.isNotEmpty ? responseData.items.first.manPower ?? 0 : 0;
          isLoading = false;
        });

      } else {
        setState(() {
          isLoading = false;
          noWorkItems = true;
        });
      }
    } catch (e) {
      print("❌ Error fetching data: $e");
      setState(() {
        isLoading = false;
        noWorkItems = true;
      });
    }
  }

  // Add item to the list
  void addItem() {
    if (selectedAssetId != null &&
        selectedUomId != null &&
        quantityController.text.isNotEmpty) {
      String assetName = assetsDataItems
          .firstWhere((e) => e.value == selectedAssetId)
          .child
          .toString();
      String uomName = uomDataItems
          .firstWhere((e) => e.value == selectedUomId)
          .child
          .toString();

      setState(() {
        itemList.add({
          'itemId': selectedAssetId.toString(),
          'item': assetName.replaceAll('Text("', '').replaceAll('")', ''),
          'quantity': quantityController.text,
          'uomId': selectedUomId.toString(),
          'uom': uomName.replaceAll('Text("', '').replaceAll('")', ''),
        });
        quantityController.clear();
        selectedAssetId = null;
        selectedUomId = null;
      });
    }
  }

  // Edit an item
  void editItem(int index) {
    var item = itemList[index];
    setState(() {
      selectedAssetId = int.tryParse(item['itemId'] ?? '');
      quantityController.text = item['quantity'] ?? '';
      selectedUomId = int.tryParse(item['uomId'] ?? '');
      itemList.removeAt(index);
    });
  }

  // Delete an item
  void deleteItem(int index) {
    setState(() => itemList.removeAt(index));
  }

  // Rounded button widget
  Widget roundedButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          width: 160,
          child: Text(
            "Delete Activity",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Colors.white,
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (noWorkItems || itemList.isEmpty) {
      return const Center(
        child: Text(
          "No Work Items",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return buildWorkItemsTable();
  }

  Widget buildWorkItemsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) => Colors.grey[200],
        ),
        columns: const [
          DataColumn(
            label: Text("Item Name", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text("UOM", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: itemList.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item["itemName"] ?? "")),
              DataCell(Text(item["quantity"] ?? "")),
              DataCell(Text(item["uomName"] ?? "")),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    if (item["id"] != null) {
                      _confirmDelete(item["id"].toString());
                    }
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              //deleteActivity(id); // Call your delete function
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const SizedBox(
//           width: 160,
//           child: Text("Delete Activity",
//               style: TextStyle(color: Colors.white, fontSize: 18)),
//         ),
//         backgroundColor: AppColor.colorPrimary,
//         iconTheme: const IconThemeData(color: Colors.white),
//         automaticallyImplyLeading: true,
//       ),
//       backgroundColor: Colors.white,
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : itemList.isEmpty
//           ? const Center(
//         child: Text(
//           "No items to delete",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//       )
//           : Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             // Title
//             Text(
//               'Work Items For Date: $activityDate',
//               style: const TextStyle(
//                   fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//
//             // Cost and Manpower
//             RichText(
//               text: TextSpan(
//                 style:
//                 const TextStyle(color: Colors.black, fontSize: 14),
//                 children: [
//                   const TextSpan(
//                       text: 'Cost: ',
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                   TextSpan(text: 'Rs.$cost'),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 4),
//             RichText(
//               text: TextSpan(
//                 style:
//                 const TextStyle(color: Colors.black, fontSize: 14),
//                 children: [
//                   const TextSpan(
//                       text: 'Manpower: ',
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                   TextSpan(text: '$manpower'),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // Add Item Section
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 5,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Items:',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//
//                   // Scrollable Row to prevent overflow
//                   SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         SizedBox(
//                           width: 120,
//                           child: DropdownButtonFormField<int>(
//                             decoration: const InputDecoration(
//                               labelText: 'Item *',
//                               isDense: true,
//                             ),
//                             value: selectedAssetId,
//                             items: assetsDataItems,
//                             onChanged: (val) => setState(() => selectedAssetId = val),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         SizedBox(
//                           width: 90,
//                           child: TextFormField(
//                             controller: quantityController,
//                             keyboardType: TextInputType.number,
//                             decoration: const InputDecoration(
//                               labelText: 'Quantity *',
//                               isDense: true,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         SizedBox(
//                           width: 100,
//                           child: DropdownButtonFormField<int>(
//                             decoration: const InputDecoration(
//                               labelText: 'UOM *',
//                               isDense: true,
//                             ),
//                             value: selectedUomId,
//                             items: uomDataItems,
//                             onChanged: (val) => setState(() => selectedUomId = val),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       foregroundColor: Colors.white, // White text
//                     ),
//                     onPressed: () {
//                       print("Pressed");
//                       // if (selectedAssetId != null &&
//                       //     selectedUomId != null &&
//                       //     quantityController.text.isNotEmpty) {
//                       //   setState(() {
//                       //     if (editingIndex != null) {
//                       //       // Update existing item
//                       //       itemList[editingIndex!] = {
//                       //         "itemId": selectedAssetId,
//                       //         "itemName": assetsDataItems
//                       //             .firstWhere((e) => e.value == selectedAssetId)
//                       //             .child
//                       //             .toString()
//                       //             .replaceAll("Text(", "")
//                       //             .replaceAll(")", "")
//                       //             .replaceAll('"', ''),
//                       //         "quantity": quantityController.text,
//                       //         "uomId": selectedUomId,
//                       //         "uomName": uomDataItems
//                       //             .firstWhere((e) => e.value == selectedUomId)
//                       //             .child
//                       //             .toString()
//                       //             .replaceAll("Text(", "")
//                       //             .replaceAll(")", "")
//                       //             .replaceAll('"', ''),
//                       //       };
//                       //       editingIndex = null;
//                       //     } else {
//                       //       // Add new item
//                       //       itemList.add({
//                       //         "itemId": selectedAssetId,
//                       //         "itemName": assetsDataItems
//                       //             .firstWhere((e) => e.value == selectedAssetId)
//                       //             .child
//                       //             .toString()
//                       //             .replaceAll("Text(", "")
//                       //             .replaceAll(")", "")
//                       //             .replaceAll('"', ''),
//                       //         "quantity": quantityController.text,
//                       //         "uomId": selectedUomId,
//                       //         "uomName": uomDataItems
//                       //             .firstWhere((e) => e.value == selectedUomId)
//                       //             .child
//                       //             .toString()
//                       //             .replaceAll("Text(", "")
//                       //             .replaceAll(")", "")
//                       //             .replaceAll('"', ''),
//                       //       });
//                       //     }
//                       //     quantityController.clear();
//                       //     selectedAssetId = null;
//                       //     selectedUomId = null;
//                       //   });
//                       // }
//                     },
//                     child: Text(editingIndex != null ? "Update Item" : "Add Item"),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // Table Header
//             // ---------------- Item List Section ----------------
//             Table(
//               border: TableBorder.all(color: Colors.grey),
//               columnWidths: const {
//                 0: FlexColumnWidth(3),
//                 1: FlexColumnWidth(2),
//                 2: FlexColumnWidth(2),
//                 3: FlexColumnWidth(3),
//               },
//               children: [
//                 TableRow(
//                   decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.3)),
//                   children: const [
//                     Padding(padding: EdgeInsets.all(8), child: Text("Item")),
//                     Padding(padding: EdgeInsets.all(8), child: Text("Quantity")),
//                     Padding(padding: EdgeInsets.all(8), child: Text("UOM")),
//                     Padding(padding: EdgeInsets.all(8), child: Text("Actions")),
//                   ],
//                 ),
//                 ...itemList.map((item) {
//                   return TableRow(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8),
//                         child: Text(item["itemName"]?.toString() ?? ''),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8),
//                         child: Text(item["quantity"]?.toString() ?? ''),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8),
//                         child: Text(item["uomName"]?.toString() ?? ''),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8),
//                         child: Row(
//                           children: [
//                             // Edit Icon Button
//                             Visibility(
//                               visible: false,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     selectedAssetId = item["itemId"];
//                                     selectedUomId = item["uomId"];
//                                     quantityController.text = item["quantity"];
//                                     editingIndex = itemList.indexOf(item);
//                                   });
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.orange,
//                                     borderRadius: BorderRadius.circular(5),
//                                   ),
//                                   padding: const EdgeInsets.all(6),
//                                   child: const Icon(
//                                     Icons.edit,
//                                     color: Colors.white,
//                                     size: 16,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 20),
//                             // Delete Icon Button
//                             GestureDetector(
//                               // onTap: () {
//                               //   setState(() {
//                               //     itemList.remove(item);
//                               //   });
//                               // },
//                               onTap: () async {
//                                 final id = item['id']; // the activityId from API
//                                 bool success = await deleteActivityItem(id);
//
//                                 if (success) {
//                                   setState(() {
//                                     // ✅ Remove all items with same id
//                                     itemList.removeWhere((element) => element['id'] == id);
//                                   });
//                                 } else {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text('Failed to delete item. Please try again.')),
//                                   );
//                                 }
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.red,
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 padding: const EdgeInsets.all(6),
//                                 child: const Icon(
//                                   Icons.delete,
//                                   color: Colors.white,
//                                   size: 16,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   );
//                 }),
//               ],
//             ),
//
//             const SizedBox(height: 10),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white, // White text
//               ),
//               onPressed: () {
//                 List<Map<String, String>> finalData = itemList.map((e) {
//                   return {
//                     "itemId": e["itemId"].toString(),
//                     "quantity": e["quantity"].toString(),
//                     "uomId": e["uomId"].toString(),
//                   };
//                 }).toList();
//                 print(jsonEncode(finalData)); // Final array
//               },
//               child: const Text("Save Item List"),
//             ),
// // ----------------------------------------------------
//           ],
//         ),
//       ),
//     );
//   }


  // Custom helper
  Widget roundedButtonIcon(IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(8),
        backgroundColor: color,
        minimumSize: const Size(20, 20),
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}

*/