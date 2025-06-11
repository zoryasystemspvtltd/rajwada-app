import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:rajwada_app/core/model/activity_sub_detail_model.dart';
import 'package:rajwada_app/ui/screen/gallery_image.dart';
import 'package:rajwada_app/ui/screen/post_activity_report.dart';
import 'package:rajwada_app/ui/screen/post_comment.dart';

import '../../core/functions/functions.dart';
import '../../core/model/event_data_model.dart';
import '../helper/app_colors.dart';


class ActivitySubDetailsPage extends StatefulWidget {
  final int eventId;
  final DateTime selectedDate;

  const ActivitySubDetailsPage({super.key, required this.eventId,required this.selectedDate,});

  @override
  State<ActivitySubDetailsPage> createState() => _ActivitySubDetailsPageState();
}

class _ActivitySubDetailsPageState extends State<ActivitySubDetailsPage> {
  ActivitySubDetailModel? subActivityDetails;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSubActivityDetails();
  }

  void fetchSubActivityDetails() async {
    try {
      final data = await RestFunction.fetchSubActivityList(widget.eventId);
      setState(() {
        subActivityDetails = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          width: 160,
          child: Text(
            "Activity Sub Details",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
      ),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (errorMessage != null) {
            return Center(child: Text('Error: $errorMessage'));
          }

          if (subActivityDetails == null || subActivityDetails!.items == null ||
              subActivityDetails!.items!.isEmpty) {
            return const Center(child: Text('No sub-activity details found.'));
          }

          final items = subActivityDetails!.items!;
          print(items.length);
          for (var item in items) {
            print('Description: ${item.description}');
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final activityData = items[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Slidable(
                  key: ValueKey(activityData.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.9,
                    children: [
                      CustomSlidableAction(
                        onPressed: (context) {
                          print("Chat tapped for ${activityData.name}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentPage(
                                parentId: activityData.id, loggedInUser: 'a.bose@civilhead.com',
                                selectedDate: widget.selectedDate,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/chat.png',
                                width: 25,
                                height: 25,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      CustomSlidableAction(
                        onPressed: (context) {
                          print("Image tapped for ${activityData.name}");
                          print("Activity Id: ${activityData.id}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageGalleryPage(
                                parentId: activityData.id,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/gallery.png',
                                width: 25,
                                height: 25,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      CustomSlidableAction(
                        onPressed: (context) {
                          print("Delete tapped for ${activityData.name}");
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/bin-2.png',
                                width: 25,
                                height: 25,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (activityData.id != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostActivityReportPage(
                              subDetailItemId: activityData.id!,
                              selectedDate: widget.selectedDate,
                            ),
                          ),
                        );
                      } else {
                        print("Error: activityData.id is null");
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity, // Make the container full width
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        activityData.name.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}