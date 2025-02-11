
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rajwada_app/core/functions/auth_function.dart';
import 'package:rajwada_app/core/model/login_data_model.dart';
import 'package:rajwada_app/ui/helper/app_colors.dart';
import 'package:rajwada_app/ui/helper/assets_path.dart';
import '../../core/functions/functions.dart';
import '../widget/custom_date_field.dart';
import '../widget/custom_text_field.dart';
import '../widget/form_field_widget.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Home", "icon": Icons.home},
    {"title": "Profile", "icon": Icons.person},
    {"title": "Settings", "icon": Icons.settings},
    {"title": "Activity Reporting", "icon": Icons.pie_chart},
    {"title": "Logout", "icon": Icons.logout},
  ];

  final AuthService authService = AuthService(); // Initialize AuthService
  final RestFunction restService = RestFunction();

  final LoginDataModel loginModel = LoginDataModel();

  final TextEditingController trackingNoController = TextEditingController();
  final TextEditingController vehicleNoController = TextEditingController();
  final TextEditingController documentDateController = TextEditingController();
  final TextEditingController quantityDataController = TextEditingController();
  final TextEditingController priceDataController = TextEditingController();
  final TextEditingController receiverRemarkDataController = TextEditingController();


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

  int selectedAssetId = -1;
  int selectedUomId = -1;
  int selectedQualityStatusId = -1; // Default selected ID

  bool showListView = false; // Initially hidden
  Map<int, Map<String, TextEditingController>> controllers = {};

  List<Map<String, dynamic>> dataRows = [
    {
      "item": null,  // Dropdown value (int or String)
      "quantity": "",
      "price": "",
      "uom": null,  // Dropdown value (int or String)
      "qualityStatus": null,  // Dropdown value
      "receiverRemarks": ""
    }
  ];

 //Fetch Pre Data Sets
  void getUserData() async {
    List<DropdownMenuItem<int>> items = await RestFunction.fetchQualityUsersDropdown();
    setState(() {
      quantityInChargeItems = items;
    });
  }

  void getUserProjects() async {
    List<DropdownMenuItem<int>> items = await RestFunction.fetchAndStoreUserProjectData();
      setState(() {
        userProjectItems = items;
      });
  }

  void getSupplier() async {
    List<DropdownMenuItem<int>> items = await RestFunction.fetchAndStoreSupplierData();
      setState(() {
        supplierDataItems = items;
      });
  }

  void getAssets() async {
    List<DropdownMenuItem<int>> items = await RestFunction.fetchAndStoreAssetData();
      setState(() {
        assetsDataItems = items;
      });
  }

  void getUomData() async {
    List<DropdownMenuItem<int>> items = await RestFunction.fetchAndStoreUOMData();
      setState(() {
        uomDataItems = items;
      });
  }

  void getQualityStatus() async {
    List<DropdownMenuItem<int>> items = await restService.fetchAndStoreQualityStatusData();
    setState(() {
      qualityStatusItems = items;
    });
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

  }

  TextEditingController getController(int index, String fieldKey) {
    if (!controllers.containsKey(index)) {
      controllers[index] = {};
    }
    return controllers[index]!.putIfAbsent(fieldKey, () => TextEditingController());
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
        title: Container(
          width: 120,
          height: 45,
          decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage(AssetsPath.drawerLogo),
              fit: BoxFit.fill,
            ),
          ),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          color: AppColor.colorPrimary, // Background color
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.white, // Change image color to white
                        BlendMode
                            .srcATop, // Blend mode to apply color over image
                      ),
                      child: Container(
                        width: 220,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: const DecorationImage(
                            image: AssetImage(AssetsPath.currentAppLogo),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(
                          menuItems[index]['icon'], color: Colors.white),
                      title: Text(
                        menuItems[index]['title'],
                        style: const TextStyle(color: Colors.white,
                            fontSize: 16),
                      ),
                      onTap: () {
                        // Handle navigation
                        Navigator.pop(context);
                        if (menuItems[index]["title"] == "Logout") {
                          authService.logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                'Navigating to ${menuItems[index]["title"]}')),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: "Project *",
                        border: OutlineInputBorder( // Default border
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder( // Unfocused border
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder( // Focused border
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      style: TextStyle(fontSize: 14, color: Colors.black), // Smaller text size
                      value: selectedProjectId,
                      items: userProjectItems,
                      onChanged: (value) {
                        setState(() {
                          selectedProjectId = value!;
                        });
                        if (kDebugMode) {
                          print("Selected Project Status ID: $selectedProjectId");
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: "Quality In Charge *",
                        border: OutlineInputBorder( // Default border
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder( // Unfocused border
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder( // Focused border
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      style: TextStyle(fontSize: 14, color: Colors.black), // Smaller text size
                      value: selectedQuantityInChargeId,
                      items: quantityInChargeItems,
                      onChanged: (value) {
                        setState(() {
                          selectedQuantityInChargeId = value!;
                        });
                        if (kDebugMode) {
                          print("Selected Quality Status ID: $selectedQuantityInChargeId");
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CustomTextField(
                    label: "Tracking No",
                    controller: trackingNoController,
                    hintText: "Tracking No Here...",
                  )),
                  SizedBox(width: 10),
                  Expanded(child:  CustomDateField(
                    label: "Document Date *",
                    controller: documentDateController,
                  )),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: CustomTextField(
                    label: "Vehicle No",
                    controller: vehicleNoController,
                    hintText: "Vehicle No Here...",
                  )),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                          labelText: "Supplier Name *",
                        border: OutlineInputBorder( // Default border
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder( // Unfocused border
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder( // Focused border
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                      value: selectedSupplierId,
                      items: supplierDataItems,
                      onChanged: (value) {
                        setState(() {
                          selectedSupplierId = value!;
                        });
                        if (kDebugMode) {
                          print("Selected Quality In Charge Status ID: $selectedSupplierId");
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      setState(() {
                        showListView = true; // Show ListView when Save is clicked
                      });
                    },
                    child: Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    onPressed: () {},
                    child: Text("Cancel", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              SizedBox(height: 40),
              if (showListView) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Item List",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(width: 20,),
                    IconButton(
                      icon: Icon(Icons.add_circle_rounded, color: Colors.blue,size: 30,),
                      onPressed: () => {
                          addRow()
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true, // Helps avoid infinite height issues
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: dataRows.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: "Item *",
                                  border: OutlineInputBorder( // Default border
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                  enabledBorder: OutlineInputBorder( // Unfocused border
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder( // Focused border
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                ),
                                style: TextStyle(fontSize: 14, color: Colors.black), // Smaller text size
                                value: dataRows[index]["item"], // ✅ Now stored in dataRows,
                                items: assetsDataItems,
                                onChanged: (value) {
                                  setState(() {
                                    dataRows[index]["item"] = value;
                                  });
                                  if (kDebugMode) {
                                    print("Selected Project Item ID: ${dataRows[index]["item"]}");
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(child: FormFieldItem(
                              index: index,
                              fieldKey: "quantity",
                              label: "Quantity",
                              controller: getController(index, "quantity"),
                              onChanged: (value) => setState(() {
                                dataRows[index]["quantity"] = value;
                              }),
                            )),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(child: FormFieldItem(
                              index: index,
                              fieldKey: "price",
                              label: "Price",
                              controller: getController(index, "price"),
                              onChanged: (value) => setState(() {
                                dataRows[index]["price"] = value;
                              }),
                            )),
                            SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: "UOM *",
                                  border: OutlineInputBorder( // Default border
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                  enabledBorder: OutlineInputBorder( // Unfocused border
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder( // Focused border
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                ),
                                style: TextStyle(fontSize: 14, color: Colors.black), // Smaller text size
                                value: dataRows[index]["uom"],
                                items: uomDataItems,
                                onChanged: (value) {
                                  setState(() {
                                    dataRows[index]["uom"] = value;
                                  });
                                  if (kDebugMode) {
                                    print("Selected Project UOM ID: ${dataRows[index]["uom"]}");
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: "Receiver Status *",
                                  border: OutlineInputBorder( // Default border
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                  enabledBorder: OutlineInputBorder( // Unfocused border
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder( // Focused border
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                  ),
                                ),
                                style: TextStyle(fontSize: 14, color: Colors.black), // Smaller text size
                                value: dataRows[index]["qualityStatus"],
                                items: qualityStatusItems,
                                onChanged: (value) {
                                  setState(() {
                                    dataRows[index]["qualityStatus"] = value!;
                                  });
                                  if (kDebugMode) {
                                    print("Selected Receiver Status ID: ${dataRows[index]["qualityStatus"]}");
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(child: FormFieldItem(
                              index: index,
                              fieldKey: "",
                              label: "Receiver Remark",
                              controller: getController(index, "receiverRemarks"), // Safe retrieval
                              onChanged: (value) => setState(() {
                                dataRows[index]["receiverRemarks"] = value;
                              }),
                            )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.save, color: Colors.blue,size: 30,),
                              onPressed: () => {

                                print(dataRows[index]["price"]),
                                print(dataRows[index]["quantity"])
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red,size: 30,),
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
