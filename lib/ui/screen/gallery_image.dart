import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../core/model/image_gallery_model.dart';
import '../../core/service/shared_preference.dart';
import '../helper/app_colors.dart';

class ImageGalleryPage extends StatefulWidget {
  final int? parentId;

  const ImageGalleryPage({
    Key? key,
    required this.parentId,
  }) : super(key: key);

  @override
  _ImageGalleryPageState createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
  List<String> imageUrls = [];
  bool isLoading = true;
  List<Uint8List> imageBytesList = [];
  int currentIndex = 0;
  ImageGalleryModel model = ImageGalleryModel(); // or late if you're sure it's assigned
  late PageController _pageController;


  String formatDateToIST(String dateStr) {
    try {
      DateTime utcDate = DateTime.parse(dateStr);
      DateTime istDate = utcDate.add(const Duration(hours: 5, minutes: 30));
      return DateFormat('yyyy/MM/dd HH:mm').format(istDate);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
    fetchImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchImages() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null) return;

      Uri apiUrl = Uri.parse("https://65.0.190.66/api/attachment");

      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        "apioption": jsonEncode({
          "recordPerPage": 0,
          "searchCondition": {
            "name": "parentId",
            "value": widget.parentId.toString(),
            "and": {
              "name": "module",
              "value": "activity",
            }
          }
        }),
      };

      final response = await http.get(apiUrl, headers: headers);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        model = ImageGalleryModel.fromJson(decoded);

        setState(() {
          imageBytesList = (model.items ?? [])
              .map((item) {
            final base64Str = item.file;
            if (base64Str != null && base64Str.isNotEmpty) {
              try {
                final base64Data = base64Str
                    .split(',')
                    .last; // Remove "data:image/jpeg;base64,"
                return base64Decode(base64Data);
              } catch (e) {
                print("Base64 decode error: $e");
              }
            }
            return null;
          })
              .whereType<Uint8List>()
              .toList();

          isLoading = false;
        });
      } else {
        print('Fetch image failed: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error during fetch image: $e');
      setState(() {
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
          child: Text("Image Gallery",
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : imageBytesList.isEmpty
          ? const Center(child: Text("No images found."))
          : Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              const SizedBox(height: 12),
              // ✅ Image Name
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Putty Work-Tower E-Floor 1-Flat 1-Bed Room-1',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              // ✅ Image Counter
              Text(
                "${currentIndex + 1} / ${imageBytesList.length}",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              // ✅ Image Viewer
              Expanded(
                child: PageView.builder(
                  itemCount: imageBytesList.length,
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Image.memory(
                        imageBytesList[index],
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // ✅ Left Arrow
          Positioned(
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                if (currentIndex > 0) {
                  currentIndex--;
                  _pageController.animateToPage(
                    currentIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() {});
                }
              },
            ),
          ),
          // ✅ Right Arrow
          Positioned(
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onPressed: () {
                if (currentIndex < imageBytesList.length - 1) {
                  currentIndex++;
                  _pageController.animateToPage(
                    currentIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() {});
                }
              },
            ),
          ),
          // ✅ Uploader Name
          Positioned(
            bottom: 100,
            child: Center(
              child: Column(
                children: [
                  Text(model.items![currentIndex].member.toString(),style: const TextStyle(fontSize: 20,color: Colors.white),),
                  // Inside your widget
                  Text(
                    "Uploaded Date Time: ${formatDateToIST(model.items![currentIndex].date.toString())}",
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}