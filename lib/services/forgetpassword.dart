import 'package:byhands/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void resetPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password reset email sent!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Email Verification",
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Please enter your Email and we will send you a password reset link.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            SizedBox(height: 20),
            // Email input field
            TextField(
              controller: _emailController,
              decoration: textInputdecoration(context, "Email"),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                resetPassword(context);
              },
              style: CustomElevatedButtonTheme(context),
              child: Text("Send Verification Email"),
            ),
            SizedBox(height: 30),
            Center(
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: customContainerDecoration(context),
                child: Column(
                  children: [
                    TextField(
                      controller: _verificationCodeController,
                      decoration: textInputdecoration(
                        context,
                        "Verification Code",
                      ),
                    ),
                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {},
                      style: CustomElevatedButtonTheme(context),
                      child: Text("Verify Code"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // add a place for the user to input a verification code (for extra security in some cases).
          ],
        ),
      ),
    );
  }
}
