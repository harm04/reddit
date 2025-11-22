import 'package:flutter/material.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/theme/pallete.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      label: Text('Continue with Google'),
      icon: Image.asset(Constants.googlePath, width: 40),
      style: ElevatedButton.styleFrom(
        backgroundColor: Pallete.greyColor, 
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
