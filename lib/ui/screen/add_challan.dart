import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rajwada_app/core/model/challan_detailItem_model.dart';

import '../../core/functions/auth_function.dart';
import '../../core/functions/functions.dart';
import '../../core/model/challan_detail_model.dart';
import '../../core/model/login_data_model.dart';
import '../../core/service/shared_preference.dart';
import '../helper/app_colors.dart';
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
  //MARK: - Variable Declaration
  final AuthService authService = AuthService(); // Initialize AuthService
  final RestFunction restService = RestFunction();
  final LoginDataModel loginModel = LoginDataModel();

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
  List<DropdownMenuItem<int>> supplierDataItems = [];

  List<DropdownMenuItem<int>> assetsDataItems = [];
  List<DropdownMenuItem<int>> uomDataItems = [];
  List<DropdownMenuItem<int>> qualityStatusItems = [];

  int? selectedProjectId;
  int? selectedQuantityInChargeId; // Default selected ID
  int? selectedSupplierId;

  int? selectedAssetId;
  int? selectedUomId;
  int? selectedReceiverStatusId; // Default selected ID

  bool? showListView; // Initially hidden
  Map<int, Map<String, TextEditingController>> controllers = {};
  ChallanDetailModel? _challanDetail;
  ChallanDetailItemModel? _challanDetailItem;

  bool? isEnabled; // Allows user interaction

  String selectedProjectName = ""; // Stores the corresponding project name
  String selectedQualityInChargeName =
      ""; // Stores the corresponding QualityInCharge Name
  String selectedSupplierName = ""; // Stores the corresponding Supplier Name
  String selectedItemName = "";
  String selectedUomName = "";
  String selectedReceiverStatusName = "";
  String selectedItemPrice = "";
  String selectedItemQuantity = "";
  String selectedReceiverRemark = "";

  int? apiResponseValue; // Variable to store the integer response
  bool isLoading = false; // Loader state
  bool? savePressed;

  String challanItemID = "";

  List<Map<String, dynamic>> dataRows = [
    {
      "item": null, // Dropdown value (int or String)
      "quantity": "",
      "price": "",
      "uom": null, // Dropdown value (int or String)
      "qualityStatus": null, // Dropdown value
      "receiverRemarks": ""
    }
  ];

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
  void getUserData() async {
    List<DropdownMenuItem<int>> items =
        await RestFunction.fetchQualityUsersDropdown();
    if (mounted) {
      setState(() {
        quantityInChargeItems = items;
      });
    }
  }

  void getUserProjects() async {
    List<DropdownMenuItem<int>> items =
        await RestFunction.fetchAndStoreUserProjectData();
    if (mounted) {
      setState(() {
        userProjectItems = items;
      });
    }
  }

  void getSupplier() async {
    List<DropdownMenuItem<int>> items =
        await RestFunction.fetchAndStoreSupplierData();
    if (mounted) {
      setState(() {
        supplierDataItems = items;
      });
    }
  }

  void getAssets() async {
    List<DropdownMenuItem<int>> items =
        await RestFunction.fetchAndStoreAssetData();
    if (mounted) {
      setState(() {
        assetsDataItems = items;
      });
    }
  }

  void getUomData() async {
    List<DropdownMenuItem<int>> items =
        await RestFunction.fetchAndStoreUOMData();
    if (mounted) {
      setState(() {
        uomDataItems = items;
      });
    }
  }

  void getQualityStatus() async {
    List<DropdownMenuItem<int>> items =
        await restService.fetchAndStoreQualityStatusData();
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

  Future<void> fetchChallanDetailItem() async {
    ChallanDetailItemModel? data =
        await RestFunction.fetchChallanDetailItem(widget.challanId);
    print("Challan Detail Item Count: ${data?.items.length}");
    if (mounted) {
      setState(() {
        _challanDetailItem = data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    getUserProjects();
    getSupplier();
    getAssets();
    getUomData();
    getQualityStatus();
    fetchChallanData();
    fetchChallanDetailItem();

    if (widget.isEdit) {
      isEnabled = false;
      showListView = false;
    } else {
      isEnabled = true;
      showListView = false;
    }
  }

  TextEditingController getController(int index, String fieldKey) {
    if (!controllers.containsKey(index)) {
      controllers[index] = {};
    }
    return controllers[index]!
        .putIfAbsent(fieldKey, () => TextEditingController());
  }

  void addRow() {
    setState(() {
      int newIndex = dataRows.length; // Get new row index

      dataRows.add({
        "item": null,
        "quantity": "",
        "price": "",
        "uom": null,
        "qualityStatus": null,
        "receiverRemarks": ""
      });

      // Initialize controllers for the new row
      controllers[newIndex] = {
        "quantity": TextEditingController(),
        "price": TextEditingController(),
        "email": TextEditingController(),
        "phone": TextEditingController(),
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        filled: widget.isEdit ? isEnabled! : isEnabled,
                        // When disabled, apply a gray background
                        fillColor:
                            widget.isEdit ? Colors.grey.shade200 : Colors.white,
                        // Light gray background when disabled
                        labelText: widget.isEdit
                            ? _challanDetail?.inChargeName
                            : "Quality In Charge *",
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
                      // Smaller text size
                      value: selectedQuantityInChargeId,
                      items: quantityInChargeItems,
                      onChanged: (!widget.isEdit && isEnabled == true)
                          ? (value) {
                              setState(() {
                                selectedQuantityInChargeId = value!;
                                selectedQualityInChargeName =
                                    (quantityInChargeItems
                                                .firstWhere(
                                                    (item) =>
                                                        item.value ==
                                                        selectedQuantityInChargeId,
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
                                    "Selected QualityInCharge ID: $selectedQuantityInChargeId");
                                print(
                                    "Selected QualityInCharge Name: $selectedQualityInChargeName");
                              }
                            }
                          : null, // Disable dropdown interaction
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: CustomTextField(
                    isEnabled: widget.isEdit ? false : true,
                    label: widget.isEdit
                        ? _challanDetail?.trackingNo ?? ""
                        : "Tracking No",
                    controller: trackingNoController,
                    hintText: "Tracking No Here...",
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: CustomDateField(
                    isEnabled: widget.isEdit ? false : true,
                    label: widget.isEdit
                        ? (_challanDetail?.documentDate != null
                            ? DateFormat('yyyy-MM-dd')
                                .format(_challanDetail!.documentDate!)
                            : "")
                        : "Document Date *",
                    controller: documentDateController,
                  )),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: CustomTextField(
                    isEnabled: widget.isEdit ? false : true,
                    label: widget.isEdit
                        ? _challanDetail?.vechileNo ?? ""
                        : "Vehicle No",
                    controller: vehicleNoController,
                    hintText: "Vehicle No Here...",
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
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
                                                    const DropdownMenuItem<int>(
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
                ],
              ),
              const SizedBox(height: 20),
              !widget.isEdit
                  ? Row(
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
                                  await sendDataToAPI(); // Call the API function
                                },
                                child: const Text("Save",
                                    style: TextStyle(color: Colors.white)),
                              ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey),
                          onPressed: () {},
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  : const Row(),
              const SizedBox(height: 40),
              if (widget.isEdit || showListView == true) ...[
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
                    !widget.isEdit
                        ? IconButton(
                            icon: const Icon(
                              Icons.add_circle_rounded,
                              color: Colors.blue,
                              size: 30,
                            ),
                            onPressed: () => {addRow()},
                          )
                        : const SizedBox.shrink(),
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
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
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
                                    : selectedAssetId,
                                // ✅ Now stored in dataRows,
                                items: assetsDataItems,
                                onChanged: !(widget.isEdit && isEnabled == true)
                                    ? (value) {
                                        setState(() {
                                          selectedAssetId =
                                              value; // Store selected ID
                                        });

                                        // Find the selected item name from the list
                                        selectedItemName = (assetsDataItems
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
                                                .data ??
                                            "";

                                        if (kDebugMode) {
                                          print(
                                              "Selected Item ID: $selectedAssetId, Name: $selectedItemName}");
                                        }
                                      }
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: FormFieldItem(
                              index: index,
                              fieldKey: "quantity",
                              label: widget.isEdit
                                  ? _challanDetailItem?.items[index].quantity ??
                                      ""
                                  : "Quantity",
                              controller: getController(index, "quantity"),
                              onChanged: (value) => setState(() {
                                selectedItemQuantity = value;
                              }),
                            )),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: FormFieldItem(
                              index: index,
                              fieldKey: "price",
                              label: widget.isEdit
                                  ? _challanDetailItem?.items[index].price ?? ""
                                  : "Price",
                              controller: getController(index, "price"),
                              onChanged: (value) => setState(() {
                                selectedItemPrice = value;
                              }),
                            )),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
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
                                    : selectedUomId,
                                items: uomDataItems,
                                onChanged: !(widget.isEdit && isEnabled == true)
                                    ? (value) {
                                        setState(() {
                                          selectedUomId =
                                              value; // Store selected ID
                                        });

                                        // Find the selected item name from the list
                                        selectedUomName = (uomDataItems
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
                                                .data ??
                                            "";

                                        if (kDebugMode) {
                                          print(
                                              "Selected UOM ID: $selectedUomId, Name: $selectedUomName}");
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
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
                                      ? null
                                      : "Receiver Status *",
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
                                    : selectedReceiverStatusId,
                                items: qualityStatusItems,
                                onChanged: !(widget.isEdit && isEnabled == true)
                                    ? (value) {
                                        setState(() {
                                          selectedReceiverStatusId =
                                              value; // Store selected ID
                                        });

                                        // Find the selected item name from the list
                                        selectedReceiverStatusName =
                                            (qualityStatusItems
                                                        .firstWhere(
                                                          (item) =>
                                                              item.value ==
                                                              selectedReceiverStatusId,
                                                          orElse: () =>
                                                              const DropdownMenuItem(
                                                                  value: 0,
                                                                  child: Text(
                                                                      "Unknown")), // Fallback if not found
                                                        )
                                                        .child as Text)
                                                    .data ??
                                                "";

                                        if (kDebugMode) {
                                          print(
                                              "Selected Receiver Status ID: $selectedReceiverStatusId, Name: $selectedReceiverStatusName}");
                                        }
                                      }
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
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
                                selectedReceiverRemark = value;
                              }),
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
                                      savePressed = true;
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
                                : IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                    onPressed: () async {
                                      savePressed = false;
                                      challanItemID =
                                          "${_challanDetailItem?.items[index].id}";
                                      for (int i = 0;
                                          i < _challanDetailItem!.items.length;
                                          i++) {
                                        // Determine whether to use the edited value or the preset one
                                        selectedItemPrice =
                                            selectedItemPrice.isEmpty
                                                ? (_challanDetailItem
                                                        ?.items[index].price ??
                                                    "")
                                                : selectedItemPrice;
                                        selectedItemQuantity =
                                            selectedItemQuantity.isEmpty
                                                ? (_challanDetailItem
                                                        ?.items[index]
                                                        .quantity ??
                                                    "")
                                                : selectedItemQuantity;
                                        selectedReceiverRemark =
                                            selectedReceiverRemark.isEmpty
                                                ? (_challanDetailItem
                                                        ?.items[index]
                                                        .receiverRemarks ??
                                                    "")
                                                : selectedReceiverRemark;
                                        selectedAssetId ??= int.tryParse(
                                            _challanDetailItem!
                                                .items[index].itemId
                                                .toString());
                                        selectedItemName =
                                            selectedItemName.isEmpty
                                                ? (_challanDetailItem
                                                        ?.items[index].name ??
                                                    "")
                                                : selectedItemName;
                                        selectedUomId ??= int.tryParse(
                                            _challanDetailItem!
                                                .items[index].uomId
                                                .toString());
                                        selectedUomName =
                                            selectedUomName.isEmpty
                                                ? (_challanDetailItem
                                                        ?.items[index]
                                                        .uomName ??
                                                    "")
                                                : selectedUomName;
                                        selectedReceiverStatusId ??=
                                            int.tryParse(_challanDetailItem!
                                                .items[index].receiverStatus
                                                .toString());
                                      }

                                      setState(() {
                                        if (kDebugMode) {
                                          print(
                                              "${_challanDetailItem?.items[index].price}");
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
                                      await sendItemDataForEditToAPI(); // Call the API function
                                    },
                                  ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 30,
                              ),
                              onPressed: () => removeRow(index),
                            ),
                          ],
                        )
                      ],
                    );
                  },
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
