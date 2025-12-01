import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/login_button.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/theme/pallete.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
 

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
