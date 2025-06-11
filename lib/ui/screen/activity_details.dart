import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../helper/app_colors.dart';
import 'activity_sub_details.dart';


class ActivityDetailsPage extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> events;

  const ActivityDetailsPage({
    Key? key,
    required this.selectedDate,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          width: 120,
          child: Text("Activity Details",
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true, // This is default
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return GestureDetector(
            onTap: () {
              // Navigate to the sub details page with the event ID
              print("Event id: ${events[index]["id"]}");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivitySubDetailsPage(
                    eventId: event['id'],
                    selectedDate: selectedDate,// Ensure 'id' is present in your event map
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                event['name'] ?? 'No name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}