import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rajwada_app/core/model/event_data_model.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/functions/functions.dart';
import '../helper/app_colors.dart';


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

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Map<DateTime, List<Map<String, dynamic>>> groupEventsByDate(EventModel eventModel)
  {

    if (eventModel.items != null) {
      for (var item in eventModel.items!) {
        if (item.startDate != null && item.endDate != null && item.name != null) {
          DateTime start = _normalizeDate(item.startDate!);
          DateTime end = _normalizeDate(item.endDate!);

          for (DateTime date = start; date.isBefore(end.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
            if (!eventMap.containsKey(date)) {
              eventMap[date] = [];
            }

            eventMap[date]!.add({
              "id": item.id,
              "name": item.name!,
              "progressPercentage": item.progressPercentage ?? 0, // Default 0 if null
              "actualCost": item.actualCost ?? 0, // Default 0 if null
            });
          }
        }
      }
    }
    return eventMap;
  }

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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Events on this day:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
              ),
              SizedBox(height: 10),
              ...events.map((event) => GestureDetector(
                onTap: () {
                  showTaskUpdateDialog(context, date, event);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      event["name"],
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void showTaskUpdateDialog(BuildContext context, DateTime date, Map<String, dynamic> event) {
    TextEditingController costController = TextEditingController(text: event["actualCost"].toString());

    double initialProgress = 10.0 ?? 0.0; // Default to 0 if null

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              content: Container(
                width: 350, // Adjust width
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Task Update Form",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Align(
                        alignment: Alignment.topLeft,
                        child: Text("Date: ${date.day}-${date.month}-${date.year}",
                            style: const TextStyle(fontWeight: FontWeight.bold))
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text("Task: ${event["name"]}",
                            style: const TextStyle(fontWeight: FontWeight.bold))
                    ),

                    const SizedBox(height: 10),

                    const Text("Cost"),
                    TextField(
                      controller: costController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter cost",
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 10),

                    const Text("Progress"),
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: initialProgress / 100, // Normalized to 0-1 range
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        const SizedBox(height: 10),
                        Slider(
                          value: initialProgress,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: "${initialProgress.toInt()}%",
                          onChanged: (newValue) {
                            setState(() {
                              initialProgress = newValue < 10 ? 10 : newValue; // Update progress inside setState
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          child: const Text("Close", style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Handle submission
                            print("Submitted: Cost - ${costController.text}, Progress - ${initialProgress.toInt()}%");
                            Navigator.pop(context); // Close the dialog
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text("Submit", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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

            //List<Item> events = eventMap[selectedDay] ?? [];

            if (_events.containsKey(_normalizeDate(selectedDay))) {
              _showEventPopup(context, selectedDay, _events[_normalizeDate(selectedDay)]!);
            }
          },
          eventLoader: (day) => _events[_normalizeDate(day)] ?? [],
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

