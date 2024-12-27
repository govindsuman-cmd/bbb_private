import 'package:bbb_mobile_app/Provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/CustomWidget/background_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Authentication/forget_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  Map<String, dynamic> userInfo = {};

  Future<void> _login() async {
    final String userid = _userIdController.text.trim();
    final String password = _passwordController.text.trim();

    if (userid.isEmpty || password.isEmpty) {
      _showErrorMessage("Please fill in both fields.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Obtain bearer token
      final tokenResponse = await http.post(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/oauth/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept-Charset': 'utf-8',
        },
        body: {
          'grant_type': "client_credentials",
          'client_id': 'a47c93f6-1a30-4edb-8ad1-9cfc6b640aa4',
          'client_secret': 'a7bae359-b418-4952-8315-dfba81a2ee5b',
        },
      );

      if (tokenResponse.statusCode != 200) {
        _showErrorMessage("Failed to obtain bearer token.");
        return;
      }

      final tokenBody = json.decode(tokenResponse.body);
      final String bearerToken = tokenBody['access_token'];

      // Step 2: Validate User Credentials
      final validationResponse = await http.post(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/auth/password/validation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: json.encode({'userid': userid, 'password': password}),
      );

      if (validationResponse.statusCode != 201) {
        _showErrorMessage("Invalid User ID or Password.");
        return;
      }

      final validationBody = json.decode(validationResponse.body);
      final int patronId = validationBody['patron_id'];

      // Step 3: Fetch User Information
      final userInfoResponse = await http.get(
        Uri.parse('https://demo.bestbookbuddies.com/api/v1/patrons/$patronId'),
        headers: {'Authorization': 'Bearer $bearerToken'},
      );

      if (userInfoResponse.statusCode != 200) {
        _showErrorMessage("Failed to fetch user information.");
        return;
      }

      final userInfo = json.decode(userInfoResponse.body);

      // Step 4: Save Token and User Info Locally

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', bearerToken);
      await prefs.setInt('patron_id', patronId);
      await prefs.setString('user_info', json.encode(userInfo));


      // Debugging logs
      print('Patron ID: $patronId');
      print('User Info: $userInfo');
      print('Token: $bearerToken');

      final userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
      userInfoProvider.setUserInfo(userInfo);
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: userInfo, // Pass userInfo to next screen
      );

    } catch (e) {
      _showErrorMessage("Something went wrong. Please try again. $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showForgetPasswordDropUp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ForgetPasswordDropUp(
        onSubmit: (email, mobile) {
          print('Email: $email, Mobile: $mobile');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BackgroundWidget(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 150),
                const Center(
                  child: Image(image: AssetImage('assets/bbb_logo.png')),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    labelText: 'User ID',
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
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
                  ),
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgetPasswordDropUp,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Remember Me Checkbox
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text('Remember Me'),
                  ],
                ),
                const SizedBox(height: 20),

                // Login Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 19),
                    backgroundColor: const Color(0xFF009A90),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 20),

                // Guest Login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/home',
                      arguments: userInfo,
                    );
                  },
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 10),

                // Registration Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
