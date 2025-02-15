
import 'package:flutter/material.dart';
import 'package:rajwada_app/core/functions/auth_function.dart';
import 'package:rajwada_app/core/model/login_data_model.dart';
import 'package:rajwada_app/ui/helper/app_colors.dart';
import 'package:rajwada_app/ui/helper/assets_path.dart';
import 'package:rajwada_app/ui/screen/add_challan.dart';
import '../../core/functions/functions.dart';
import '../../core/model/challan_list.dart';
import '../widget/challan_table.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Home", "icon": Icons.home},
    {"title": "Profile", "icon": Icons.person},
    {"title": "Settings", "icon": Icons.settings},
    {"title": "Activity Reporting", "icon": Icons.pie_chart},
    {"title": "Logout", "icon": Icons.logout},
  ];

  final AuthService authService = AuthService(); // Initialize AuthService
  final RestFunction restService = RestFunction();
  bool isLoading = false;
  final LoginDataModel loginModel = LoginDataModel();

  ChallanListModel? challanData;
  List<ChallanItem?> challanListData = [];
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    fetchChallanData(currentPage);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !isLoading) {
        fetchChallanData(currentPage); // ✅ Load next page when reaching bottom
      }
    });
  }


  // Future<void> fetchChallanData(int currentPage) async {
  //   if (isLoading || !hasMoreData) return; // Prevent duplicate calls
  //
  //   isLoading = true;
  //
  //   ChallanListModel? response = await RestFunction.fetchChallanList(
  //     currentPage: currentPage,
  //     recordPerPage: 15,
  //   );
  //
  //   if (response != null) {
  //     if (response.items.isNotEmpty) {
  //       challanListData.addAll(response.items);
  //       currentPage++; // Increment page number
  //     } else {
  //       hasMoreData = false; // No more data available
  //     }
  //   }
  //
  //   isLoading = false;
  // }

  Future<void> fetchChallanData(int pageNumber) async {
    if (isLoading) return; // ✅ Prevent duplicate API calls

    setState(() {
      isLoading = true;
    });

    ChallanListModel? response = await RestFunction.fetchChallanList(
      currentPage: pageNumber,
      recordPerPage: 15,
    );

    if (mounted) {
      setState(() {
        isLoading = false;
        challanListData.addAll(response?.items ?? []);
        currentPage++; // Increment page number
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: 120,
          height: 45,
          decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage(AssetsPath.drawerLogo),
              fit: BoxFit.fill,
            ),
          ),
        ),
        backgroundColor: AppColor.colorPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          color: AppColor.colorPrimary, // Background color
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.white, // Change image color to white
                        BlendMode
                            .srcATop, // Blend mode to apply color over image
                      ),
                      child: Container(
                        width: 220,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: const DecorationImage(
                            image: AssetImage(AssetsPath.currentAppLogo),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(
                          menuItems[index]['icon'], color: Colors.white),
                      title: Text(
                        menuItems[index]['title'],
                        style: const TextStyle(color: Colors.white,
                            fontSize: 16),
                      ),
                      onTap: () {
                        // Handle navigation
                        Navigator.pop(context);
                        if (menuItems[index]["title"] == "Logout") {
                          authService.logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                'Navigating to ${menuItems[index]["title"]}')),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar and Add New button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to dashboard if login is successful
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChallanEntryScreen(isEdit: false, challanId: 0),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                      "Add New", style: TextStyle(color: Colors.white)),
                ),
                const Spacer(),
                // Container(
                //   width: 200,
                //   height: 40,
                //   child: TextField(
                //     controller: _searchController,
                //     decoration: InputDecoration(
                //       contentPadding: EdgeInsets.symmetric(vertical: 10),
                //       prefixIcon: Icon(Icons.search),
                //       hintText: "Search",
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(5),
                //       ),
                //       filled: true,
                //       fillColor: Colors.white,
                //     ),
                //   ),
                // ),
                const SizedBox(width: 10),
                // ElevatedButton(
                //   onPressed: () {
                //     // Implement search logic
                //   },
                //   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                //   child: Text("Search", style: TextStyle(color: Colors.white)),
                // ),
              ],
            ),
          ),

          isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loader
              : challanData != null
              ? const Center(
              child: Text("No data available")) // Handle null case
              : ChallanTable(challanItems: challanListData, controllScroll: _scrollController,), // Pass API data
        ],
      ),
    );
  }
}


