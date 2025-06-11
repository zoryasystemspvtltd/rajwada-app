import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' as typed;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rajwada_app/core/model/event_data_model.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/functions/functions.dart';
import '../../core/service/shared_preference.dart';
import '../helper/app_colors.dart';
import 'activity_details.dart';
import 'add_challan.dart';


class ActivityReport extends StatefulWidget {
  const ActivityReport({super.key});

  @override
  _ActivityReportScreenState createState() => _ActivityReportScreenState();

}


class _ActivityReportScreenState extends State<ActivityReport> {

  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  List<EventModel>? eventItems;
  bool isLoading = false; // Loader state
  Map<DateTime, List<Map<String, dynamic>>> eventMap = {};
  typed.Uint8List? bytes;
  XFile? _capturedImage;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _icons = [];
  String? costData;
  String? manpowerData;
  String? progressData;
  String? taskStateData;
  String? activityId;
  bool? onHoldStatus;
  bool? onCancelledStatus;
  bool? onCuringStatus;
  bool? onAbandonedStatus;
  bool isUploading = false;
  late DateTime _lastDayOfCurrentMonth = DateTime.now();
  late DateTime _firstDayOfCurrentMonth = DateTime.now();


  Future<void> _openCamera() async {
    // Open the device camera
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _capturedImage = image;
      });
    }
  }


  ///MARK: - Init State
  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    _firstDayOfCurrentMonth = DateTime(now.year, now.month, 1);
    _lastDayOfCurrentMonth = DateTime(now.year, now.month + 1, 0); // last day of current month

    if (kDebugMode) {
      print(now);
      print(_firstDayOfCurrentMonth);
      print(_lastDayOfCurrentMonth);
    }

    String startDate = DateFormat('yyyy-MM-dd').format(_firstDayOfCurrentMonth);
    String endDate = DateFormat('yyyy-MM-dd').format(_lastDayOfCurrentMonth);
    fetchEvents(startDate,  endDate);
  }


  ///MARK:- Fetch Events
  void fetchEvents(String startDate, String endDate) async {
    print("Event Fetching");

    setState(() {
      isLoading = true;
    });

    // Example: for May 2025
    // String startDate = "2025-05-01";
    // String endDate = "2025-05-31";

    try {
      List<EventModel>? data = await RestFunction.fetchCalenderActivity(startDate: startDate, endDate: endDate);

      if (data != null) {
        if (mounted) {
          Map<DateTime, List<Map<String, dynamic>>> tempMap = {};

          for (var event in data) {
            DateTime normalizedDate = _normalizeDate(event.date);

            if (!tempMap.containsKey(normalizedDate)) {
              tempMap[normalizedDate] = [];
            }

            for (var activity in event.activities) {
              tempMap[normalizedDate]!.add({
                "id": activity.id,
                "name": activity.name.toString().split('.').last, // enum name
                "isCuringDone": event.isCuringDone,
              });
            }

            // ✅ Reverse the list of activities for this date
            tempMap[normalizedDate] = tempMap[normalizedDate]!.reversed.toList();
          }

          setState(() {
            eventItems = data;
            eventMap = tempMap;
            isLoading = false;
          });
        }
      } else {
        print("Error: No event data received.");
        setState(() {
          isLoading = false;
          eventItems = null;
        });
      }
    } catch (e, stackTrace) {
      print("Error fetching events: $e");
      print(stackTrace);
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Ensures all events have time set to 00:00:00 to match dates properly
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  ///MARK: - Camera operation
  void _openCameraAndShowDialog(StateSetter setStateDialog, Map<String, dynamic> task) async {
    final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _capturedImage = pickedFile; // Save image
      });

      setStateDialog(() {}); // Update UI inside the dialog

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
                    File(pickedFile.path), // Convert XFile to File
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
                      await uploadImageData(
                        context: context,
                        setStateDialog: setStateDialog,
                        taskId: task["id"].toString(),
                        taskName: task["name"].toString(),
                        taskStatus: task["status"].toString(),
                        taskMember: task["member"].toString(),
                        taskKey: task["key"].toString(),
                      );
                    },
                    child: const Text("OK"),
                  ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> uploadImageData({
    required BuildContext context,
    required StateSetter setStateDialog,
    required String taskId,
    required String taskName,
    required String taskStatus,
    required String taskMember,
    required String taskKey,
  }) async {
    if (_capturedImage == null) return;

    setState(() {
      isLoading = true; // Show loader before API call
    });

    final File imageFile = File(_capturedImage!.path);
    final bytes = await imageFile.readAsBytes();
    final base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";

    String? token = await SharedPreference.getToken();
    if (token == null) return;

    String apiUrl = "https://65.0.190.66/api/attachment";

    Map<String, String> requestBody = {
      "module": "activity",
      "file": base64Image,
      "parentId": taskId,
    };

    if (kDebugMode) {
      print("Uploading image with body: $requestBody");
      print("Token: $token");
      print(activityId.toString());
      print(taskId);
      print(taskName);
      print(taskStatus);
      print(taskMember);
      print(taskKey);
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false; // Only state change goes here
        });
        if (kDebugMode) print("Image uploaded successfully.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image uploaded successfully.", style: TextStyle(fontSize: 16, color: Colors.green)),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          isLoading = false; // Only state change goes here
        });
        if (kDebugMode) print("Image upload failed: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Only state change goes here
      });
      if (kDebugMode) print("Image upload error: $e");
    } finally {
      setStateDialog(() => isUploading = false); // Hide loader
    }
  }


  Future<void> sendFullDataToAPI(taskId, taskName, taskStatus, taskMember, taskKey) async {
    setState(() {
      isLoading = true; // Show loader before API call
    });
    String? token = await SharedPreference.getToken();
    if (token == null) return; // Return null if token is missing

    String apiUrl = "https://65.0.190.66/api/activityTracking";

    // Request body
    Map<String, String> requestBody = {
      "manPower": manpowerData.toString(),
      "isOnHold": onHoldStatus.toString(),
      "isCancelled": onCancelledStatus.toString(),
      "isCuringDone": onCuringStatus.toString(),
      "cost": costData.toString(),
      // "Item": "string",
      "activityId": activityId.toString(),
      "activity": taskStateData.toString(),
      "id": taskId,
      "name": taskName,
      "status": taskStatus,
      "date": DateTime.now().toIso8601String(),
      "member": taskMember,
      "key": taskKey
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
          isLoading = false; // Only state change goes here
        });

        await sendPatchData(taskId, taskName, taskStatus, taskMember, taskKey); // Async call happens *after* setState
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

  Future<void> sendPatchData(taskId, taskName, taskStatus, taskMember, taskKey) async {
    setState(() {
      isLoading = true; // Show loader before API call
    });
    String? token = await SharedPreference.getToken();
    if (token == null) return; // Return null if token is missing
    String apiUrl = "";

    apiUrl = "https://65.0.190.66//api/activity/$activityId";



    // Request body
    Map<String, String> requestBody = {
      "actualCost": costData.toString(),
      "isOnHold": onHoldStatus.toString(),
      "isCancelled": onCancelledStatus.toString(),
      "isAbandoned": onAbandonedStatus.toString(),
      "progressPercentage": progressData.toString(),
      "id": taskId,
      "name": taskName,
      "status": taskStatus,
      "date": DateTime.now().toIso8601String(),
      "member": taskMember,
      "key": taskKey
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
        setState(() {
          isLoading = false; // Hide loader after API response
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Activity Modified Successfully",
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.normal),
                ),
                duration: Duration(seconds: 2),
              )
          );
        });

        // if (kDebugMode) {
        //   print("API Response Value: $response");
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







  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          width: 120,
          child: Text("Activity Report",
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true, // This is default
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading ?
        const Center(child: CircularProgressIndicator()) :
        TableCalendar(
          firstDay: DateTime(2025, 1, 1),
          lastDay: DateTime(2040, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {

            setState(() {
              _focusedDay = focusedDay; // <-- this is essential
            });

            // Fetch new events for the new visible month
            print(focusedDay);
            DateTime firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
            DateTime lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0); // last day of current month

            if (kDebugMode) {
              print(focusedDay);
              print(firstDay);
              print(lastDay);
            }

            String startDate = DateFormat('yyyy-MM-dd').format(firstDay);
            String endDate = DateFormat('yyyy-MM-dd').format(lastDay);
            fetchEvents(startDate,  endDate);
            //fetchEvents(focusedDay);
          },
          eventLoader: (day) => eventMap[_normalizeDate(day)] ?? [],
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.yellow.shade200,
              shape: BoxShape.rectangle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronVisible: true,
            rightChevronVisible: true, // hides the next month arrow
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;

                bool showCuring = false;

                // Check if any event on that date has isCuringDone == true
                for (Map<String, dynamic> event in events.cast<Map<String, dynamic>>()) {
                  if (event['isCuringDone'] == true) {
                    showCuring = true;
                    break;
                  }
                }

                return GestureDetector(
                  onTap: () {
                      // Allow navigation only if it's today's date
                      print('Tapped date: $date');
                      print('Number of events: ${events.length}');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityDetailsPage(
                            selectedDate: date,
                            events: events.cast<Map<String, dynamic>>(),
                          ),
                        ),
                      );
                  },//_showEventPopup(context, date, events.cast<Map<String, dynamic>>()),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Red count circle
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              events.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 4), // space between count and badge

                        // Green "C" badge for curing
                        if (showCuring)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'C',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
            },
          ),
        ),
      ),
    );
  }
}

