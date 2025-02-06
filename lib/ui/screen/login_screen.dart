import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rajwada_app/ui/helper/app_colors.dart';
import 'dart:async';

import '../../core/functions/auth_function.dart';
import '../../core/model/login_data_model.dart';
import '../../core/model/user_privilege_model.dart';
import '../../core/service/shared_preference.dart';
import '../helper/assets_path.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _isPasswordVisible = false;
  bool _showError = false; // Controls the error message visibility
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService(); // Initialize AuthService

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key
  get http => null;
  LoginDataModel? loginDataModel; // Global or class-level variable to store login data
  bool isLoading = false; // Loader state

  @override
  void initState() {
    super.initState();
    checkLoginStatus(); // Check if user is already logged in
  }

  //MARK: - Check Login Status
  void checkLoginStatus() async {
    bool loggedIn = await authService.isLoggedIn();
    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  //MARK: - Handle Login Module
  void handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Show loader before API call
      });

      String email = emailController.text;
      String password = passwordController.text;

      // Call API from AuthService
      LoginDataModel? loginData = await authService.login(email, password);

      if (loginData != null) {
        if (kDebugMode) {
          print(loginData.accessToken);
          print(loginData.tokenType);
        }

        // Fetch user privileges after login
        UserPrivilegeModel? privileges = await authService.fetchAndStoreUserPrivileges();

        setState(() {
          isLoading = false; // Hide loader after API response
        });

        if (privileges != null) {
          print("User Privileges: ${privileges.roles}");
        }

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Successfully Logged In",
                style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.normal),
              ),
              duration: Duration(seconds: 2),
            )
        );
        // Navigate to dashboard if login is successful
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Show error message if login fails
        setState(() {
          isLoading = false; // Hide loader if login fails
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid email or password.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Email regex pattern
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailPattern).hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey, // Assign form key
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsPath.backGroundImg1),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                height: 500,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 150,
                              height: 100,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(AssetsPath.currentAppLogo),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
          
                          const SizedBox(height: 10),
                          // Subtitle
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "User Login",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Error Message
                          if (_showError)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "your password is incorrect",
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 10),
                          // Email Input
                          TextFormField(
                            controller: emailController,
                            validator: validateEmail,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Password Input
                          TextFormField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            validator: validatePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "••••••••",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Forgot Password and Show Password Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  // Forgot password action
                                },
                                child: const Text(
                                  "Forgot password?",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Login Button
                          // Show loader while logging in
                          isLoading
                              ? const Center(child: CircularProgressIndicator()) // Loader widget
                              : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Login action
                                handleLogin();
                                //Navigator.pushReplacementNamed(
                                    //context, '/dashboard');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.colorPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Login",
                                style:
                                    TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          ),
        )
      ),
    );
  }
}

