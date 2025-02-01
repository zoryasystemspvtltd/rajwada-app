import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  // final TextEditingController _startDateController = TextEditingController();
  // final TextEditingController _endDateController = TextEditingController();
  //
  // bool _isChecked = false;
  //
  // Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
  //   DateTime now = DateTime.now();
  //   DateTime? selectedDate = await showDatePicker(
  //     context: context,
  //     initialDate: now,
  //     firstDate: now,
  //     lastDate: DateTime(2100),
  //   );
  //   if (selectedDate != null) {
  //     setState(() {
  //       controller.text = "${selectedDate.toLocal()}".split(' ')[0];
  //     });
  //   }
  // }

  final List<Map<String, dynamic>> _icons = [];
  XFile? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    // Open the device camera
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _capturedImage = image;
      });
    }
  }

  void _showIconOptionsDialog(Offset position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Icon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera Icon'),
                onTap: () {
                  setState(() {
                    _icons.add({'position': position, 'type': 'camera', 'text': ''});
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.bubble_chart),
                title: Text('Balloon Icon'),
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

  void _showAddTextDialog(Map<String, dynamic> iconData) {
    TextEditingController _textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Text'),
          content: TextField(
            controller: _textController,
            decoration: InputDecoration(hintText: 'Enter your text here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  iconData['text'] = _textController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenImage(File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imageFile: imageFile),
      ),
    );
  }

  void _showCameraIconDialog(Map<String, dynamic> iconData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Icon'),
          content: const Text('Do you want to place a new camera icon or remove the existing one?'),
          actions: [
            TextButton(
              onPressed: () {
                // Remove the camera icon
                setState(() {
                  _icons.remove(iconData);
                });
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                // Place a new camera icon
                _openCamera();
                Navigator.pop(context);
              },
              child: const Text('Update Existing Picture'),
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

  void _showBalloonIconDialog(Map<String, dynamic> iconData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Balloon Icon'),
          content: const Text('Do you want to place a new balloon icon or remove the existing one?'),
          actions: [
            TextButton(
              onPressed: () {
                // Remove the balloon icon
                setState(() {
                  _icons.remove(iconData);
                });
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                // Place a new balloon icon by calling _showAddTextDialog
                setState(() {
                  Navigator.pop(context);
                  _showAddTextDialog(iconData);
                });

                //Navigator.pop(context);
              },
              child: const Text('Update Existing Text'),
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
      body: Stack(
        children: [
          // Floor plan image
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              _showIconOptionsDialog(details.localPosition);
            },
            child: Image.asset(
              'assets/images/f1.jpeg', // Add the image to your assets folder
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Display added icons
          ..._icons.map((iconData) {
            Offset position = iconData['position'];
            String type = iconData['type'];
            String text = iconData['text'];

            return Positioned(
              left: position.dx - 25, // Adjust offset
              top: position.dy - 25,
              child: GestureDetector(
                onTap: () {
                  if (type == 'camera') {
                    if (_capturedImage != null){
                      _showCameraIconDialog(iconData);
                    } else{
                      _openCamera();
                    }

                  } else if (type == 'balloon') {
                    if (text.isEmpty){
                      _showAddTextDialog(iconData);
                    } else{
                      _showBalloonIconDialog(iconData);
                    }

                  }
                },
                child: Column(
                  children: [
                    Image.asset(
                      type == 'camera'
                          ? 'assets/images/c1.png'
                          : 'assets/images/pin.png', // Add balloon icon
                      width: 50,
                      height: 50,
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
          // Display captured image
          if (_capturedImage != null)
            Positioned(
              bottom: 20,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  _showFullScreenImage(File(_capturedImage!.path));
                },
                child: Image.file(
                  File(_capturedImage!.path),
                  width: 100,
                  height: 100,
                ),
              ),
            ),
        ],
      ),
      // Container(
      //   padding: EdgeInsets.only(top: 50),
      //   width: double.infinity,
      //   height: double.infinity,
      //   decoration: const BoxDecoration(
      //     image: DecorationImage(
      //       image: AssetImage('assets/images/onboard_background.png'),
      //       fit: BoxFit.cover,
      //     ),
      //   ),
      //   child: Padding(
      //     padding: const EdgeInsets.all(16.0),
      //     child: SingleChildScrollView(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           // Name TextField
      //           TextField(
      //             decoration: InputDecoration(
      //               labelText: 'Name',
      //               hintText: 'Enter your name',
      //               border: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(8),
      //               ),
      //             ),
      //           ),
      //           SizedBox(height: 20),
      //
      //           // Email TextField
      //           TextField(
      //             decoration: InputDecoration(
      //               labelText: 'Email',
      //               hintText: 'Enter your email',
      //               border: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(8),
      //               ),
      //             ),
      //           ),
      //           SizedBox(height: 20),
      //
      //           // Phone Number TextField
      //           TextField(
      //             keyboardType: TextInputType.phone,
      //             decoration: InputDecoration(
      //               labelText: 'Phone Number',
      //               hintText: 'Enter your phone number',
      //               border: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(8),
      //               ),
      //             ),
      //           ),
      //           SizedBox(height: 20),
      //
      //           // Address TextField
      //           TextField(
      //             maxLines: 3,
      //             decoration: InputDecoration(
      //               labelText: 'Address',
      //               hintText: 'Enter your address',
      //               border: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(8),
      //               ),
      //             ),
      //           ),
      //           SizedBox(height: 20),
      //
      //           // Start Date and End Date
      //           Row(
      //             children: [
      //               Expanded(
      //                 child: GestureDetector(
      //                   onTap: () => _selectDate(context, _startDateController),
      //                   child: AbsorbPointer(
      //                     child: TextField(
      //                       controller: _startDateController,
      //                       decoration: InputDecoration(
      //                         labelText: 'Start Date',
      //                         hintText: 'Select start date',
      //                         border: OutlineInputBorder(
      //                           borderRadius: BorderRadius.circular(8),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //               SizedBox(width: 10),
      //               Expanded(
      //                 child: GestureDetector(
      //                   onTap: () => _selectDate(context, _endDateController),
      //                   child: AbsorbPointer(
      //                     child: TextField(
      //                       controller: _endDateController,
      //                       decoration: InputDecoration(
      //                         labelText: 'End Date',
      //                         hintText: 'Select end date',
      //                         border: OutlineInputBorder(
      //                           borderRadius: BorderRadius.circular(8),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           ),
      //           SizedBox(height: 20),
      //
      //           // Checkbox
      //           Row(
      //             children: [
      //               Checkbox(
      //                 value: _isChecked,
      //                 onChanged: (value) {
      //                   setState(() {
      //                     _isChecked = value!;
      //                   });
      //                 },
      //               ),
      //               Text('I agree to the terms and conditions'),
      //             ],
      //           ),
      //
      //           SizedBox(height: 20),
      //
      //           // Submit Button
      //           SizedBox(
      //             width: double.infinity,
      //             child: ElevatedButton(
      //               onPressed: () {
      //                 // Login action
      //                 //Navigator.pushReplacementNamed(context, '/dashboard');
      //               },
      //               style: ElevatedButton.styleFrom(
      //                 backgroundColor: Colors.green,
      //                 padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
      //                 shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(10),
      //                 ),
      //               ),
      //               child: const Text(
      //                 "Submit",
      //                 style:
      //                 TextStyle(fontSize: 18, color: Colors.white),
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final File imageFile;

  const FullScreenImage({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Captured Image'),
      ),
      body: Center(
        child: Image.file(
          imageFile,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}