import 'dart:async';
import 'package:bbb_mobile_app/Provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bbb_mobile_app/splash_screen.dart';
import 'package:bbb_mobile_app/login.dart';
import 'package:bbb_mobile_app/Authentication/create_account.dart';
import 'package:bbb_mobile_app/Authentication/forget_password.dart';
import 'package:bbb_mobile_app/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserInfoProvider()), // Register UserInfoProvider
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(title: 'Login Page'),
          '/home': (context) => const HomeScreen(), // UserInfo is now managed globally
          '/register': (context) => const CreateAccountScreen(),
        },
      ),
    );
  }
}
