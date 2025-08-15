import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rajwada_app/core/model/comment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/model/quality_user_model.dart';
import '../../core/service/shared_preference.dart';
import '../helper/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CommentPage extends StatefulWidget {
  final String loggedInUser;
  final int? parentId;
  final DateTime selectedDate;

  const CommentPage({Key? key, required this.loggedInUser,required this.parentId,required this.selectedDate,}) : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  List<CommentModelItem> comments = [];
  final TextEditingController commentController = TextEditingController();
  CommentModel model = CommentModel();
  bool isLoading = true;
  String? date = "";
  QualityItem? loggedInUser;
  File? _imageFile;
  File? capturedImage;
  bool isUploading = false;

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  @override
  void initState() {
    super.initState();

    _loadLoggedInUser();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() => isLoading = true);

    try {
      final token = await SharedPreference.getToken();
      if (token == null) {
        print('Token is null');
        return;
      }

      final Uri apiUrl = Uri.parse("https://65.0.190.66/api/comment");

      final String apiOptionJson = jsonEncode({
        "recordPerPage": 0,
        "searchCondition": {
          "name": "activityId",
          "value": widget.parentId,
        }
      });

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        "apioption": apiOptionJson, // correct usage
      };

      final response = await http.get(apiUrl, headers: headers);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final commentModel = CommentModel.fromJson(decoded);

        setState(() {
          comments = (commentModel.items ?? []).reversed.toList();
          isLoading = false;
        });
      } else if (response.statusCode == 204) {
        // No content found
        print('No comments found.');
        setState(() {
          comments = [];
          isLoading = false;
        });
      } else {
        print('Fetch comment failed: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e, stack) {
      print('Error during fetch comment: $e');
      print(stack);
      setState(() => isLoading = false);
    }
  }

  Future<void> _postComment(String commentText) async {
    final token = await SharedPreference.getToken();
    if (token == null) {
      print('Token is null');
      return;
    }

    final Uri apiUrl = Uri.parse("https://65.0.190.66/api/comment");
    final Map<String, dynamic> payload = {
      "activityId": widget.parentId.toString(),
      "remarks": commentText,
      "date": DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Comment posted successfully');
        commentController.clear(); // Clear the input
        await _fetchComments(); // Refresh the list on success
      } else {
        print('Failed to post comment. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error posting comment: $e');
    }
  }

  Future<QualityItem?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('loggedInUser');
    if (userJson != null) {
      final Map<String, dynamic> map = json.decode(userJson);
      return QualityItem.fromJson(map);
    }
    return null;
  }

  Future<void> _loadLoggedInUser() async {
    final user = await getLoggedInUser();
    setState(() {
      loggedInUser = user;
      print(loggedInUser);
    });
  }



  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    // Request permission
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera permission denied')),
        );
        return;
      }
    } else if (source == ImageSource.gallery) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery permission denied')),
        );
        return;
      }
    }

    // Pick the image
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        capturedImage = File(pickedFile.path); // 👈 store for activity module
      });

      // Show snackbar after selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selected')),
      );

      // Call upload method
      await uploadImageData(
        context: context,
        taskId: widget.parentId.toString(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
    }
  }

  Future<void> uploadImageData({
    required BuildContext context,
    required String taskId,
  }) async {
    setState(() {
      isLoading = true;
    });

    String? token = await SharedPreference.getToken();
    if (token == null) return;

    String apiUrl = "https://65.0.190.66/api/attachment";

    final List<Map<String, dynamic>> uploadTasks = [];

    if (capturedImage != null) {
      uploadTasks.add({
        "image": capturedImage,
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

  Widget _buildCommentBubble(CommentModelItem comment) {
    bool isCurrentUser =
        comment.member?.trim().toLowerCase() ==
            loggedInUser?.member?.trim().toLowerCase();

    String convertUtcIsoToIST(String isoDateString) {
      try {
        final dateTime = DateTime.parse(isoDateString);
        final utcDateTime = DateTime.utc(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
        );
        final istDate = utcDateTime.add(const Duration(hours: 5, minutes: 30));
        return DateFormat('dd/MM/yyyy HH:mm').format(istDate);
      } catch (e) {
        print('Error converting to IST: $e');
        return isoDateString;
      }
    }

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: const BoxConstraints(maxWidth: 250),
        child: Column(
          crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser) // only show name if it's another user
              Text(
                comment.member ?? "",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            if (!isCurrentUser) const SizedBox(height: 4),
            Text(comment.remarks ?? ""),
            const SizedBox(height: 4),
            Text(
              convertUtcIsoToIST(comment.date ?? ""),
              style: const TextStyle(fontSize: 10, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildCommentBubble(CommentModelItem comment) {
  //   bool isCurrentUser = comment.member == loggedInUser?.member;
  //
  //   // Safely parse and format date
  //   /// Converts an ISO 8601 timestamp string to local time and formats it.
  //   /// Returns a formatted local time string like '03/06/2025 11:17 PM'.
  //   String convertUtcIsoToIST(String isoDateString) {
  //     try {
  //       // Step 1: Parse string manually as if it’s UTC
  //       final dateTime = DateTime.parse(isoDateString);
  //
  //       // Step 2: Treat parsed time as UTC by reconstructing
  //       final utcDateTime = DateTime.utc(
  //         dateTime.year,
  //         dateTime.month,
  //         dateTime.day,
  //         dateTime.hour,
  //         dateTime.minute,
  //         dateTime.second,
  //       );
  //
  //       // Step 3: Add IST offset
  //       final istDate = utcDateTime.add(const Duration(hours: 5, minutes: 30));
  //
  //       // Step 4: Format
  //       return DateFormat('dd/MM/yyyy HH:mm').format(istDate);
  //     } catch (e) {
  //       print('Error converting to IST: $e');
  //       return isoDateString;
  //     }
  //   }
  //
  //   return Align(
  //     alignment: isCurrentUser ?  Alignment.centerLeft : Alignment.centerRight,
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(vertical: 4),
  //       padding: const EdgeInsets.all(10),
  //       decoration: BoxDecoration(
  //         color: isCurrentUser ? Colors.blue.shade100 : Colors.grey.shade200,
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       constraints: const BoxConstraints(maxWidth: 250),
  //       child: Column(
  //         crossAxisAlignment:
  //         isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             comment.member.toString(),
  //             style: const TextStyle(fontSize: 12, color: Colors.black54),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(comment.remarks.toString()),
  //           const SizedBox(height: 4),
  //           Text(
  //             convertUtcIsoToIST(comment.date.toString()),
  //             style: const TextStyle(fontSize: 10, color: Colors.black38),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          width: 160,
          child: Text("Comments",
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _fetchComments();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                ? const Center(child: Text("No comments yet."))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: comments.length,
              itemBuilder: (context, index) =>
                  _buildCommentBubble(comments[index]),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Row 1: Text Field
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'Type Your Comment Here...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),

                // Row 2: Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: isToday(widget.selectedDate)
                          ? () {
                        final comment = commentController.text.trim();
                        if (comment.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please type comment to post'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        _postComment(comment);
                      }
                          : null, // disables the button
                      child: const Text('Post Comment'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: isToday(widget.selectedDate)
                          ? () => _showImageSourceActionSheet(context)
                          : null,
                      child: const Text('Upload Photo'),
                    ),
                    if (_imageFile != null) ...[
                      SizedBox(height: 20),
                      Image.file(_imageFile!, height: 150),
                    ],
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}