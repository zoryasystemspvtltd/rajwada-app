
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rajwada_app/core/functions/auth_function.dart';
import 'package:rajwada_app/core/model/login_data_model.dart';
import 'package:rajwada_app/ui/helper/app_colors.dart';
import 'package:rajwada_app/ui/helper/assets_path.dart';
import 'package:rajwada_app/ui/screen/add_challan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/functions/functions.dart';
import '../../core/model/challan_list.dart';
import '../../core/model/user_privilege_model.dart';
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
  List<ChallanItem> challanListData = [];
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  bool hasMoreData = true;
  UserPrivilegeModel? userPrivilege;
  String userRole = "";
  final TextEditingController searchController = TextEditingController();
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchChallanData(currentPage);
    loadUserPrivileges();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("Received data:");
    fetchChallanData(currentPage);
    loadUserPrivileges();
  }

  // Method to load user privileges from SharedPreferences
  Future<void> loadUserPrivileges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userPrivilegeJson = prefs.getString('userPrivileges');

    if (userPrivilegeJson != null) {
      Map<String, dynamic> jsonMap = jsonDecode(userPrivilegeJson);
      userPrivilege = UserPrivilegeModel.fromJson(jsonMap);
    }

    printRoles(); // Call printRoles() after loading data
  }

  // Method to print roles
  void printRoles() {
    if (userPrivilege != null && userPrivilege!.roles != null) {
      userRole = userPrivilege!.roles!.join(', ');
      print("User Roles: $userRole");
    } else {
      print("No roles found.");
    }
  }

  Future<void> fetchChallanData(int pageNumber) async {
    print("Called after pop Back");
    if (isLoading || !hasMoreData) return; // ✅ Prevent unnecessary

    setState(() {
      isLoading = true;
    });

    ChallanListModel? response = await RestFunction.fetchChallanList(
      pageNumber,
      15,
    );

    if (kDebugMode) {
      print("Page Number: $pageNumber");
    }

    if (mounted) {
      setState(() {
        isLoading = false; // ✅ Ensure this always resets
        if (response?.items.isNotEmpty ?? false) {
          challanListData.addAll(response!.items);
          currentPage++; // ✅ Only increment if new data exists
        } else {
          hasMoreData = false; // ✅ Stop further API calls if no new data
        }
      });
    }
  }

  Future<void> fetchSearchList(int pageNumber , String keyword) async {
    if (isLoading) return; // ✅ Prevent duplicate API calls

    setState(() {
      isLoading = true;
    });

    ChallanListModel? response = await RestFunction.fetchSearchList(
      currentPage,
      15,
      keyword
    );

    if (kDebugMode) {
      print("Page Number: $pageNumber");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
        if (response?.items.isNotEmpty ?? false) {
          challanListData.addAll(response!.items);
          currentPage++; // ✅ Increment page number only if new data is available
        }
      });
    }
  }

  // Future<void> fetchChallanData(int pageNumber) async {
  //   if (isLoading) return; // ✅ Prevent duplicate API calls
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   ChallanListModel? response = await RestFunction.fetchChallanList(
  //     currentPage: pageNumber,
  //     recordPerPage: 15,
  //   );
  //
  //   if (kDebugMode) {
  //     print("Page Number: $pageNumber");
  //   }
  //
  //   if (mounted) {
  //     setState(() {
  //       isLoading = false;
  //       challanListData.addAll(response?.items ?? []);
  //       currentPage++; // Increment page number
  //     });
  //   }
  // }

  void _toggleSearch() {
    setState(() {
      isExpanded = !isExpanded;
      if (!isExpanded) {
        searchController.clear(); // Clear text when closing
      }
    });
  }

  void _onSearchChanged(String value) {
    if (value.length > 3) {
      // Implement your search logic here
      print("Searching for: $value");
      challanListData = [];
      currentPage = 1;
      fetchSearchList(currentPage, value);
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
                        } else if (menuItems[index]["title"] == "Activity Reporting") {
                          Navigator.pushNamed(context, '/activity');
                        } else if (menuItems[index]["title"] == "Home") {
                          Navigator.pushNamed(context, '/dashboard');
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
                Visibility(
                  visible: userRole == "Receiver",
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChallanEntryScreen(isEdit: false, challanId: 0),
                        ),
                      );

                      if (result != null) {
                        print("result not Nil");
                        fetchChallanData(1);
                      } else {
                        print("result Nil");
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text(
                      "Add New",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: isExpanded ? 180 : 0, // Expand width on tap
                      curve: Curves.easeInOut,
                      child: isExpanded
                          ? TextField(
                        controller: searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          prefixIcon: Icon(Icons.search),
                          hintText: "Search",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      )
                          : null, // Hide text field when collapsed
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _toggleSearch,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          isLoading && challanListData.isEmpty
              ? const Center(child: CircularProgressIndicator()) // ✅ Show only if loading and no data
              : challanListData.isEmpty
              ? const Center(child: Text("No data available")) // ✅ Show when data is empty
              : ChallanTable(
            challanItems: challanListData, // ✅ Pass fetched data
            fetchChallanData: fetchChallanData, // ✅ Pass API function for pagination
            controllScroll: _scrollController,
            userRole: userRole,
            currentPage: currentPage, // ✅ Pass currentPage value
          ),

          // isLoading
          //     ? const Center(child: CircularProgressIndicator()) // ✅ Show loader while fetching
          //     : challanListData.isEmpty
          //     ? const Center(child: Text("No data available")) // ✅ Show this only when API returns empty data
          //     : ChallanTable(challanItems: challanListData, controllScroll: _scrollController, userRole: userRole) // ✅ Show data when available
        ],
      ),
    );
  }
}


