import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/functions/functions.dart';
import '../../core/model/activity_detail_model.dart';
import '../../core/model/activity_tracking_response.dart';
import '../../core/service/shared_preference.dart';
import '../helper/app_colors.dart';
import 'add_challan.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


class PostActivityReportPage extends StatefulWidget {
  final int subDetailItemId;
  final DateTime selectedDate;

  const PostActivityReportPage({super.key, required this.subDetailItemId,required this.selectedDate,});

  @override
  State<PostActivityReportPage> createState() => _PostActivityReportPageState();
}



class _PostActivityReportPageState extends State<PostActivityReportPage> {
  late TextEditingController costController;
  late TextEditingController manpowerController;

  double progress = 0.0;
  double minProgress = 0; // minimum allowed value for the slider
  String? selectedStatus;
  Uint8List? bytes;
  ActivityDetailModel? activityDetails;
  bool isLoading = true;
  String? errorMessage;
  File? _capturedCuringImage;
  File? _capturedBlueprintImage;

  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _icons = [];
  String? date;
  bool? onHoldStatus;
  bool? onCancelledStatus;
  bool? onCuringStatus;
  bool? onAbandonedStatus;
  bool isUploading = false;
  double? costData;
  String? manpowerData;
  double? progressData;
  String? taskStateData;
  String? activityId;
  bool? curingImage = false;
  bool? blueprintImage = false;

  List<DropdownMenuItem<int>> assetsDataItems = [];
  List<DropdownMenuItem<int>> uomDataItems = [];
  int? selectedAssetId;
  int? selectedUomId;
  int? editingIndex;

  TextEditingController quantityController = TextEditingController();

  List<Map<String, dynamic>> itemList = [];

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }


  @override
  void initState() {
    super.initState();
    costController = TextEditingController();
    manpowerController = TextEditingController(text: "0");
    fetchSubActivityDetails();
    fetchActivityTracking();
    getAssets();
    getUomData();
  }


  // API calls
  Future<void> getUomData() async {
    List<DropdownMenuItem<int>> items =
    await RestFunction.fetchAndStoreUOMData();
    if (mounted) {
      setState(() {
        uomDataItems = items;
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

  /// MARK:- Show Image in Full Screen
  void _showFullScreenImage(ActivityDetailModel activityDetails, String imageType) {
    File? imageFile;

    if (imageType == 'curing') {
      imageFile = _capturedCuringImage;
    } else if (imageType == 'blueprint') {
      imageFile = _capturedBlueprintImage;
    }

    if (imageFile == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(
          imagePath: imageFile!.path,
          activityDetails: activityDetails,
          onRetake: () {
            Navigator.pop(context);
            _openCameraAndShowDialog(activityDetails, imageType);
          },
          onUpload: () async {
            await uploadImageData(
              context: context,
              taskId: activityDetails.id.toString(),
              taskName: activityDetails.name.toString(),
              taskStatus: activityDetails.status.toString(),
              taskMember: activityDetails.member.toString(),
              taskKey: activityDetails.key.toString(),
            );
          },
        ),
      ),
    );
  }

  void fetchActivityTracking() async {
    try {
      final data = await RestFunction.fetchActivityTracking(widget.subDetailItemId);
      if (kDebugMode) {
        print(data);
      }
      if (data?.items.isNotEmpty ?? false) {
        final latestItem = data!.items.first;
        print(latestItem);
        // proceed...
        print(latestItem);
        setState(() {
          isLoading = false;

          // Populate manpower if available
          manpowerController.text = latestItem.manPower.toString();

          if (latestItem.isOnHold) {
            taskStateData = 'On Hold';
            onHoldStatus = true;
          } else if (latestItem.isCancelled) {
            taskStateData = 'Cancelled';
            onCancelledStatus = true;
          } else if (latestItem.isCuringDone) {
            taskStateData = 'Curing';
            onCuringStatus = true;
          } else {
            taskStateData = 'Abandoned';
            onAbandonedStatus = true;
          }

          print(taskStateData);
          selectedStatus = taskStateData;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void fetchSubActivityDetails() async {
    try {
      final data = await RestFunction.fetchSubActivity(widget.subDetailItemId);
      setState(() {
        activityDetails = data;
        isLoading = false;

        // Format and assign date
        date = DateFormat('dd-MM-yyyy').format(widget.selectedDate);

        // Populate cost if available
        costController.text = activityDetails?.actualCost?.toString() ?? "";

        progress = activityDetails!.progressPercentage!.toDouble();
        minProgress = progress; // Set the baseline (minimum allowed) from the API
        final photoUrl = activityDetails?.photoUrl;
        if (photoUrl != null && photoUrl.contains(',')) {
          try {
            final cleanBase64 = photoUrl.split(',').last;
            bytes = base64Decode(cleanBase64);
          } catch (e) {
            print('Base64 decode error: $e');
          }
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }


  ///MARK: - Camera operation
  void _openCameraAndShowDialog(ActivityDetailModel activityDetails, String imageType) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      if (imageType == 'curing') {
        _capturedCuringImage = File(image.path);
      } else if (imageType == 'blueprint') {
        _capturedBlueprintImage = File(image.path);
      }
    });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Captured Image"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(image.path), // Convert XFile to File
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                if (isUploading)
                  const CircularProgressIndicator()
                else
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      // await uploadImageData(
                      //   context: context,
                      //   taskId: activityDetails.id.toString(),
                      //   taskName: activityDetails.name.toString(),
                      //   taskStatus: activityDetails.status.toString(),
                      //   taskMember: activityDetails.member.toString(),
                      //   taskKey: activityDetails.key.toString(),
                      // );
                    },
                    child: const Text("OK"),
                  ),
              ],
            ),
          );
        },
      );
  }

  Future<void> uploadImageData({
    required BuildContext context,
    required String taskId,
    required String taskName,
    required String taskStatus,
    required String taskMember,
    required String taskKey,
  }) async {
    setState(() {
      isLoading = true;
    });

    String? token = await SharedPreference.getToken();
    if (token == null) return;

    String apiUrl = "https://65.0.190.66/api/attachment";

    final List<Map<String, dynamic>> uploadTasks = [];

    if (_capturedCuringImage != null) {
      uploadTasks.add({
        "image": _capturedCuringImage,
        "module": "curing",
      });
    }

    if (_capturedBlueprintImage != null) {
      uploadTasks.add({
        "image": _capturedBlueprintImage,
        "module": "activity",
      });
    }

    if (uploadTasks.isEmpty) {
      if (kDebugMode) print("No image captured to upload.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      for (final task in uploadTasks) {
        final File image = task["image"];
        final String module = task["module"];

        final bytes = await image.readAsBytes();
        final base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";

        // 👇 Updated to match required format
        final Map<String, dynamic> requestBody = {
            "parentId": taskId,
            "module": module,
            "file": base64Image,
        };

        if (kDebugMode) {
          print("Uploading image for module: $module");
          print("Request Body: $requestBody");
        }

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          print(response);
          if (kDebugMode) print("Image uploaded successfully for $module.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Images uploaded successfully.",
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        } else {
          if (kDebugMode) {
            print("Failed to upload $module image: ${response.statusCode}");
            print("Response: ${response.body}");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("Image upload error: $e");
    } finally {
      setState(() {
        isLoading = false;
        isUploading = false;
      });
    }
  }

  ///MARK:- Show Balloon Icon Dialog
  void _showBalloonIconDialog(Map<String, dynamic> iconData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Balloon Icon'),
          content: const Text('Do you want to update or remove this text balloon?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() { // ✅ Updates AlertDialog UI
                  _icons.remove(iconData);
                });
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddTextDialog(iconData); // ✅ Pass setStateDialog
              },
              child: const Text('Update Text'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  ///MARK:- Show Camera Icon Dialog
  void _showCameraIconDialog(Map<String, dynamic> iconData, ActivityDetailModel activityDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Icon'),
          content: const Text('Do you want to update or remove this camera icon?'),
          actions: [
            TextButton(
              onPressed: () {
                _showFullScreenImage(activityDetails, 'blueprint');
              },
              child: const Text('View'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _icons.remove(iconData);
                });
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                blueprintImage = true;
                _openCameraAndShowDialog(activityDetails, 'blueprint'); // ✅ Use setStateDialog for updates
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
            // TextButton(
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            //   child: const Text('Cancel'),
            // ),
          ],
        );
      },
    );
  }

  ///MARK:- Handle Taps on Existing Icons
  void _handleIconTap(Map<String, dynamic> iconData, ActivityDetailModel activityDetails) {
    switch (iconData['type']) {
      case 'camera':
        _showCameraIconDialog(iconData, activityDetails);
        break;
      case 'balloon':
        _showBalloonIconDialog(iconData);
        break;
    }
  }

  ///MARK:- Show Icon Dialog
  void _showIconOptionsDialog(Offset position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Icon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera Icon'),
                onTap: () {
                  setState(() {
                    _icons.add({'position': position, 'type': 'camera', 'text': ''});
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bubble_chart),
                title: const Text('Balloon Icon'),
                onTap: () {
                  setState(() {
                    _icons.add({'position': position, 'type': 'balloon', 'text': ''});
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  ///MARK:- Show Add Text Dialog
  void _showAddTextDialog(Map<String, dynamic> iconData) {
    TextEditingController textController = TextEditingController(text: iconData['text']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Text'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Enter your text'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() { // ✅ Updates AlertDialog UI
                  iconData['text'] = textController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          width: 160,
          child: Text("Post Activity Details",
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: $date", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Task: ${activityDetails?.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: costController,
              decoration: const InputDecoration(
                  labelText: "Cost", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: manpowerController,
              decoration: const InputDecoration(
                  labelText: "Man Power", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            const Text("Task Status:", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: ["On Hold", "Cancelled", "Abandoned", "Curing"]
                  .map((status) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio(
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                     // Update UI inside dialog
                      setState(() {
                        selectedStatus = value.toString();
                        if (selectedStatus == "Curing") {
                          onCuringStatus = true;
                          onAbandonedStatus = false;
                          onHoldStatus = false;
                          onCancelledStatus = false;
                          curingImage = true;
                          _openCameraAndShowDialog(activityDetails! , 'curing'); // Open Camera
                        }
                        else if (selectedStatus == "On Hold"){
                          onHoldStatus = true;
                          onAbandonedStatus = false;
                          onCancelledStatus = false;
                          onCuringStatus = false;
                          curingImage = false;
                        } else if (selectedStatus == "Cancelled"){
                          onCancelledStatus = true;
                          onAbandonedStatus = false;
                          onHoldStatus = false;
                          onCuringStatus = false;
                          curingImage = false;
                        } else if (selectedStatus == "Abandoned"){
                          onAbandonedStatus = true;
                          onCancelledStatus = false;
                          onCuringStatus = false;
                          onHoldStatus = false;
                          curingImage = false;
                        }
                      });
                    },
                  ),
                  Text(status),
                  if (status == "Curing" && selectedStatus == "Curing" && _capturedCuringImage != null &&  curingImage == true)
                    GestureDetector(
                      onTap: () => _showFullScreenImage(activityDetails!, 'curing'),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_capturedCuringImage!.path),
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                ],
              ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            const Text("Progress", style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: progress,
              onChanged: (value) {
                if (value >= minProgress) {
                  setState(() {
                    progress = value;
                  });
                }
              },
              min: 0,
              max: 100,
              divisions: 10,
              label: "${progress.toInt()}%",
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(value: false, onChanged: (val) {}),
                const Text("Assign to QC"),
              ],
            ),
            const SizedBox(height: 10),
            // ---------------- Item List Section ----------------
            const SizedBox(height: 20),
            const Text("Item List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Item"),
              value: selectedAssetId,
              items: assetsDataItems,
              onChanged: (value) {
                setState(() {
                  selectedAssetId = value;
                });
              },
            ),

            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: "Quantity"),
              keyboardType: TextInputType.number,
            ),

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "UOM"),
              value: selectedUomId,
              items: uomDataItems,
              onChanged: (value) {
                setState(() {
                  selectedUomId = value;
                });
              },
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white, // White text
              ),
              onPressed: () {
                if (selectedAssetId != null &&
                    selectedUomId != null &&
                    quantityController.text.isNotEmpty) {
                  setState(() {
                    if (editingIndex != null) {
                      // Update existing item
                      itemList[editingIndex!] = {
                        "itemId": selectedAssetId,
                        "itemName": assetsDataItems
                            .firstWhere((e) => e.value == selectedAssetId)
                            .child
                            .toString()
                            .replaceAll("Text(", "")
                            .replaceAll(")", "")
                            .replaceAll('"', ''),
                        "quantity": quantityController.text,
                        "uomId": selectedUomId,
                        "uomName": uomDataItems
                            .firstWhere((e) => e.value == selectedUomId)
                            .child
                            .toString()
                            .replaceAll("Text(", "")
                            .replaceAll(")", "")
                            .replaceAll('"', ''),
                      };
                      editingIndex = null;
                    } else {
                      // Add new item
                      itemList.add({
                        "itemId": selectedAssetId,
                        "itemName": assetsDataItems
                            .firstWhere((e) => e.value == selectedAssetId)
                            .child
                            .toString()
                            .replaceAll("Text(", "")
                            .replaceAll(")", "")
                            .replaceAll('"', ''),
                        "quantity": quantityController.text,
                        "uomId": selectedUomId,
                        "uomName": uomDataItems
                            .firstWhere((e) => e.value == selectedUomId)
                            .child
                            .toString()
                            .replaceAll("Text(", "")
                            .replaceAll(")", "")
                            .replaceAll('"', ''),
                      });
                    }
                    quantityController.clear();
                    selectedAssetId = null;
                    selectedUomId = null;
                  });
                }
              },
              child: Text(editingIndex != null ? "Update Item" : "Add Item"),
            ),

            const SizedBox(height: 10),

            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(3),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.3)),
                  children: const [
                    Padding(padding: EdgeInsets.all(8), child: Text("Item")),
                    Padding(padding: EdgeInsets.all(8), child: Text("Quantity")),
                    Padding(padding: EdgeInsets.all(8), child: Text("UOM")),
                    Padding(padding: EdgeInsets.all(8), child: Text("Actions")),
                  ],
                ),
                ...itemList.map((item) {
                  return TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8), child: Text(item["itemName"])),
                      Padding(padding: const EdgeInsets.all(8), child: Text(item["quantity"])),
                      Padding(padding: const EdgeInsets.all(8), child: Text(item["uomName"])),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            // Edit Icon Button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedAssetId = item["itemId"];
                                  selectedUomId = item["uomId"];
                                  quantityController.text = item["quantity"];
                                  editingIndex = itemList.indexOf(item);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Delete Icon Button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  itemList.remove(item);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white, // White text
              ),
              onPressed: () {
                List<Map<String, String>> finalData = itemList.map((e) {
                  return {
                    "itemId": e["itemId"].toString(),
                    "quantity": e["quantity"].toString(),
                    "uomId": e["uomId"].toString(),
                  };
                }).toList();
                print(jsonEncode(finalData)); // Final array
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Item list updated Successfully",
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text("Save Item List"),
            ),
// ----------------------------------------------------
            const SizedBox(height: 20),
            const Text("Activity Blueprint", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTapDown: (TapDownDetails details) {
                  // Handle tap
                  _showIconOptionsDialog(details.localPosition); // ✅ Pass setStateDialog
                },
                  child: SizedBox(
                    height: 265,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // 📄 PDF or 🖼️ Image viewer
                        if (bytes != null)
                          Builder(
                            builder: (context) {
                              if (activityDetails?.photoUrl?.startsWith("data:application/pdf") ?? false) {
                                return SfPdfViewer.memory(
                                  bytes!,
                                  canShowScrollHead: false,
                                  canShowScrollStatus: false,
                                );
                              } else {
                                return Image.memory(
                                  bytes!,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                );
                              }
                            },
                          )
                        else
                          const Center(child: Text("No blueprint available")),

                        // 👆 Transparent tap layer (catches taps instantly)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTapDown: (details) {
                              _showIconOptionsDialog(details.localPosition); // 👈 your popup
                            },
                            child: Container(color: Colors.transparent),
                          ),
                        ),

                        // 📍 Overlay icons
                        ..._icons.map((iconData) {
                          Offset position = iconData['position'];
                          String type = iconData['type'];
                          String text = iconData['text'];

                          return Positioned(
                            left: position.dx - 25,
                            top: position.dy - 25,
                            child: GestureDetector(
                              onTap: () => _handleIconTap(iconData, activityDetails!),
                              child: Column(
                                children: [
                                  Image.asset(
                                    type == 'camera'
                                        ? 'assets/images/c1.png'
                                        : 'assets/images/pin.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                  if (text.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      color: Colors.white,
                                      child: Text(
                                        text,
                                        style: const TextStyle(fontSize: 12, color: Colors.black),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                          onPressed: isToday(widget.selectedDate)
                              ? () async {
                                  costData = double.parse(costController.text);
                                  manpowerData = manpowerController.text;
                                  taskStateData = selectedStatus;
                                  progressData =
                                      double.parse(progress.toInt().toString());
                                  activityId = "${activityDetails?.id}";

                                  String? taskId =
                                      activityDetails?.id.toString();
                                  String? taskName =
                                      activityDetails?.name.toString();
                                  String? taskStatus =
                                      activityDetails?.status.toString();
                                  String? taskMember =
                                      activityDetails?.member.toString();
                                  String? taskKey =
                                      activityDetails?.key.toString();
                                  // Prepare final item list from your table data
                                  List<Map<String, String>> finalItemList = itemList.map((e) {
                                    return {
                                      "itemId": e["itemId"].toString(),
                                      "quantity": e["quantity"].toString(),
                                      "uomId": e["uomId"].toString(),
                                    };
                                  }).toList();

                                  if (kDebugMode) {
                                    print(costData);
                                    print(manpowerData);
                                    print(taskStateData);
                                    print(progressData);
                                    print(activityId);
                                    print(taskId);
                                    print(taskName);
                                    print(taskStatus);
                                    print(taskMember);
                                    print(taskKey);
                                  }

                                  // await uploadImageData(
                                  //   context: context,
                                  //   taskId: taskId.toString(),
                                  //   taskName: taskName.toString(),
                                  //   taskStatus: taskStatus.toString(),
                                  //   taskMember: taskMember.toString(),
                                  //   taskKey: taskKey.toString(),
                                  // );
                                  await sendPatchData(taskId, taskName, taskStatus, taskMember, taskKey, finalItemList); // 👈 pass here
                                }
                              : null, // 👈 Disabled if not today
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            disabledBackgroundColor:
                                Colors.grey, // Optional for disabled look
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendFullDataToAPI(
      taskId,
      taskName,
      taskStatus,
      taskMember,
      taskKey,
      List<Map<String, String>> itemListData,
      ) async {
    setState(() {
      isLoading = true;
    });

    String? token = await SharedPreference.getToken();
    if (token == null) return;

    String apiUrl = "https://65.0.190.66/api/activitytracking";

    // Build request body exactly like required payload
    Map<String, dynamic> requestBody = {
      "activityId": activityId,
      "manPower": manpowerData,
      "item": jsonEncode(itemListData), // must be JSON string
      "cost": costData,
      "isOnHold": onHoldStatus,
      "isCancelled": onCancelledStatus,
      "isCuringDone": onCuringStatus,
      "name": taskName,
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

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Activity Added Successfully",
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            duration: Duration(seconds: 2),
          ),
        );

        // Decide based on image availability
        if (_capturedCuringImage == null && _capturedBlueprintImage == null) {
          // No image → pop directly
          Navigator.pop(context);
        } else {
          // Image available → follow normal upload flow
          await uploadImageData(
            context: context,
            taskId: taskId,
            taskName: taskName,
            taskStatus: taskStatus,
            taskMember: taskMember,
            taskKey: taskKey,
          );
        }
      } else {
        if (kDebugMode) {
          print("Failed to send data: ${response.statusCode}");
          print("Response body: ${response.body}");
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  Future<void> sendPatchData(taskId, taskName, taskStatus, taskMember, taskKey, List<Map<String, String>> itemListData) async {
    setState(() {
      isLoading = true; // Show loader before API call
    });
    String? token = await SharedPreference.getToken();
    if (token == null) return; // Return null if token is missing
    String apiUrl = "";

    apiUrl = "https://65.0.190.66/api/activity/$activityId";

    // Request body
    Map<String, dynamic> requestBody = {
      "description": activityDetails?.description,
      "type": activityDetails?.type,
      "isSubSubType": activityDetails?.isSubSubType,
      "photoUrl" : activityDetails?.photoUrl,
      "actualCost": costData,
      "progressPercentage": progressData?.toInt(),
      "isCuringDone": onCuringStatus,
      "isCancelled": onCancelledStatus,
      "isOnHold": onHoldStatus,
      "isAbandoned": onAbandonedStatus,
      "documentLinks": activityDetails?.documentLinks,
      "notes": activityDetails?.notes,
      "userId": activityDetails?.userId,
      "curingDate": activityDetails?.curingDate?.toIso8601String(),
      "isCompleted": activityDetails?.isCompleted,
      "isQCApproved": activityDetails?.isQcApproved,
      "qcApprovedDate": activityDetails?.qcApprovedDate?.toIso8601String(),
      "qcApprovedBy": activityDetails?.qcApprovedBy,
      "qcRemarks": activityDetails?.qcRemarks,
      "isApproved": activityDetails?.isApproved,
      "approvedDate": activityDetails?.approvedDate?.toIso8601String(),
      "approvedBy": activityDetails?.approvedBy,
      "hodRemarks": activityDetails?.hodRemarks,
      "actualItems": activityDetails?.actualItems,
      "priorityStatus": activityDetails?.priorityStatus,
      "workflowState": activityDetails?.workflowState,
      "approvalStatus": activityDetails?.approvalStatus,
      "costEstimate": activityDetails?.costEstimate,
      "startDate": activityDetails?.startDate?.toIso8601String(),
      "endDate": activityDetails?.endDate?.toIso8601String(),
      "duration": activityDetails?.duration,
      "items": activityDetails?.items ?? "[]", // ✅ sends as string
      "actualStartDate": activityDetails?.actualStartDate,
      "actualEndDate": activityDetails?.actualEndDate?.toIso8601String(),
      "projectId": activityDetails?.projectId,
      "project": activityDetails?.project,
      "parentId": activityDetails?.parentId,
      "parent": activityDetails?.parent,
      "parentName": activityDetails?.parentName,
      "dependencyId": activityDetails?.dependencyId,
      "dependency": activityDetails?.dependency,
      "towerId": activityDetails?.towerId,
      "tower": activityDetails?.tower,
      "floorId": activityDetails?.floorId,
      "floor": activityDetails?.floor,
      "flatId": activityDetails?.flatId,
      "flat": activityDetails?.flat,
      "contractorId": activityDetails?.contractorId,
      "contractor": activityDetails?.contractor,
      "id": activityDetails?.id,
      "name": activityDetails?.name,
      "status": activityDetails?.status,
      "date": DateTime.now().toIso8601String(),
      "member": activityDetails?.member,
      "key": activityDetails?.key,
    };


    if (kDebugMode) {
      print("Api url: $apiUrl");
      print("Request Body for patch: $requestBody");
      print("Token for path: $token");
      print("Encoded JSON: ${jsonEncode(requestBody)}");
      print("costData: $costData (${costData.runtimeType})");
      print("progressData: $progressData (${progressData.runtimeType})");
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
        print(response);
        print(response.body);
        if (!mounted) return;
        setState(() {
          isLoading = false; // Hide loader after API response
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Activity Patched Successfully",
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.normal),
                ),
                duration: Duration(seconds: 2),
              )
          );
        });
        await sendFullDataToAPI(taskId, taskName, taskStatus, taskMember, taskKey, itemListData); // Async call happens *after* setState
        // if (kDebugMode) {
        //   print("API Response Value: $response");
        // }
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false; // Hide loader after API response
        });
        if (kDebugMode) {
          print("Failed to send data: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false; // Hide loader after API response
      });
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }
}