import 'package:byhands/services/auth/auth_service.dart';
import 'package:byhands/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:byhands/pages/start_pages/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final authService = AuthService();
  final _formfield = GlobalKey<FormState>();
  late final emailController = TextEditingController();
  final passController = TextEditingController();
  bool passToggle = true;

  void login() async {
    //prepare the data
    final email = emailController.text.trim();
    final pw = passController.text.trim();
    //attempt login
    try {
      await authService.signInWithEmailAndPassword(
        "byhandsapplication@gmail.com",
        "ByhandsapplicationDatabase_2025",
      );
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pw);
      print("✅🔐 Logged in as ${userCredential.user?.email}");
      Navigator.pushNamed(context, '/Home');
    }
    // catch any error
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Error: $e",
              style: Theme.of(context).textTheme.labelSmall,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "🔄 check your email and password again",
              style: Theme.of(context).textTheme.labelSmall,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 15),
                  Column(
                    children: <Widget>[
                      Text(
                        "Login",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Login to your account",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Form(
                    key: _formfield,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            style: Theme.of(context).textTheme.labelMedium,
                            controller: emailController,
                            decoration: textInputdecoration(
                              context,
                              "Email",
                            ).copyWith(prefixIcon: Icon(Icons.email)),
                            validator: (value) {
                              if (value!.isEmpty ||
                                  !RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                                  ).hasMatch(value)) {
                                return "Enter correct email";
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 15),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextFormField(
                            style: Theme.of(context).textTheme.labelMedium,
                            controller: passController,
                            obscureText: passToggle,
                            decoration: textInputdecoration(
                              context,
                              "Password",
                            ).copyWith(
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  passToggle
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    passToggle = !passToggle;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formfield.currentState!.validate()) {
                          login();
                        }
                      },
                      style: CustomElevatedButtonTheme(context),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot_password');
                    },
                    child: Text(
                      "Forgot Password?",
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Don't have an account?",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Signup()),
                          );
                        },
                        child: Text(
                          " Sign up",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
