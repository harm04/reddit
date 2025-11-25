import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/theme/pallete.dart';

class LoginButton extends ConsumerWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    
    return isLoading
        ? Loader()
        : ElevatedButton.icon(
            onPressed: () {
              ref.read(authControllerProvider.notifier).login(context: context);
            },
            label: Text('Continue with Google'),
            icon: Image.asset(Constants.googlePath, width: 40),
            style: ElevatedButton.styleFrom(
              backgroundColor: Pallete.greyColor,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
  }
}
