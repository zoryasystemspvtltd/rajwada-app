import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rajwada_app/ui/screen/project_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/functions/functions.dart';
import '../../core/model/challan_detailItem_model.dart';
import '../../core/model/challan_status_model.dart';
import '../../core/model/quality_status_model.dart';
import '../../core/model/user_privilege_model.dart';
import '../../core/service/shared_preference.dart';
import '../helper/app_colors.dart';
import '../widget/form_field_widget.dart';
import 'package:http/http.dart' as http;

class ViewChallanScreen extends StatefulWidget {
  final int challanId;
  final challanData;

  const ViewChallanScreen(
      {super.key, required this.challanId, this.challanData});

  @override
  _ViewChallanScreenState createState() => _ViewChallanScreenState();
}

class _ViewChallanScreenState extends State<ViewChallanScreen> {

  ChallanDetailItemModel? _challanDetailItem;
  Map<int, Map<String, TextEditingController>> controllers = {};
  bool isLoading = false; // Loader state
  List<ChallanStatusModel> _statusList = [];
  List<DropdownMenuItem<int>> qualityStatusItems = [];
  String userRole = "";
  String userEmail = "";
  UserPrivilegeModel? userPrivilege;
  final TextEditingController _remarksController = TextEditingController();
  bool? approveTapped = false;

  // Method to load user privileges from SharedPreferences
  Future<void> loadUserPrivileges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userPrivilegeJson = prefs.getString('userPrivileges');

    if (userPrivilegeJson != null) {
      Map<String, dynamic> jsonMap = jsonDecode(userPrivilegeJson);
      userPrivilege = UserPrivilegeModel.fromJson(jsonMap);
    }

    printRoles(); // Call printRoles() after loading data
  }

  // Method to print roles
  void printRoles() {
    if (userPrivilege != null && userPrivilege!.roles != null) {
      userRole = userPrivilege!.roles!.join(', ');
      userEmail = userPrivilege?.email ?? "";
      print("User Roles: $userRole");
      print("User Email: $userEmail");
    } else {
      print("No roles found.");
    }
  }

  TextEditingController getController(int index, String fieldKey) {
    if (!controllers.containsKey(index)) {
      controllers[index] = {};
    }
    return controllers[index]!
        .putIfAbsent(fieldKey, () => TextEditingController());
  }

  @override
  void initState() {
    super.initState();
    fetchChallanDetailItem();
    fetchChallanStatus();
    getQualityStatus();
    loadUserPrivileges();
    print(widget.challanData?.status);
  }

  void getQualityStatus() async {
    List<DropdownMenuItem<int>> items =
    await RestFunction.fetchAndStoreQualityStatusData();
    if (mounted) {
      setState(() {
        qualityStatusItems = items;
      });
    }
  }

  Future<void> fetchChallanStatus() async{
    setState(() {
      isLoading = true;
    });

    List<ChallanStatusModel>? data = await RestFunction.fetchChallanStatus();
    if (mounted){
      setState(() {
        isLoading = false;
        _statusList = data!;
      });
    }
  }

  Future<void> fetchChallanDetailItem() async {
    setState(() {
      isLoading = true;
    });
    ChallanDetailItemModel? data =
    await RestFunction.fetchChallanDetailItem(widget.challanId);
    print("Challan Detail Item Count: ${data?.items.length}");
    if (mounted) {
      setState(() {
        isLoading = false;
        _challanDetailItem = data;
        // Clear previous dataRows and controllers
      });
    }
  }

  String getReceiverStatusLabel(String? receiverStatus) {
    if (receiverStatus == null) return "";

    // Convert receiverStatus to int
    int? statusValue = int.tryParse(receiverStatus);

    // Extract QualityStatusModel from DropdownMenuItem<int>
    final matchedItem = qualityStatusItems
        .map((item) => QualityStatusModel(
      name: item.child is Text ? (item.child as Text).data : "Unknown",
      value: item.value,
    ))
        .firstWhere(
          (item) => item.value == statusValue,
      orElse: () => QualityStatusModel(name: "Unknown", value: -1),
    );

    return matchedItem.name ?? "Unknown";
  }


  void _showRemarksDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remarks"),
          content: TextField(
            controller: _remarksController,
            decoration: InputDecoration(
              hintText: "Remarks Here.....",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          actions: [
            // Close Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(backgroundColor: Colors.grey.shade600),
              child: const Text("Close", style: TextStyle(color: Colors.white)),
            ),

            // Submit Button
            TextButton(
              onPressed: () async {
                print("Submitted Remarks: ${_remarksController.text}");
                await sendPatchData();
                // Navigator.of(context).pop(); // Close dialog
              },
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendPatchData() async {
    setState(() {
      isLoading = true; // Show loader before API call
    });
    String? token = await SharedPreference.getToken();
    if (token == null) return; // Return null if token is missing
    String apiUrl = "";
    apiUrl = "https://65.0.190.66/api/LevelSetup/${widget.challanData?.id}";


    // Request body
    Map<String, String> requestBody = {
      "id": widget.challanData?.id.toString() ?? "",
      "status": approveTapped == true ?  "4" : "6",
      "approvedRemarks" : _remarksController.text,
      "approvedBy" : userEmail,
      "approvedDate" : DateTime.now().toString(),
      "isApproved" : approveTapped == true ? "true" : "false"
    };

    if (kDebugMode) {
      print("Request Body: $requestBody");
      print("Token: $token");
    }

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false; // Hide loader after API response
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Head Approval Successfully",
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.normal),
                ),
                duration: Duration(seconds: 2),
              )
          );
        });

      } else {
        setState(() {
          isLoading = false; // Hide loader after API response
        });
        if (kDebugMode) {
          print("Failed to send data: ${response.statusCode}");
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loader after API response
      });
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          width: 120,
          child: Text("View Challan",
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true, // This is default
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: userRole == "New Civil Head" && widget.challanData?.status == 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () async {
                        _remarksController.text = "";
                        approveTapped = true;
                        setState(() {

                          _showRemarksDialog();
                        });
                      },
                      child: const Text("Approve",
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey),
                      onPressed: () {
                        _remarksController.text = "";
                        approveTapped = false;
                        setState(() {
                          _showRemarksDialog();
                        });
                      },
                      child: const Text("Reject",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailScreen(projectId: widget.challanData?.projectId ?? 0),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Project: ", // Static text
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: widget.challanData?.projectName ?? "", // Dynamic text
                            style: const TextStyle(
                              fontSize: 15, // Larger font size for project name
                              fontWeight: FontWeight.w500,
                              color: AppColor.colorPrimary, // Different color for project name
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Quality In Charge: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: widget.challanData?.inChargeName ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: Colors.black, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Status: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // Check if the current status matches any status in the _statusList
                        TextSpan(
                          text: _statusList.any((status) =>
                          status.value == widget.challanData?.status) == true
                              ? _statusList.firstWhere(
                                  (status) => status.value == widget.challanData?.status,
                              orElse: () => ChallanStatusModel(name: "N/A"))
                              .name
                              : "Status not found", // Fallback text if status is not found
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: Colors.black, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Tracking No: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: widget.challanData?.trackingNo ?? "", // Use status directly
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: Colors.black, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Vehicle No: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: widget.challanData?.vechileNo ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: Colors.black, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Document Date: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: DateFormat('yyyy-MM-dd').format(
                              DateTime.parse(widget.challanData?.documentDate)), // Dynamic text
                          style: const TextStyle(
                            fontSize: 14, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: Colors.black, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Supplier Name: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: widget.challanData?.supplierName ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 14, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: Colors.black, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Remarks: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: widget.challanData?.approvedRemarks ?? "", // Use status directly
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: Colors.black, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40,),
              const Text(
                "Item List",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20,),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                shrinkWrap: true, // Helps avoid infinite height issues
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (_challanDetailItem?.items.length ?? 0),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "itemName",
                                  isEnabled: false,
                                  label:  _challanDetailItem!.items[index].name ?? "",
                                  controller: getController(index, "itemName"),
                                  onChanged: (String ) { },
                                ),
                              )),
                          const SizedBox(width: 10),
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "quantity",
                                  isEnabled: false,
                                  label:  _challanDetailItem!.items[index].quantity ?? "",
                                  controller: getController(index, "quantity"),
                                  onChanged: (String ) { },
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "price",
                                  isEnabled: false,
                                  label:  _challanDetailItem!.items[index].price ?? "",
                                  controller: getController(index, "price"),
                                  onChanged: (String ) { },
                                ),
                              )),
                          const SizedBox(width: 10),
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "uomName",
                                  isEnabled: false,
                                  label:  _challanDetailItem!.items[index].uomName ?? "",
                                  controller: getController(index, "uomName"),
                                  onChanged: (String ) { },
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "qualityStatus",
                                  isEnabled: false,
                                  label:  getReceiverStatusLabel(_challanDetailItem!.items[index].qualityStatus),
                                  controller: getController(index, "qualityStatus"),
                                  onChanged: (String ) { },
                                ),
                              )),
                          const SizedBox(width: 10),
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "qualityRemarks",
                                  isEnabled: false,
                                  label:  _challanDetailItem!.items[index].qualityRemarks ?? "",
                                  controller: getController(index, "qualityRemarks"),
                                  onChanged: (String ) { },
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "receiverStatus",
                                  isEnabled: false,
                                  label:  getReceiverStatusLabel(_challanDetailItem!.items[index].receiverStatus),
                                  controller: getController(index, "receiverStatus"),
                                  onChanged: (String ) { },
                                ),
                              )),
                          const SizedBox(width: 10),
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "receiverRemarks",
                                  isEnabled: false,
                                  label:  _challanDetailItem!.items[index].receiverRemarks ?? "",
                                  controller: getController(index, "receiverRemarks"),
                                  onChanged: (String ) { },
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 30,),
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

}
