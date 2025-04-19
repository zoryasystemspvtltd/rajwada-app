import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' as typed;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rajwada_app/core/model/event_data_model.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/functions/functions.dart';
import '../helper/app_colors.dart';
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
  EventModel? eventItems;
  bool isLoading = false; // Loader state
  Map<DateTime, List<Map<String, dynamic>>> eventMap = {};
  typed.Uint8List? bytes;
  XFile? _capturedImage;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _icons = [];


  Future<void> _openCamera() async {
    // Open the device camera
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _capturedImage = image;
      });
    }
  }

  /// MARK:- Show Image in Full Screen
  void _showFullScreenImage() {
    if (_capturedImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imagePath: _capturedImage!.path),
      ),
    );
  }

  ///MARK: - Init State
  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  ///MARK:- Group Events By Date
  Map<DateTime, List<Map<String, dynamic>>> groupEventsByDate(EventModel eventModel)
  {
    if (eventModel.items != null) {
      for (var item in eventModel.items!) {
        DateTime? start, end;
        if (item.parent?.startDate != null && item.parent?.endDate != null) {
          start = _normalizeDate(item.parent!.startDate!);
          end = _normalizeDate(item.parent!.endDate!);
        } else if (item.startDate != null && item.endDate != null) {
          start = _normalizeDate(item.startDate!);
          end = _normalizeDate(item.endDate!);
        }

        // Ensure start and end are assigned before using them
        if (start != null && end != null) {
          for (DateTime date = start; date.isBefore(end.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
            eventMap.putIfAbsent(date, () => []).add({
              "id": item.id,
              "name": item.name ?? "Unknown", // Handle potential null names
              "progressPercentage": item.progressPercentage ?? 0, // Default to 0 if null
              "actualCost": item.actualCost ?? 0, // Default to 0 if null
              "photoUrl": item.parent?.photoUrl,
            });
          }
        }
      }
    }
    return eventMap;
  }

  ///MARK:- Fetch Events
  void fetchEvents() async {
    print("Event Fetching");

    setState(() {
      isLoading = true;
    });

    try {
      EventModel? data = await RestFunction.fetchActivity();

      if (data != null) {
        if (mounted) {
          setState(() {
            isLoading = false;
            eventItems = data;
            _events = groupEventsByDate(eventItems!);
            print("Event Fetched");
            print("Event Items: ${jsonEncode(eventItems)}");
            print("Event Map: $_events");
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

  /// Shows a popup with event details
  void _showEventPopup(BuildContext context, DateTime date, List<Map<String, dynamic>> events) {

    print(events);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Tasks For Date: ${date.day}-${date.month}-${date.year}",style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Events on this day:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ),
                const SizedBox(height: 10),
                ...events.map((event) => GestureDetector(
                  onTap: () {
                    showTaskUpdateDialog(context, date, event);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        event["name"],
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  ///MARK: - Camera operation
  void _openCameraAndShowDialog(StateSetter setStateDialog) async {
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
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close preview dialog
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

  ///MARK:- Task Update Dialog
  void showTaskUpdateDialog(BuildContext context, DateTime date, Map<String, dynamic> task) {
    TextEditingController costController = TextEditingController(text: task["actualCost"].toString());
    TextEditingController manpowerController = TextEditingController(text: "0");
    double progress = 0.0;
    String? selectedStatus;

    print("Task Detail: $task");

    if (task["photoUrl"] != null &&
        task["photoUrl"].isNotEmpty) {

      String cleanBase64 = task["photoUrl"].split(',').last;
      bytes = base64Decode(cleanBase64); // Should work fine
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Task Update Form", style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text("Date: ${date.day}-${date.month}-${date.year}",
                                style: const TextStyle(fontWeight: FontWeight.bold))
                        ),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text("Task: ${task["name"]}", style: const TextStyle(fontWeight: FontWeight.bold))
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: costController,
                      decoration: const InputDecoration(labelText: "Cost", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: manpowerController,
                      decoration: const InputDecoration(labelText: "Man Power", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    const Text("Task Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 10,
                      children: ["In Progress", "On Hold", "Cancelled", "Abandoned", "Curing"]
                          .map((status) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio(
                            value: status,
                            groupValue: selectedStatus,
                            onChanged: (value) {
                              setStateDialog(() { // Update UI inside dialog
                                selectedStatus = value.toString();
                                if (selectedStatus == "Curing") {
                                  _openCameraAndShowDialog(setStateDialog); // Open Camera
                                }
                              });
                            },
                          ),
                          Text(status),
                          if (status == "Curing" && selectedStatus == "Curing" && _capturedImage != null)
                            GestureDetector(
                              onTap: _showFullScreenImage,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_capturedImage!.path),
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
                        setStateDialog(() {
                          progress = value;
                        });
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
                    const Text("Activity Blueprint", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          _showIconOptionsDialog(details.localPosition, setStateDialog); // ✅ Pass setStateDialog
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Stack(
                            children: [
                              bytes != null
                                  ? Image.memory(bytes!)
                                  : const Text("No blueprint available"),
                              ..._icons.map((iconData) {
                                Offset position = iconData['position'];
                                String type = iconData['type'];
                                String text = iconData['text'];

                                return Positioned(
                                  left: position.dx - 25,
                                  top: position.dy - 25,
                                  child: GestureDetector(
                                    onTap: () => _handleIconTap(iconData, setStateDialog),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          type == 'camera' ? 'assets/images/c1.png' : 'assets/images/pin.png',
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
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text("Close", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                // Handle submit action here
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  ///MARK:- Handle Taps on Existing Icons
  void _handleIconTap(Map<String, dynamic> iconData, void Function(void Function()) setStateDialog) {
    switch (iconData['type']) {
      case 'camera':
        _showCameraIconDialog(iconData, setStateDialog);
        break;
      case 'balloon':
        _showBalloonIconDialog(iconData, setStateDialog);
        break;
    }
  }

  ///MARK:- Show Icon Dialog
  void _showIconOptionsDialog(Offset position, void Function(void Function()) setStateDialog) {
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
                  setStateDialog(() {}); // ✅ Rebuild AlertDialog
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
                  setStateDialog(() {}); // ✅ Rebuild AlertDialog
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
  void _showAddTextDialog(Map<String, dynamic> iconData, void Function(void Function()) setStateDialog) {
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
                setStateDialog(() { // ✅ Updates AlertDialog UI
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

  ///MARK:- Show Camera Icon Dialog
  void _showCameraIconDialog(Map<String, dynamic> iconData, void Function(void Function()) setStateDialog) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Icon'),
          content: const Text('Do you want to update or remove this camera icon?'),
          actions: [
            TextButton(
              onPressed: () {
                setStateDialog(() { // ✅ Updates AlertDialog UI
                  _icons.remove(iconData);
                });
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                _openCameraAndShowDialog(setStateDialog); // ✅ Use setStateDialog for updates
                Navigator.pop(context);
              },
              child: const Text('Update'),
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

  ///MARK:- Show Balloon Icon Dialog
  void _showBalloonIconDialog(Map<String, dynamic> iconData, void Function(void Function()) setStateDialog) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Balloon Icon'),
          content: const Text('Do you want to update or remove this text balloon?'),
          actions: [
            TextButton(
              onPressed: () {
                setStateDialog(() { // ✅ Updates AlertDialog UI
                  _icons.remove(iconData);
                });
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddTextDialog(iconData, setStateDialog); // ✅ Pass setStateDialog
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
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            if (_events.containsKey(_normalizeDate(selectedDay))) {
              _showEventPopup(context, selectedDay, eventMap[_normalizeDate(selectedDay)]!);
            }
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
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return GestureDetector(
                  onTap: () => _showEventPopup(context, date, events.cast<Map<String, dynamic>>()),
                  child: Align( // Use Align instead of Positioned
                    alignment: Alignment.bottomCenter,
                    child: Container(
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}

