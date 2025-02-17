import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rajwada_app/core/functions/functions.dart';

import '../../core/model/project_detail_model.dart';
import '../helper/app_colors.dart';


class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen(
      {super.key, required this.projectId});

  @override
  _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {

  ProjectDetailModel? projectDetail;
  bool isLoading = false; // Loader state
  Uint8List? bytes;

  @override
  void initState() {
    super.initState();
    fetchProjectDetail();

  }

  Future<void> fetchProjectDetail() async{
    setState(() {
      isLoading = true;
    });
    ProjectDetailModel? data = await RestFunction.fetchProjectDetail(widget.projectId);
    if (mounted) {
      setState(() {
        isLoading = false;
        projectDetail = data;
        // Clear previous dataRows and controllers
      });
    }
  }


  @override
  Widget build(BuildContext context) {


    if (projectDetail?.blueprint != null && projectDetail!.blueprint!.isNotEmpty) {
      String cleanBase64 = projectDetail!.blueprint!.split(',').last;
      bytes = base64Decode(cleanBase64);
    }

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          width: 120,
          child: Text("Project Detail",
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true, // This is default
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child:  isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Name: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.name ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Alias: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.code ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Start Fin Year: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.startFinYear ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Planned Start Date: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.planStartDate != null
                              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(projectDetail!.planStartDate.toString()))
                              : "No Date Available", // Default text if null
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Planned End Date: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.planEndDate != null
                              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(projectDetail!.planEndDate.toString()))
                              : "No Date Available", // Default text if null
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Zone: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.zone ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Belongs To: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.belongTo ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Completion Certificate Date: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.completionCertificateDate != null
                              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(projectDetail!.completionCertificateDate.toString()))
                              : "No Date Available", // Default text if null
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Address 1: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.address1 ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Address 2: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.address2 ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Address 3: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.address3 ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Country: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.country ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "State: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.state ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "City: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.city ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "PIN: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.pinCode ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Latitude: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.latitude ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Longitude: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.longitude ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Phone: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.phoneNumber ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Contact Name: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: projectDetail?.contactName ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 15, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Project Blueprint: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Center(
                child: projectDetail?.blueprint != null &&
                    projectDetail!.blueprint!.isNotEmpty && bytes != null
                    ? Image.memory(bytes!) // Safe usage
                    : const Text("No blueprint available"),
              ),
            ],
          ),
        ),
      ),
    );
  }


}