import 'package:flutter/material.dart';
import 'package:reddit_clone_provider/core/common/sign_in_button.dart';
import 'package:reddit_clone_provider/core/constants/constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          Constants.logoPath,
          width: 40,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Skip",
              style: TextStyle(color: Constants.blueColor),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Column(
          children: <Widget>[
            const Text(
              "Dive into anything",
              style: TextStyle(
                color: Constants.whiteColor,
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(Constants.loginEmotePath),
            const SizedBox(height: 40),
            const GoogleSignIn()
          ],
        ),
      ),
    );
  }
}
