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
  bool isEmailSent = false;
  bool isEmailVerified = false;

  // Send verification email to the user
  Future<void> sendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          isEmailSent = true;
        });
        print("✅ Verification email sent to ${user.email}");
      } else {
        print("❌ User is already verified or not logged in.");
        setState(() {
          isEmailSent = false;
        });
      }
    } catch (e) {
      print("❌ Error sending verification email: $e");
      setState(() {
        isEmailSent = false;
      });
    }
  }

  // Check if the email is verified
  Future<void> checkEmailVerification() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.reload();
        setState(() {
          isEmailVerified = user.emailVerified;
        });

        if (user.emailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Your email is successfully verified!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "❌ Your email is not verified yet. Please check your inbox.",
              ),
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error checking email verification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ An error occurred. Please try again.")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    sendVerificationEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Email Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please enter your email to receive a verification link.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Email input field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendVerificationEmail,
              child: Text("Send Verification Email"),
            ),
            if (isEmailSent)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'A verification email has been sent. Please check your inbox.',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            SizedBox(height: 20),
            // Check email verification button
            ElevatedButton(
              onPressed: checkEmailVerification,
              child: Text("Check Email Verification"),
            ),
            if (isEmailVerified)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Your email is verified.',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ),
            if (!isEmailVerified && isEmailSent)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Your email is not verified yet.',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            SizedBox(height: 20),
            // add a place for the user to input a verification code (for extra security in some cases).
            TextField(
              controller: _verificationCodeController,
              decoration: InputDecoration(
                labelText: "Verification Code",
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle code verification here
              },
              child: Text("Verify Code"),
            ),
          ],
        ),
      ),
    );
  }
}
