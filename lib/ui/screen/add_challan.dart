import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rajwada_app/core/model/challan_detailItem_model.dart';
import 'package:rajwada_app/core/model/user_privilege_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../core/functions/auth_function.dart';
import '../../core/functions/functions.dart';
import '../../core/model/challan_detail_model.dart';
import '../../core/model/challan_status_model.dart';
import '../../core/model/login_data_model.dart';
import '../../core/model/quality_status_model.dart';
import '../../core/model/quality_user_model.dart';
import '../../core/service/shared_preference.dart';
import '../helper/app_colors.dart';
import '../widget/addTextDialog.dart';
import '../widget/custom_date_field.dart';
import '../widget/custom_text_field.dart';
import '../widget/form_field_widget.dart';
import 'package:http/http.dart' as http;

class ChallanEntryScreen extends StatefulWidget {
  final bool isEdit;
  final int challanId;

  const ChallanEntryScreen(
      {super.key, required this.isEdit, required this.challanId});

  @override
  _ChallanEntryScreenState createState() => _ChallanEntryScreenState();
}

class _ChallanEntryScreenState extends State<ChallanEntryScreen> {
  ///MARK: - Variable Declaration
  final AuthService authService = AuthService(); // Initialize AuthService
  final RestFunction restService = RestFunction();
  final LoginDataModel loginModel = LoginDataModel();

  XFile? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController trackingNoController = TextEditingController();
  final TextEditingController vehicleNoController = TextEditingController();
  final TextEditingController documentDateController = TextEditingController();
  final TextEditingController quantityDataController = TextEditingController();
  final TextEditingController priceDataController = TextEditingController();
  final TextEditingController receiverRemarkDataController =
      TextEditingController();

  String selectedQuality = "--Select--";
  String selectedProject = "--Select--";
  String selectedQualityInCharge = "--Select--";

  List<DropdownMenuItem<int>> userProjectItems = [];
  List<DropdownMenuItem<int>> quantityInChargeItems = [];
  List<DropdownMenuItem<int>> assignForApprovalItems = [];

  List<DropdownMenuItem<int>> supplierDataItems = [];

  List<DropdownMenuItem<int>> assetsDataItems = [];
  List<DropdownMenuItem<int>> uomDataItems = [];
  List<DropdownMenuItem<int>> qualityStatusItems = [];

  int? selectedProjectId;
  int? selectedQuantityInChargeId; // Default selected ID
  int? selectedSupplierId;
  int? selectedForApprovalId;

  int? selectedAssetId;
  int? selectedUomId;
  int? selectedReceiverStatusId; // Default selected ID
  int? selectedQualityStatusId;

  bool? showListView; // Initially hidden
  Map<int, Map<String, TextEditingController>> controllers = {};
  ChallanDetailModel? _challanDetail;
  ChallanDetailItemModel? _challanDetailItem;
  UserPrivilegeModel? userPrivilege;
  QualityUserModel? userModel;

  bool? isEnabled; // Allows user interaction

  String selectedProjectName = ""; // Stores the corresponding project name
  String selectedQualityInChargeName =
      ""; // Stores the corresponding QualityInCharge Name
  String selectedForApprovalName = "";
  String selectedForApprovalEmail = "";
  String selectedQualityInChargeEmail = "";
  String selectedSupplierName = ""; // Stores the corresponding Supplier Name
  String selectedItemName = "";
  String selectedUomName = "";
  String selectedReceiverStatusName = "";
  String selectedItemPrice = "";
  String selectedItemQuantity = "";
  String selectedReceiverRemark = "";
  String selectedQualityStatusName = "";
  String selectedQualityStatusRemark = "";
  String userRole = "";

  int? apiResponseValue; // Variable to store the integer response
  bool isLoading = false; // Loader state
  bool? savePressed = false;

  String challanItemID = "";

  List<Map<String, dynamic>> dataRows = [];
  List<ChallanStatusModel> _statusList = [];


  Future<void> _openCamera() async {
    // Open the device camera
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _capturedImage = image;
      });
    }
  }

  void _showFullScreenImage() {
    if (_capturedImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imagePath: _capturedImage!.path),
      ),
    );
  }

  Future<void> sendItemDataForEditToAPI() async {
    setState(() {
      isLoading = true; // Show loader before API call
    });
    String? token = await SharedPreference.getToken();
    if (token == null) return; // Return null if token is missing

    final String apiUrl =
        "https://65.0.190.66/api/levelSetupDetails/$challanItemID";

    // Request body
    Map<String, String> requestBody = {
      "HeaderId": "${_challanDetail?.id}",
      "headerId": "${_challanDetail?.id}",
      "id": challanItemID,
      "itemId": selectedAssetId.toString(),
      "key": _challanDetail?.key ?? "",
      "member": _challanDetail?.member ?? "",
      "mode": "edit",
      "name": selectedItemName,
      "price": selectedItemPrice,
      "quantity": selectedItemQuantity,
      "readonly": "false",
      "receiverRemarks": selectedReceiverRemark,
      "receiverStatus": selectedReceiverStatusId.toString(),
      "uomId": selectedUomId.toString(),
      "uomName": selectedUomName,
      "qualityStatus": selectedQualityStatusId.toString(),
      "qualityRemarks": selectedQualityStatusRemark
    };
    if (kDebugMode) {
      print("URL: $apiUrl");
      print("Request Body: $requestBody");
      print("Token: $token");
    }

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Item Edited Successfully",
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.normal),
                ),
                duration: Duration(seconds: 2),
              )
          );
          Navigator.pop(context);
          isLoading = false; // Hide loader after API response
        });

        // if (kDebugMode) {
        //   print("API Response Value: $apiResponseValue");
        // }
      } else {
        setState(() {
          isLoading = false; // Hide loader after API response
        });
        if (kDebugMode) {
          //print("Failed to send data: ${response.statusCode}");
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

  Future<void> sendItemDataToAPI() async {
    setState(() {
      isLoading = true; // Show loader before API call
    });
    String? token = await SharedPreference.getToken();
    if (token == null) return; // Return null if token is missing

    const String apiUrl = "https://65.0.190.66/api/levelSetupDetails";

    // Request body
    Map<String, String> requestBody = {
      "HeaderId": !widget.isEdit
          ? apiResponseValue.toString()
          : "${_challanDetail?.id}",
      "itemId": selectedAssetId.toString(),
      "mode": "add",
      "name": selectedItemName,
      "price": selectedItemPrice,
      "quantity": selectedItemQuantity,
      "readonly": "false",
      "receiverRemarks": selectedReceiverRemark,
      "receiverStatus": selectedReceiverStatusId.toString(),
      "uomId": selectedUomId.toString(),
      "uomName": selectedUomName,
    };
    if (kDebugMode) {
      print("Request Body: $requestBody");
      print("Token: $token");
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() {
          //Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Item Added Successfully",
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.normal),
                ),
                duration: Duration(seconds: 2),
              )
          );
          isLoading = false; // Hide loader after API response
        });

        // if (kDebugMode) {
        //   print("API Response Value: $apiResponseValue");
        // }
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

  Future<void> sendDataToAPI() async {
    setState(() {
      isLoading = true; // Show loader before API call
    });
    String? token = await SharedPreference.getToken();
    if (token == null) return; // Return null if token is missing

    const String apiUrl = "https://65.0.190.66/api/LevelSetup";

    // Request body
    Map<String, String> requestBody = {
      "projectId": selectedProjectId.toString(),
      "projectName": selectedProjectName,
      "inChargeId": selectedQuantityInChargeId.toString(),
      "inChargeName": selectedQualityInChargeName,
      "documentDate": documentDateController.text,
      "supplierId": selectedSupplierId.toString(),
      "supplierName": selectedSupplierName,
      "trackingNo": trackingNoController.text,
      "vechileNo": vehicleNoController.text,
    };

    if (kDebugMode) {
      print("Request Body: $requestBody");
      print("Token: $token");
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() {
          apiResponseValue = int.tryParse(response.body);
          showListView = true; // Convert response to integer
          isLoading = false; // Hide loader after API response
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Challan Added Successfully",
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.normal),
                ),
                duration: Duration(seconds: 2),
              )
          );
        });

        if (kDebugMode) {
          print("API Response Value: $apiResponseValue");
        }
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

  Future<void> sendFullDataToAPI() async {
    setState(() {
      isLoading = true; // Show loader before API call
    });
    String? token = await SharedPreference.getToken();
    if (token == null) return; // Return null if token is missing

    String apiUrl = "https://65.0.190.66/api/LevelSetup/$apiResponseValue";

    // Request body
    Map<String, String> requestBody = {
      "projectId": selectedProjectId.toString(),
      "projectName": selectedProjectName,
      "inChargeId": selectedQuantityInChargeId.toString(),
      "inChargeName": selectedQualityInChargeName,
      "documentDate": documentDateController.text,
      "supplierId": selectedSupplierId.toString(),
      "supplierName": selectedSupplierName,
      "trackingNo": trackingNoController.text,
      "vechileNo": vehicleNoController.text,
    };

    if (kDebugMode) {
      print("Request Body: $requestBody");
      print("Token: $token");
    }

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() async {
          isLoading = false; // Hide loader after API response
          await sendPatchData();
        });

        if (kDebugMode) {
          print("API Response Value: $apiResponseValue");
        }
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

  Future<void> sendPatchData() async {
    setState(() {
      isLoading = true; // Show loader before API call
    });
    String? token = await SharedPreference.getToken();
    if (token == null) return; // Return null if token is missing
    String apiUrl = "";

    if(userRole == "Quality Engineer"){
      apiUrl = "https://65.0.190.66/api/LevelSetup/${_challanDetail?.id}";
    } else{
      apiUrl = "https://65.0.190.66/api/LevelSetup/$apiResponseValue";
    }


    // Request body
    Map<String, String> requestBody = {
      "id": userRole == "Quality Engineer" ? "${_challanDetail?.id}" : apiResponseValue.toString(),
      "member" : userRole == "Quality Engineer" ? selectedForApprovalEmail : selectedQualityInChargeEmail,
      "status": userRole == "Quality Engineer" ?  "3" : "2"
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
                  "Challan Patched Successfully",
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.normal),
                ),
                duration: Duration(seconds: 2),
              )
          );
        });

        if (kDebugMode) {
          print("API Response Value: $apiResponseValue");
        }
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

  //Fetch Pre Data Sets
  Future<void> getUserData() async {
    Map<String, dynamic> data = await RestFunction.fetchQualityUsersDropdown();

    if (mounted && data.isNotEmpty) {
      setState(() {
        userModel = data["userModel"]; // ✅ Assign userModel properly
        quantityInChargeItems = data["dropdownItems"];
      });

      // ✅ Debug print to ensure userModel is populated
      // if (kDebugMode) {
      //   print("User Model Data Fetched:");
      //   print("Total Records: ${userModel?.totalRecords}");
      //   for (var user in userModel?.items ?? []) {
      //     print("ID: ${user.id}, Name: ${user.name}, Email: ${user.email}");
      //   }
      // }
    }
  }

  Future<void> getAssignForApprovalData() async {
    Map<String, dynamic> data = await RestFunction.fetchAssignForApprovalUsersDropdown();
    if (mounted && data.isNotEmpty) {
      setState(() {
        userModel = data["userModel"]; // ✅ Assign userModel properly
        assignForApprovalItems = data["dropdownItems"];
      });

      // ✅ Debug print to ensure userModel is populated
      // if (kDebugMode) {
      //   print("User Model Data Fetched:");
      //   print("Total Records: ${userModel?.totalRecords}");
      //   for (var user in userModel?.items ?? []) {
      //     print("ID: ${user.id}, Name: ${user.name}, Email: ${user.email}");
      //   }
      // }
    }
  }

  Future<void> getUserProjects() async {
    List<DropdownMenuItem<int>> items =
        await RestFunction.fetchAndStoreUserProjectData();
    if (mounted) {
      setState(() {
        userProjectItems = items;
      });
    }
  }

  Future<void> getSupplier() async {
    List<DropdownMenuItem<int>> items =
        await RestFunction.fetchAndStoreSupplierData();
    if (mounted) {
      setState(() {
        supplierDataItems = items;
      });
    }
  }

  Future<void> getAssets() async {
    List<DropdownMenuItem<int>> items =
        await RestFunction.fetchAndStoreAssetData();
    if (mounted) {
      setState(() {
        assetsDataItems = items;
      });
    }
  }

  Future<void> getUomData() async {
    List<DropdownMenuItem<int>> items =
        await RestFunction.fetchAndStoreUOMData();
    if (mounted) {
      setState(() {
        uomDataItems = items;
      });
    }
  }

  Future<void> getQualityStatus() async {
    List<DropdownMenuItem<int>> items =
        await RestFunction.fetchAndStoreQualityStatusData();
    if (mounted) {
      setState(() {
        qualityStatusItems = items;
      });
    }
  }

  Future<void> fetchChallanData() async {
    ChallanDetailModel? data =
        await RestFunction.fetchChallanDetail(widget.challanId);
    if (mounted) {
      setState(() {
        _challanDetail = data;
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
    ChallanDetailItemModel? data =
        await RestFunction.fetchChallanDetailItem(widget.challanId);
    print("Challan Detail Item Count: ${data?.items.length}");
    if (mounted) {
      setState(() {
        _challanDetailItem = data;
        // Clear previous dataRows and controllers
        dataRows.clear();
        controllers.clear();

        if (_challanDetailItem != null && _challanDetailItem!.items.isNotEmpty) {
          for (var item in _challanDetailItem!.items) {
            int newIndex = dataRows.length;

            // Map fetched items into dataRows
            dataRows.add({
              "itemId": item.itemId,
              "name": item.name,
              "price": item.price,
              "quantity": item.quantity,
              "receiverRemarks": item.receiverRemarks,
              "receiverStatus": item.receiverStatus,
              "qualityStatus": item.qualityStatus,
              "qualityRemark": item.qualityRemarks,
              "uomId": item.uomId,
              "uomName": item.uomName,
            });

            // Initialize controllers for editable fields
            controllers[newIndex] = {
              "quantity": TextEditingController(text: item.quantity.toString()),
              "price": TextEditingController(text: item.price.toString()),
            };
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Ensures _loadData() runs after initState() completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });

    if (widget.isEdit) {
      isEnabled = false;
      showListView = true;
    } else {
      isEnabled = true;
      showListView = false;
    }
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        loadUserPrivileges(),
        getUserData(),
        getAssignForApprovalData(),
        getUserProjects(),
        getSupplier(),
        getAssets(),
        getUomData(),
        getQualityStatus(),
        fetchChallanData(),
        fetchChallanDetailItem(),
        fetchChallanStatus(),
      ]);
      print("✅ All data loaded successfully!");
    } catch (e) {
      print("⚠️ Error loading data: $e");
    }
  }

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
      print("User Roles: $userRole");
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

  void addDynamicRows() {
    setState(() {
      // Reset selected values
      selectedAssetId = 0;
      selectedItemName = "";
      selectedUomId = 0;
      selectedUomName = "";
      selectedReceiverStatusId = 0;
      selectedReceiverRemark = "";
      selectedItemQuantity = "";
      selectedItemPrice = "";

      // Ensure that we add one item each time
      if (_challanDetailItem != null) {
        // Create a new ChallanDetailItem using default empty values
        var newItem = ChallanDetailItem(
          itemId: null,
          name: "Item",
          price: "Price",
          quantity: "Quantity",
          receiverRemarks: "Receiver Remark",
          receiverStatus: null,
          uomId: null,
          uomName: "UOM Name",
        );

        // Add the newly created item to the list
        _challanDetailItem!.items.add(newItem);

        // Get the new index after adding the item to the list
        int newIndex = _challanDetailItem!.items.length - 1;

        // Initialize controllers for the new row
        controllers[newIndex] = {
          "quantity": TextEditingController(),
          "price": TextEditingController(),
        };
      }
    });
  }

  void addRow() {
    setState(() {
      int newIndex = dataRows.length; // Get new row index

      selectedAssetId = 0;
      selectedItemName = "";
      selectedUomId = 0;
      selectedUomName = "";
      selectedReceiverStatusId = 0;
      selectedReceiverRemark = "";
      selectedItemQuantity = "";
      selectedItemPrice = "";

      dataRows.add({
        "itemId": null,
        "name": "",
        "price": "",
        "quantity": "",
        "receiverRemarks": "",
        "receiverStatus": null,
        "uomId": null,
        "uomName": "",
      });

      // Initialize controllers for the new row
      controllers[newIndex] = {
        "quantity": TextEditingController(),
        "price": TextEditingController(),
      };
    });
  }


  void removeRow(int index) {
    setState(() {
      // Remove the corresponding row
      dataRows.removeAt(index);

      // Rebuild the controllers map after shifting indices
      Map<int, Map<String, TextEditingController>> updatedControllers = {};

      for (int i = 0; i < dataRows.length; i++) {
        updatedControllers[i] = controllers[i + 1] ?? {};
      }

      controllers = updatedControllers;
    });
  }

  String getQualityStatusLabel(String? receiverStatus) {
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 120,
          child: Text(widget.isEdit ? "Edit Challan" : "Add Challan",
              style: const TextStyle(color: Colors.white, fontSize: 18)),
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
              const SizedBox(
                height: 20,
              ),
              Visibility(
                visible: userRole == "Quality Engineer" && (_challanDetail?.status == 2 || _challanDetail?.status == 0 || _challanDetail?.status == 3),
                child: Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    height: 45,
                    width: 210,
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        labelText: "Assign for Approval *",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      value: selectedForApprovalId,

                      // ✅ Filter out the logged-in user from the list
                      items: assignForApprovalItems
                          .where((item) => item.value != userModel?.items[0].id) // Exclude logged-in user
                          .toList(),

                      onChanged: (widget.isEdit)
                          ? (value) async {
                        setState(() {
                          selectedForApprovalId = value!;

                          // ✅ Ensure userModel is not null before accessing items
                          if (userModel != null && userModel!.items.isNotEmpty) {
                            final selectedUser = userModel!.items.firstWhere(
                                  (user) => user.id == selectedForApprovalId,
                              orElse: () => Item(
                                id: -1,
                                name: "Unknown",
                                email: "No Email",
                                disable: false, // Required field
                              ),
                            );

                            // ✅ Store the name and email safely
                            selectedForApprovalName = selectedUser.name ?? "No Name";
                            selectedForApprovalEmail = selectedUser.email ?? "No Email";
                          } else {
                            // ✅ Handle case where userModel is null
                            selectedForApprovalName = "No Name";
                            selectedForApprovalEmail = "No Email";
                          }

                          if (kDebugMode) {
                            print("Selected User: $selectedForApprovalId");
                            print("Selected Email: $selectedForApprovalEmail");
                            print("Selected ID: $selectedForApprovalName");
                          }
                        });
                        await sendPatchData();
                      }
                          : null, // Disable dropdown interaction when editing
                    ),
                  ),
                ),

              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Reduced padding
                          filled: widget.isEdit ? isEnabled! : isEnabled,
                          fillColor:
                              widget.isEdit ? Colors.grey.shade200 : Colors.white,
                          labelText: widget.isEdit
                              ? _challanDetail?.projectName
                              : "Project *",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        value: selectedProjectId,
                        items: userProjectItems,
                        onChanged: (!widget.isEdit)
                            ? (value) {
                                setState(() {
                                  selectedProjectId = value!;
                                  selectedProjectName = (userProjectItems
                                              .firstWhere(
                                                  (item) =>
                                                      item.value ==
                                                      selectedProjectId,
                                                  orElse: () =>
                                                      const DropdownMenuItem<int>(
                                                          value: null,
                                                          child: Text('')))
                                              .child as Text)
                                          .data ??
                                      ""; // Extract text from Text widget
                                });

                                if (kDebugMode) {
                                  print(
                                      "Selected Project ID: $selectedProjectId");
                                  print(
                                      "Selected Project Name: $selectedProjectName");
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
                          filled: widget.isEdit ? isEnabled! : isEnabled,
                          fillColor: widget.isEdit ? Colors.grey.shade200 : Colors.white,
                          labelText: widget.isEdit
                              ? _challanDetail?.inChargeName
                              : "Quality In Charge *",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        value: selectedQuantityInChargeId,
                        items: quantityInChargeItems,
                        onChanged: (!widget.isEdit && isEnabled == true)
                            ? (value) {
                          setState(() {
                            selectedQuantityInChargeId = value!;

                            // ✅ Ensure userModel is not null before accessing items
                            if (userModel != null && userModel!.items.isNotEmpty) {
                              final selectedUser = userModel!.items.firstWhere(
                                    (user) => user.id == selectedQuantityInChargeId,
                                orElse: () => Item(
                                  id: -1,
                                  name: "Unknown",
                                  email: "No Email",
                                  disable: false, // Required field
                                ),
                              );

                              // ✅ Store the name and email safely
                              selectedQualityInChargeName = selectedUser.name ?? "No Name";
                              selectedQualityInChargeEmail = selectedUser.email ?? "No Email";
                            } else {
                              // ✅ Handle case where userModel is null
                              selectedQualityInChargeName = "No Name";
                              selectedQualityInChargeEmail = "No Email";
                            }

                            if (kDebugMode) {
                              print("Selected User: $selectedQualityInChargeName");
                              print("Selected Email: $selectedQualityInChargeEmail");
                              print("Selected ID: $selectedQuantityInChargeId");
                            }
                          });
                        }
                            : null, // Disable dropdown when necessary
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: SizedBox(
                    height: 45,
                    child: CustomTextField(
                      isEnabled: widget.isEdit ? false : true,
                      label: widget.isEdit
                          ? _challanDetail?.trackingNo ?? ""
                          : "Tracking No",
                      controller: trackingNoController,
                      hintText: "Tracking No Here...",
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: CustomDateField(
                        isEnabled: widget.isEdit ? false : true,
                        label: widget.isEdit
                            ? (_challanDetail?.documentDate != null
                            ? DateFormat('yyyy-MM-dd').format(
                            DateTime.parse(_challanDetail!.documentDate!))
                            : "")
                            : "Document Date *",
                        controller: documentDateController,
                        initialDate: widget.isEdit && _challanDetail?.documentDate != null
                            ? DateTime.parse(_challanDetail!.documentDate!)
                            : DateTime.now(), // Default to current date if null
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: SizedBox(
                    height: 45,
                    child: CustomTextField(
                      isEnabled: widget.isEdit ? false : true,
                      label: widget.isEdit
                          ? _challanDetail?.vechileNo ?? ""
                          : "Vehicle No",
                      controller: vehicleNoController,
                      hintText: "Vehicle No Here...",
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Reduced padding
                          filled: widget.isEdit ? isEnabled! : isEnabled,
                          // When disabled, apply a gray background
                          fillColor:
                              widget.isEdit ? Colors.grey.shade200 : Colors.white,
                          // Light gray background when disabled
                          labelText: widget.isEdit
                              ? _challanDetail?.supplierName
                              : "Supplier Name *",
                          border: OutlineInputBorder(
                            // Default border
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            // Unfocused border
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            // Focused border
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        value: selectedSupplierId,
                        items: supplierDataItems,
                        onChanged: (!widget.isEdit && isEnabled == true)
                            ? (value) {
                                setState(() {
                                  selectedSupplierId = value!;
                                  selectedSupplierName = (supplierDataItems
                                              .firstWhere(
                                                  (item) =>
                                                      item.value ==
                                                      selectedSupplierId,
                                                  orElse: () =>
                                                      const DropdownMenuItem<
                                                              int>(
                                                          value: null,
                                                          child: Text('')))
                                              .child as Text)
                                          .data ??
                                      ""; // Extract text from Text widget
                                });

                                if (kDebugMode) {
                                  print(
                                      "Selected Supplier ID: $selectedSupplierId");
                                  print(
                                      "Selected Supplier Name: $selectedSupplierName");
                                }
                              }
                            : null, // Disable dropdown interaction
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              widget.isEdit == false && savePressed == false
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () async {
                                  savePressed = true;
                                  setState(() {
                                    if (kDebugMode) {
                                      print("Project Id: $selectedProjectId");
                                      print(
                                          "Project Name: $selectedProjectName");
                                      print(
                                          "Quality In Charge: $selectedQualityInChargeName");
                                      print(
                                          "Quality In Charge Id: $selectedQuantityInChargeId");
                                      print(
                                          "Tracking No: ${trackingNoController.text}");
                                      print(
                                          "Document Date: ${documentDateController.text}");
                                      print(
                                          "Vehicle No: ${vehicleNoController.text}");
                                      print("Supplier Id: $selectedSupplierId");
                                      print(
                                          "Supplier Name: $selectedSupplierName");
                                    }
                                  });
                                  await sendDataToAPI(); // Call the API function
                                },
                                child: const Text("Save",
                                    style: TextStyle(color: Colors.white)),
                              ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey),
                          onPressed: () {
                            setState(() {
                             // print(!widget.isEdit);
                              savePressed = false;
                              Navigator.pop(context, "Your Returned Data");
                            });
                          },
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  : const Row(),
              const SizedBox(height: 40),
              if (showListView == true) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Item List",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    userRole == "Quality Engineer" ? const SizedBox.shrink() : IconButton(
                      icon: const Icon(
                        Icons.add_circle_rounded,
                        color: Colors.blue,
                        size: 30,
                      ),
                      onPressed: () {
                        // Check if _challanDetailItem is not null and if the documentDate is equal to today's date
                        if(!widget.isEdit){
                          addRow();
                        } else{
                          if (_challanDetail != null &&
                              _challanDetail!.documentDate != null) {
                            // Convert the documentDate to DateTime for comparison
                            DateTime documentDate = DateTime.parse(_challanDetail!.documentDate.toString());
                            DateTime currentDate = DateTime.now();

                            // Compare only the date part (ignoring the time)
                            if (documentDate.year == currentDate.year &&
                                documentDate.month == currentDate.month &&
                                documentDate.day == currentDate.day) {
                                // If dates are the same, proceed with addDynamicRows
                                addDynamicRows();

                            } else {
                              // You can show a message or handle cases where the dates don't match
                              showErrorDialog(context, "Please ensure the document date is today's date before adding an item.");
                              print("Document date is not today's date.");
                            }
                          }
                        }

                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true, // Helps avoid infinite height issues
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.isEdit
                      ? (_challanDetailItem?.items.length ?? 0)
                      : dataRows.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            userRole == "Quality Engineer" ?
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
                                )) :
                            Expanded(
                              child: SizedBox(
                                height: 45,
                                child: DropdownButtonFormField<int>(
                                  decoration: InputDecoration(
                                    labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Reduced padding
                                    filled:
                                        widget.isEdit ? isEnabled! : isEnabled,
                                    // When disabled, apply a gray background
                                    fillColor: widget.isEdit
                                        ? Colors.grey.shade200
                                        : Colors.white,
                                    // Light gray background when disabled
                                    labelText: widget.isEdit &&
                                            _challanDetailItem!.items.length >
                                                index
                                        ? _challanDetailItem?.items[index].name
                                        : "Item *",
                                    border: OutlineInputBorder(
                                      // Default border
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      // Unfocused border
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      // Focused border
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  // Smaller text size
                                  value: (widget.isEdit &&
                                          _challanDetailItem!.items.length >
                                              index)
                                      ? int.tryParse(_challanDetailItem!
                                          .items[index].name
                                          .toString())
                                      : int.tryParse(dataRows[index]["name"].toString()),
                                  // ✅ Now stored in dataRows,
                                  items: assetsDataItems,
                                  onChanged: !(widget.isEdit && isEnabled == true)
                                      ? (value) {
                                          setState(() {
                                            if(_challanDetailItem!.items.isEmpty){
                                              dataRows[index]["itemId"] = value.toString();
                                              selectedAssetId = int.tryParse(dataRows[index]["itemId"]);
                                              dataRows[index]["name"] = (assetsDataItems
                                                  .firstWhere(
                                                    (item) => item.value == value,
                                                orElse: () => const DropdownMenuItem(
                                                    value: 0, child: Text("Unknown")),
                                              )
                                                  .child as Text).data
                                                  .toString();
                                              selectedItemName = dataRows[index]["name"];
                                            } else {
                                              _challanDetailItem!.items[index].itemId = value.toString();
                                              selectedAssetId =
                                                  int.tryParse(_challanDetailItem!.items[index].itemId ?? ""); // Store selected ID

                                              // Find the selected item name from the list
                                              _challanDetailItem!.items[index].name = (assetsDataItems
                                                  .firstWhere(
                                                    (item) =>
                                                item.value ==
                                                    selectedAssetId,
                                                orElse: () =>
                                                const DropdownMenuItem(
                                                    value: 0,
                                                    child: Text(
                                                        "Unknown")), // Fallback if not found
                                              )
                                                  .child as Text)
                                                  .data.toString() ??
                                                  "";
                                              selectedItemName = _challanDetailItem!.items[index].name ?? "";
                                            }
                                          });
                                          if (kDebugMode) {
                                            print(
                                                "Selected Item ID: $selectedAssetId, Name: $selectedItemName}");
                                          }
                                        }
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            userRole == "Quality Engineer" ?
                            Expanded(
                                child: SizedBox(
                                  height: 45,
                                  child: FormFieldItem(
                                    index: index,
                                    fieldKey: "quantity",
                                    isEnabled: false,
                                    label:  getController(index, "quantity").text.isNotEmpty ? "" : "Quantity",
                                    controller: getController(index, "quantity"),
                                    onChanged: (String ) { },
                                  ),
                                )) :
                            Expanded(
                                child: SizedBox(
                              height: 45,
                              child: FormFieldItem(
                                index: index,
                                fieldKey: "quantity",
                                label: getController(index, "quantity").text.isNotEmpty ? "" : "Quantity",
                                controller: getController(index, "quantity"),
                                onChanged: (value) => setState(() {
                                  if (_challanDetailItem!.items.isEmpty) {
                                    dataRows[index]["quantity"] =
                                        value.toString();
                                    selectedItemQuantity = value;
                                  } else {
                                    _challanDetailItem!.items[index].quantity =
                                        value.toString();
                                    selectedItemQuantity = _challanDetailItem!
                                            .items[index].quantity ??
                                        "";
                                  }
                                }),
                              ),
                            )),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            userRole == "Quality Engineer" ?
                            Expanded(
                                child: SizedBox(
                                  height: 45,
                                  child: FormFieldItem(
                                    index: index,
                                    fieldKey: "price",
                                    isEnabled: false,
                                    label:  getController(index, "price").text.isNotEmpty ? "" : "Price",
                                    controller: getController(index, "price"),
                                    onChanged: (String ) { },
                                  ),
                                )) :
                            Expanded(
                                child: SizedBox(
                              height: 45,
                              child: FormFieldItem(
                                index: index,
                                fieldKey: "price",
                                label: getController(index, "price").text.isNotEmpty ? "" : "Price",
                                controller: getController(index, "price"),
                                onChanged: (value) => setState(() {
                                  if (_challanDetailItem!.items.isEmpty) {
                                    dataRows[index]["price"] = value.toString();
                                    selectedItemPrice = value;
                                  } else {
                                    _challanDetailItem!.items[index].price =
                                        value.toString();
                                    selectedItemPrice = _challanDetailItem!
                                            .items[index].price ??
                                        "";
                                  }
                                }),
                              ),
                            )),
                            const SizedBox(width: 10),
                            userRole == "Quality Engineer" ?
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
                                )) :
                            Expanded(
                              child: SizedBox(
                                height: 45,
                                child: DropdownButtonFormField<int>(
                                  decoration: InputDecoration(
                                    labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Reduced padding
                                    filled:
                                        widget.isEdit ? isEnabled! : isEnabled,
                                    // When disabled, apply a gray background
                                    fillColor: widget.isEdit
                                        ? Colors.grey.shade200
                                        : Colors.white,
                                    // Light gray background when disabled
                                    labelText: widget.isEdit &&
                                            _challanDetailItem!.items.length >
                                                index
                                        ? _challanDetailItem?.items[index].uomName
                                        : "UOM *",
                                    border: OutlineInputBorder(
                                      // Default border
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      // Unfocused border
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      // Focused border
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  // Smaller text size
                                  value: (widget.isEdit &&
                                          _challanDetailItem!.items.length >
                                              index)
                                      ? int.tryParse(_challanDetailItem!
                                          .items[index].uomName
                                          .toString())
                                      : int.tryParse(dataRows[index]["uomName"].toString()),
                                  items: uomDataItems,
                                  onChanged: !(widget.isEdit && isEnabled == true)
                                      ? (value) {
                                          setState(() {

                                            if(_challanDetailItem!.items.isEmpty){
                                              dataRows[index]["uomId"] = value.toString();
                                              selectedUomId = int.tryParse(dataRows[index]["uomId"]);
                                              dataRows[index]["uomName"] = (uomDataItems
                                                  .firstWhere(
                                                    (item) => item.value == value,
                                                orElse: () => const DropdownMenuItem(
                                                    value: 0, child: Text("Unknown")),
                                              )
                                                  .child as Text).data
                                                  .toString();
                                              selectedUomName = dataRows[index]["uomName"];
                                            } else{
                                              _challanDetailItem!.items[index].uomId = value.toString();
                                              selectedUomId =
                                                  int.tryParse( _challanDetailItem!.items[index].uomId ?? ""); // Store selected ID

                                              // Find the selected item name from the list
                                              _challanDetailItem!.items[index].uomName = (uomDataItems
                                                  .firstWhere(
                                                    (item) =>
                                                item.value ==
                                                    selectedUomId,
                                                orElse: () =>
                                                const DropdownMenuItem(
                                                    value: 0,
                                                    child: Text(
                                                        "Unknown")), // Fallback if not found
                                              )
                                                  .child as Text)
                                                  .data.toString();
                                              selectedUomName =  _challanDetailItem!.items[index].uomName ?? "";
                                            }
                                          });
                                          if (kDebugMode) {
                                            print(
                                                "Selected UOM ID: $selectedUomId, Name: $selectedUomName}");
                                          }
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        userRole == "Quality Engineer" ? const SizedBox(
                          height: 10,
                        ) : const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            userRole == "Quality Engineer" ?
                            Expanded(
                              child: SizedBox(
                                height: 45,
                                child: DropdownButtonFormField<int>(
                                  decoration: InputDecoration(
                                    labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Reduced padding
                                    filled:
                                    widget.isEdit ? isEnabled! : isEnabled,
                                    // When disabled, apply a gray background
                                    fillColor: widget.isEdit
                                        ? Colors.grey.shade200
                                        : Colors.white,
                                    // Light gray background when disabled
                                    labelText: "",
                                    border: OutlineInputBorder(
                                      // Default border
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      // Unfocused border
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      // Focused border
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  // Smaller text size
                                  value: (widget.isEdit &&
                                      _challanDetailItem!.items.length >
                                          index)
                                      ? int.tryParse(_challanDetailItem!
                                      .items[index].qualityStatus
                                      .toString())
                                      : int.tryParse(dataRows[index]["qualityStatus"].toString()),
                                  items: qualityStatusItems,
                                  onChanged: !(widget.isEdit && isEnabled == true)
                                      ? (value) {
                                    setState(() {
                                      if(_challanDetailItem!.items.isEmpty){
                                        dataRows[index]["qualityStatus"] = value.toString();
                                        selectedQualityStatusId = int.tryParse(dataRows[index]["qualityStatus"]);
                                      } else{

                                        _challanDetailItem!.items[index].qualityStatus = value.toString();
                                        selectedQualityStatusId =
                                            int.tryParse(_challanDetailItem!.items[index].qualityStatus ?? ""); // Store selected ID
                                      }
                                    });
                                    if (kDebugMode) {
                                      print(
                                          "Selected Receiver Status ID: $selectedQualityStatusId, Name: $selectedReceiverStatusName}");
                                    }
                                  }
                                      : null,
                                ),
                              ),
                            ) :
                            const SizedBox.shrink(),
                            const SizedBox(width: 10),
                            userRole == "Quality Engineer" ?
                            Expanded(
                                child: SizedBox(
                                  height: 45,
                                  child: FormFieldItem(
                                    index: index,
                                    fieldKey: "qualityRemarks",
                                    isEnabled: true,
                                    label:  _challanDetailItem!.items[index].qualityRemarks ?? "",
                                    controller: getController(index, "qualityRemarks"),
                                      onChanged: (value) => setState(() {
                                        if (_challanDetailItem!.items.isEmpty) {
                                          dataRows[index]["qualityRemarks"] =
                                              value.toString();
                                          selectedQualityStatusRemark = value;
                                        } else {
                                          _challanDetailItem!.items[index]
                                              .qualityRemarks = value.toString();
                                          selectedQualityStatusRemark = _challanDetailItem!
                                              .items[index].qualityRemarks ??
                                              "";
                                        }
                                      }),
                                  ),
                                )) :
                            const SizedBox.shrink(),
                            // Expanded(
                            //     child: SizedBox(
                            //       height: 45,
                            //       child: FormFieldItem(
                            //         index: index,
                            //         fieldKey: "qualityRemarks",
                            //         isEnabled: false,
                            //         label:  _challanDetailItem!.items[index].qualityRemarks ?? "",
                            //         controller: getController(index, "qualityRemarks"),
                            //         onChanged: (value) => setState(() {
                            //           if (_challanDetailItem!.items.isEmpty) {
                            //             dataRows[index]["qualityRemarks"] =
                            //                 value.toString();
                            //             selectedQualityStatusRemark = value;
                            //           } else {
                            //             _challanDetailItem!.items[index]
                            //                 .qualityRemarks = value.toString();
                            //             selectedQualityStatusRemark = _challanDetailItem!
                            //                 .items[index].qualityRemarks ??
                            //                 "";
                            //           }
                            //         }),
                            //       ),
                            //     )),
                          ],
                        ),
                        userRole == "Quality Engineer" ? const SizedBox(
                          height: 10,
                        ) : const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            userRole == "Quality Engineer" ?
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
                                )) :
                            Expanded(
                              child: SizedBox(
                                height: 45,
                                child: DropdownButtonFormField<int>(
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Reduced padding
                                    filled:
                                        widget.isEdit ? isEnabled! : isEnabled,
                                    // When disabled, apply a gray background
                                    fillColor: widget.isEdit
                                        ? Colors.grey.shade200
                                        : Colors.white,
                                    // Light gray background when disabled
                                    labelText: "",
                                    border: OutlineInputBorder(
                                      // Default border
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      // Unfocused border
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      // Focused border
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  // Smaller text size
                                  value: (widget.isEdit &&
                                          _challanDetailItem!.items.length >
                                              index)
                                      ? int.tryParse(_challanDetailItem!
                                          .items[index].receiverStatus
                                          .toString())
                                      : int.tryParse(dataRows[index]["receiverStatus"].toString()),
                                  items: qualityStatusItems,
                                  onChanged: !(widget.isEdit && isEnabled == true)
                                      ? (value) {
                                          setState(() {
                                            if(_challanDetailItem!.items.isEmpty){
                                              dataRows[index]["receiverStatus"] = value.toString();
                                              selectedReceiverStatusId = int.tryParse(dataRows[index]["receiverStatus"]);
                                            } else{

                                              _challanDetailItem!.items[index].receiverStatus = value.toString();
                                              selectedReceiverStatusId =
                                                  int.tryParse(_challanDetailItem!.items[index].receiverStatus ?? ""); // Store selected ID
                                            }
                                          });
                                          if (kDebugMode) {
                                            print(
                                                "Selected Receiver Status ID: $selectedReceiverStatusId, Name: $selectedReceiverStatusName}");
                                          }
                                        }
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            userRole == "Quality Engineer" ?
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
                                )) :
                            Expanded(
                                child: SizedBox(
                              height: 45,
                              child: FormFieldItem(
                                index: index,
                                fieldKey: "receiverRemarks",
                                label: widget.isEdit
                                    ? _challanDetailItem
                                            ?.items[index].receiverRemarks ??
                                        ""
                                    : "Receiver Remark",
                                controller:
                                    getController(index, "receiverRemarks"),
                                // Safe retrieval
                                onChanged: (value) => setState(() {
                                  if (_challanDetailItem!.items.isEmpty) {
                                    dataRows[index]["receiverRemarks"] =
                                        value.toString();
                                    selectedReceiverRemark = value;
                                  } else {
                                    _challanDetailItem!.items[index]
                                        .receiverRemarks = value.toString();
                                    selectedReceiverRemark = _challanDetailItem!
                                            .items[index].receiverRemarks ??
                                        "";
                                  }
                                }),
                              ),
                            )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            !widget.isEdit
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.save,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        for (int i = 0;
                                            i < dataRows[index].length;
                                            i++) {

                                          selectedItemPrice =
                                              dataRows[index]["price"];
                                          selectedItemQuantity =
                                              dataRows[index]["quantity"];
                                          selectedReceiverRemark =
                                              dataRows[index]["receiverRemarks"].toString();
                                          selectedItemName =
                                              dataRows[index]["name"].toString();
                                          selectedAssetId =
                                              int.tryParse(dataRows[index]["itemId"]);
                                          selectedUomName =
                                              dataRows[index]["uomName"];
                                          selectedUomId =
                                              int.tryParse(dataRows[index]["uomId"]);
                                          selectedReceiverStatusId =
                                              int.tryParse(dataRows[index]["receiverStatus"]);
                                          selectedReceiverStatusName = dataRows[index]["receiverStatus"];
                                        }
                                        if (kDebugMode) {
                                          print(
                                              "Header Id: ${_challanDetail?.id}");
                                          print("Item Id: $challanItemID");
                                          print(
                                              "Selected Item Id: $selectedAssetId");
                                          print(
                                              "Selected Item: $selectedItemName");
                                          print(
                                              "Selected Quantity: $selectedItemQuantity");
                                          print(
                                              "Selected Price: $selectedItemPrice");
                                          print(
                                              "Selected UOM Id: $selectedUomId");
                                          print(
                                              "Selected UOM Name: $selectedUomName");
                                          print(
                                              "Selected Receiver Status Id: $selectedReceiverStatusId");
                                          print(
                                              "Selected Receiver Status Name: $selectedReceiverStatusName");
                                          print(
                                              "Selected Receiver Remark: $selectedReceiverRemark");
                                        }
                                      });
                                      await sendItemDataToAPI(); // Call the API function
                                    },
                                  )
                                : !(_challanDetailItem!.items[index].id != null) ? IconButton(
                                    icon: const Icon(
                                      Icons.save,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                    onPressed: () async {
                                      if (_challanDetail != null &&
                                          _challanDetail!.documentDate != null) {
                                        // Convert the documentDate to DateTime for comparison
                                        DateTime documentDate = DateTime.parse(_challanDetail!.documentDate.toString());
                                        DateTime currentDate = DateTime.now();

                                        // Compare only the date part (ignoring the time)
                                        if (documentDate.year == currentDate.year &&
                                            documentDate.month == currentDate.month &&
                                            documentDate.day == currentDate.day) {
                                          // If dates are the same, proceed with addDynamicRows
                                          challanItemID =
                                          "${_challanDetailItem?.items[index].id}";
                                          for (int i = 0;
                                          i < _challanDetailItem!.items.length;
                                          i++) {
                                            // Determine whether to use the edited value or the preset one

                                            selectedItemPrice =
                                                _challanDetailItem
                                                    ?.items[index].price ??
                                                    "";
                                            selectedItemQuantity =
                                                _challanDetailItem
                                                    ?.items[index].quantity ??
                                                    "";
                                            selectedReceiverRemark =
                                                _challanDetailItem
                                                    ?.items[index].receiverRemarks ??
                                                    "";
                                            selectedItemName =
                                                _challanDetailItem
                                                    ?.items[index].name ??
                                                    "";
                                            selectedAssetId ??= int.tryParse(
                                                _challanDetailItem!
                                                    .items[index].itemId
                                                    .toString());
                                            selectedUomName =
                                                _challanDetailItem
                                                    ?.items[index].uomName ??
                                                    "";
                                            selectedUomId =
                                                int.tryParse( _challanDetailItem
                                                    ?.items[index].uomId ??
                                                    "");
                                            selectedReceiverStatusId =
                                                int.tryParse( _challanDetailItem
                                                    ?.items[index].receiverStatus ??
                                                    "");
                                          }

                                          setState(() {
                                            if (kDebugMode) {
                                              print(
                                                  "Header Id: ${_challanDetail?.id}");
                                              print("Item Id: $challanItemID");
                                              print(
                                                  "Selected Item Id: $selectedAssetId");
                                              print(
                                                  "Selected Item: $selectedItemName");
                                              print(
                                                  "Selected Quantity: $selectedItemQuantity");
                                              print(
                                                  "Selected Price: ${selectedItemPrice.toString()}");
                                              print(
                                                  "Selected UOM Id: $selectedUomId");
                                              print(
                                                  "Selected UOM Name: $selectedUomName");
                                              print(
                                                  "Selected Receiver Status Id: $selectedReceiverStatusId");
                                              print(
                                                  "Selected Receiver Status Name: $selectedReceiverStatusName");
                                              print(
                                                  "Selected Receiver Remark: $selectedReceiverRemark");
                                            }
                                          });
                                          await sendItemDataToAPI(); // Call the API function
                                        } else {
                                          // You can show a message or handle cases where the dates don't match
                                          showErrorDialog(context, "Please ensure the document date is today's date before editing this item.");
                                          print("Document date is not today's date.");
                                        }
                                      }
                                    },
                                  ) :
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 30,
                              ),
                              onPressed: () async {

                                if (_challanDetail != null &&
                                    _challanDetail!.documentDate != null) {
                                  // Convert the documentDate to DateTime for comparison
                                  DateTime documentDate = DateTime.parse(_challanDetail!.documentDate.toString());
                                  DateTime currentDate = DateTime.now();

                                  //Compare only the date part (ignoring the time)
                                  if (documentDate.year == currentDate.year &&
                                      documentDate.month == currentDate.month &&
                                      documentDate.day == currentDate.day) {
                                    // If dates are the same, proceed with addDynamicRows
                                    challanItemID =
                                    "${_challanDetailItem?.items[index].id}";
                                    for (int i = 0;
                                    i < _challanDetailItem!.items.length;
                                    i++) {
                                      // Determine whether to use the edited value or the preset one

                                      selectedItemPrice =
                                          _challanDetailItem
                                              ?.items[index].price ??
                                              "";
                                      selectedItemQuantity =
                                          _challanDetailItem
                                              ?.items[index].quantity ??
                                              "";
                                      selectedReceiverRemark =
                                          _challanDetailItem
                                              ?.items[index].receiverRemarks ??
                                              "";
                                      selectedItemName =
                                          _challanDetailItem
                                              ?.items[index].name ??
                                              "";
                                      selectedAssetId ??= int.tryParse(
                                          _challanDetailItem!
                                              .items[index].itemId
                                              .toString());
                                      selectedUomName =
                                          _challanDetailItem
                                              ?.items[index].uomName ??
                                              "";
                                      selectedUomId =
                                          int.tryParse( _challanDetailItem
                                              ?.items[index].uomId ??
                                              "");
                                      selectedReceiverStatusId =
                                          int.tryParse( _challanDetailItem
                                              ?.items[index].receiverStatus ??
                                              "");

                                      selectedQualityStatusId = int.tryParse( _challanDetailItem
                                          ?.items[index].qualityStatus ??
                                          "");

                                      // selectedQualityStatusRemark =  _challanDetailItem
                                      //     ?.items[index].qualityRemarks ??
                                      //     "";
                                    }

                                    setState(() {
                                      if (kDebugMode) {
                                        print(
                                            "Header Id: ${_challanDetail?.id}");
                                        print("Item Id: $challanItemID");
                                        print(
                                            "Selected Item Id: $selectedAssetId");
                                        print(
                                            "Selected Item: $selectedItemName");
                                        print(
                                            "Selected Quantity: $selectedItemQuantity");
                                        print(
                                            "Selected Price: ${selectedItemPrice.toString()}");
                                        print(
                                            "Selected UOM Id: $selectedUomId");
                                        print(
                                            "Selected UOM Name: $selectedUomName");
                                        print(
                                            "Selected Receiver Status Id: $selectedReceiverStatusId");
                                        print(
                                            "Selected Receiver Status Name: $selectedReceiverStatusName");
                                        print(
                                            "Selected Receiver Remark: $selectedReceiverRemark");

                                        print("Selected Quality Status Name: $selectedQualityStatusId");
                                        print("Selected Quality Status Remark: $selectedQualityStatusRemark");
                                      }
                                    });
                                    await sendItemDataForEditToAPI(); // Call the API function
                                  } else {
                                    // You can show a message or handle cases where the dates don't match
                                    showErrorDialog(context, "Please ensure the document date is today's date before editing this item.");
                                    print("Document date is not today's date.");
                                  }
                                }
                              },
                            ),
                            userRole == "Quality Engineer" ? const SizedBox.shrink() : Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  onPressed: _openCamera,
                                ),
                                const SizedBox(width: 10),
                                _capturedImage != null
                                    ? GestureDetector(
                                  onTap: _showFullScreenImage,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_capturedImage!.path),
                                      width: 35,
                                      height: 35,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ],
                        )
                      ],
                    );
                  },
                )
              ],
              const SizedBox(height: 10),
              savePressed == true ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    onPressed: () async {
                      setState(() {
                        if (kDebugMode) {
                          print("Project Id: $selectedProjectId");
                          print(
                              "Project Name: $selectedProjectName");
                          print(
                              "Quality In Charge: $selectedQualityInChargeName");
                          print(
                              "Quality In Charge Id: $selectedQuantityInChargeId");
                          print(
                              "Tracking No: ${trackingNoController.text}");
                          print(
                              "Document Date: ${documentDateController.text}");
                          print(
                              "Vehicle No: ${vehicleNoController.text}");
                          print("Supplier Id: $selectedSupplierId");
                          print(
                              "Supplier Name: $selectedSupplierName");
                        }
                      });
                      await sendFullDataToAPI(); // Call the API function
                    },
                    child: const Text("Save",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey),
                    onPressed: () {
                      Navigator.pop(context);
                      // setState(() {
                      //   print(!widget.isEdit);
                      //
                      // });
                    },
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ) : const SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Image.file(File(imagePath), fit: BoxFit.contain),
        ),
      ),
    );
  }
}