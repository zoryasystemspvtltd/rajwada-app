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
  late Map<DateTime, List<String>> _events;
  EventModel? eventItems;
  bool isLoading = false; // Loader state

  @override
  void initState() {
    super.initState();
    fetchEvents();
    _initializeEvents();
  }

  void fetchEvents() async {

    print("Event Fetching");
    setState(() {
      isLoading = true;
    });

    EventModel? data =
    await RestFunction.fetchActivity();
    if (mounted) {
      setState(() {
        isLoading = false;
        eventItems = data;
        print("Event Fetched");
        // Clear previous dataRows and controllers
      });
    }
  }

  /// Ensures all events have time set to 00:00:00 to match dates properly
  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }


  void _initializeEvents() {
    _events = {
      _normalizeDate(DateTime(2025, 2, 5)): ["Hacking-Project-2-C-F1-1"],
      _normalizeDate(DateTime(2025, 2, 10)): ["Task A", "Task B"],
      _normalizeDate(DateTime(2025, 2, 15)): ["Meeting", "Review Session"],
      _normalizeDate(DateTime(2025, 2, 20)): ["Project Submission"],
      _normalizeDate(DateTime(2025, 2, 26)): ["Final Exam"],
    };
  }

  // void _initializeEvents() {
  //   _events = {
  //     _normalizeDate(DateTime(2025, 2, 1)): [1],
  //     _normalizeDate(DateTime(2025, 2, 2)): [1],
  //     _normalizeDate(DateTime(2025, 2, 3)): [1],
  //     _normalizeDate(DateTime(2025, 2, 4)): [1],
  //     _normalizeDate(DateTime(2025, 2, 5)): [1],
  //     _normalizeDate(DateTime(2025, 2, 6)): [1],
  //     _normalizeDate(DateTime(2025, 2, 7)): [1],
  //     _normalizeDate(DateTime(2025, 2, 9)): [1],
  //     _normalizeDate(DateTime(2025, 2, 10)): [1],
  //     _normalizeDate(DateTime(2025, 2, 11)): [2],
  //     _normalizeDate(DateTime(2025, 2, 12)): [2],
  //     _normalizeDate(DateTime(2025, 2, 13)): [2],
  //     _normalizeDate(DateTime(2025, 2, 14)): [2],
  //     _normalizeDate(DateTime(2025, 2, 15)): [1],
  //   };
  // }

  /// Shows a popup with event details
  void _showEventPopup(BuildContext context, DateTime date, List<String> events) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Tasks For Date: ${date.day}-${date.month}-${date.year}",style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Events on this day:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...events.map((event) => Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    event,
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
        child: TableCalendar(
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
              _showEventPopup(context, selectedDay, _events[_normalizeDate(selectedDay)]!);
            }
          },
          eventLoader: (day) => _events[_normalizeDate(day)] ?? [],
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.yellow.shade200,
              shape: BoxShape.rectangle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return GestureDetector(
                  onTap: () => _showEventPopup(context, date, events.cast<String>()),
                  child: Align( // Use Align instead of Positioned
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          events.length.toString(),
                          style: TextStyle(
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