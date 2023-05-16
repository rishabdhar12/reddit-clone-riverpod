import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/core/constants/constants.dart';
import 'package:reddit_clone_provider/features/auth/controllers/auth_controller.dart';
import 'package:reddit_clone_provider/theme/palette.dart';

class GoogleSignIn extends ConsumerWidget {
  const GoogleSignIn({super.key});

  void googleSignIn(WidgetRef ref) {
    ref.watch(authControllerProvider).signInGoogle();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => googleSignIn(ref),
      icon: Image.asset(
        Constants.googlePath,
        height: 50,
      ),
      label: const Text(
        "Signin with Google",
        style: TextStyle(color: Constants.whiteColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Pallete.greyColor,
        minimumSize: const Size(Constants.width / 20, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.borderRadius),
        ),
      ),
    );
  }
}
