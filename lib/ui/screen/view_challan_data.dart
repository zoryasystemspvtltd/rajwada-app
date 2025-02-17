import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rajwada_app/ui/screen/project_detail.dart';

import '../../core/functions/functions.dart';
import '../../core/model/challan_detailItem_model.dart';
import '../../core/model/challan_status_model.dart';
import '../helper/app_colors.dart';
import '../widget/form_field_widget.dart';


class ViewChallanScreen extends StatefulWidget {
  final int challanId;
  final challanData;

  const ViewChallanScreen(
      {super.key, required this.challanId, this.challanData});

  @override
  _ViewChallanScreenState createState() => _ViewChallanScreenState();
}

class _ViewChallanScreenState extends State<ViewChallanScreen> {

  ChallanDetailItemModel? _challanDetailItem;
  Map<int, Map<String, TextEditingController>> controllers = {};
  bool isLoading = false; // Loader state
  List<ChallanStatusModel> _statusList = [];


  TextEditingController getController(int index, String fieldKey) {
    if (!controllers.containsKey(index)) {
      controllers[index] = {};
    }
    return controllers[index]!
        .putIfAbsent(fieldKey, () => TextEditingController());
  }

  @override
  void initState() {
    super.initState();
    fetchChallanDetailItem();
    fetchChallanStatus();

  }

  Future<void> fetchChallanStatus() async{
    setState(() {
      isLoading = true;
    });

    List<ChallanStatusModel>? data = await RestFunction.fetchChallanStatus();
    if (mounted){
      setState(() {
        isLoading = false;
        _statusList = data!;
      });
    }
  }

  Future<void> fetchChallanDetailItem() async {
    setState(() {
      isLoading = true;
    });
    ChallanDetailItemModel? data =
    await RestFunction.fetchChallanDetailItem(widget.challanId);
    print("Challan Detail Item Count: ${data?.items.length}");
    if (mounted) {
      setState(() {
        isLoading = false;
        _challanDetailItem = data;
        // Clear previous dataRows and controllers
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          width: 120,
          child: Text("View Challan",
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true, // This is default
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailScreen(projectId: widget.challanData?.projectId ?? 0),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Project: ", // Static text
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: widget.challanData?.projectName ?? "", // Dynamic text
                            style: const TextStyle(
                              fontSize: 15, // Larger font size for project name
                              fontWeight: FontWeight.w500,
                              color: AppColor.colorPrimary, // Different color for project name
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Quality In Charge: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: widget.challanData?.inChargeName ?? "", // Dynamic text
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
                          text: "Status: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // Check if the current status matches any status in the _statusList
                        TextSpan(
                          text: _statusList.any((status) =>
                          status.value == widget.challanData?.status) == true
                              ? _statusList.firstWhere(
                                  (status) => status.value == widget.challanData?.status,
                              orElse: () => ChallanStatusModel(name: "N/A"))
                              .name
                              : "Status not found", // Fallback text if status is not found
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
                          text: "Tracking No: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: widget.challanData?.trackingNo ?? "", // Use status directly
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
                          text: "Vehicle No: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: widget.challanData?.vechileNo ?? "", // Dynamic text
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
                          text: "Document Date: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: DateFormat('yyyy-MM-dd').format(
                              DateTime.parse(widget.challanData?.documentDate)), // Dynamic text
                          style: const TextStyle(
                            fontSize: 14, // Larger font size for project name
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
                          text: "Supplier Name: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: widget.challanData?.supplierName ?? "", // Dynamic text
                          style: const TextStyle(
                            fontSize: 14, // Larger font size for project name
                            fontWeight: FontWeight.w500,
                            color: AppColor.colorPrimary, // Different color for project name
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Remarks: ", // Static text
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "", // Use status directly
                          style: TextStyle(
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
              const SizedBox(height: 40,),
              const Text(
                "Item List",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20,),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                shrinkWrap: true, // Helps avoid infinite height issues
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (_challanDetailItem?.items.length ?? 0),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "itemName",
                                  isEnabled: false,
                                  label:  _challanDetailItem!.items[index].name ?? "",
                                  controller: getController(index, "itemName"),
                                  onChanged: (String ) { },
                                ),
                              )),
                          const SizedBox(width: 10),
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "quantity",
                                  isEnabled: false,
                                  label:  _challanDetailItem!.items[index].quantity ?? "",
                                  controller: getController(index, "quantity"),
                                  onChanged: (String ) { },
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "price",
                                  isEnabled: false,
                                  label:  _challanDetailItem!.items[index].price ?? "",
                                  controller: getController(index, "price"),
                                  onChanged: (String ) { },
                                ),
                              )),
                          const SizedBox(width: 10),
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "uomName",
                                  isEnabled: false,
                                  label:  _challanDetailItem!.items[index].uomName ?? "",
                                  controller: getController(index, "uomName"),
                                  onChanged: (String ) { },
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "receiverStatus",
                                  isEnabled: false,
                                  label:  _challanDetailItem!.items[index].receiverStatus ?? "",
                                  controller: getController(index, "receiverStatus"),
                                  onChanged: (String ) { },
                                ),
                              )),
                          const SizedBox(width: 10),
                          Expanded(
                              child: SizedBox(
                                height: 45,
                                child: FormFieldItem(
                                  index: index,
                                  fieldKey: "receiverRemarks",
                                  isEnabled: false,
                                  label:  _challanDetailItem!.items[index].receiverRemarks ?? "",
                                  controller: getController(index, "receiverRemarks"),
                                  onChanged: (String ) { },
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 30,),
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

}
