import 'package:flutter/material.dart';
import 'package:reddit/core/common/login_button.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/theme/pallete.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(Constants.logoPath, height: 40),
            SizedBox(width: 10),
            Text('Reddit...'),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 16,
                color: Pallete.blueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Dive into anything',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.5,
              ),
            ),
            SizedBox(height: 20),
            Image.asset(Constants.loginEmotePath, height: 400),
            SizedBox(height: 20),
            LoginButton(),
          ],
        ),
      ),
    );
  }
}
