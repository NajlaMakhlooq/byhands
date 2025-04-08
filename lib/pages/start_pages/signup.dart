import 'dart:io';

import 'package:byhands_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:byhands_application/services/auth_service.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // get auth service
  final authService = AuthService();
  //text controllers
  final _formfield = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final _BioController = TextEditingController();
  final confirmPassController = TextEditingController();
  final _usernameController = TextEditingController();
  final _DateController = TextEditingController();
  String? _selectedgender;
  final List<String> _genderItems = ['Male', 'Female'];
  String url_profile = "";
  File? _imageFile;

//pick image
  Future pickimage() async {
    final ImagePicker picker = ImagePicker();
    //pick from gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    //update image preview
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        url_profile = image.path;
      });
    }
  }

  Future<void> signUpData() async {
    try {
      await Supabase.instance.client.from('User').insert({
        'Username': usernameController.text,
        'Email': emailController.text,
        'Password': passController.text,
        'Bio': _BioController.text,
        'gender': _selectedgender,
        'dateOfBirth': _DateController.text,
      });
      print("Data inserted successfully");
    } catch (e) {
      print("Error inserting data: $e");
    }
  }

  void signUp() async {
    //prepare data
    final email = emailController.text;
    final password = passController.text;
    // attempt sign up..
    try {
      await authService.signUpWithEmailAndPassword(email, password);
      // pop this register page
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ));
      }
    }
  }

  //Upload
  Future uploadImage() async {
    if (_imageFile == null) return;
    //generate a unique filr path
    final path =
        'images/profiles/${usernameController.text}/${usernameController.text}profile';
    //upload the image to supabase storage
    await Supabase.instance.client.storage
        .from('images') // to this bucket
        .upload(path, _imageFile!);
  }

  bool passToggle = true;
  bool confirmPassToggle = true;

  Future<bool> checkUsernameExists(String username) async {
    final response = await Supabase.instance.client
        .from('User')
        .select()
        .eq('Username', username)
        .maybeSingle();

    if (response != null) {
      return true; // Username exists
    } else {
      return false; // Username does not exist
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    _BioController.dispose();
    _usernameController.dispose();
    _DateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        shadowColor: Color.fromARGB(255, 54, 43, 75),
        title: Text(
          "Sign up",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  Text(
                    "Create your new account!",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Form(
                key: _formfield,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            foregroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : AssetImage('assets/logo.png')
                                    as ImageProvider,
// Use FileImage for images from files
                          ),
                          InkWell(
                            onTap: () {
                              pickimage();
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Color.fromARGB(205, 54, 43, 75),
                              child: Icon(Icons.edit,
                                  size: 15, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: TextFormField(
                        controller: usernameController,
                        decoration:
                            textInputdecoration(context, "Username").copyWith(
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        decoration:
                            textInputdecoration(context, "Email").copyWith(
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}',
                              ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: TextFormField(
                        controller: passController,
                        obscureText: passToggle,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
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
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
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
                    SizedBox(height: 15),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: TextFormField(
                        controller: confirmPassController,
                        obscureText: confirmPassToggle,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              confirmPassToggle
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                confirmPassToggle = !confirmPassToggle;
                              });
                            },
                          ),
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != passController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: TextFormField(
                        controller: _BioController,
                        decoration:
                            textInputdecoration(context, "Bio").copyWith(
                          prefixIcon: Icon(Icons.note),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your bio';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: InputDecorator(
                        decoration:
                            textInputdecoration(context, "Gender").copyWith(
                          prefixIcon: Icon(Icons.person_3),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedgender,
                            hint: Text(
                              'Select a gender',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            items: _genderItems.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedgender = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: TextFormField(
                        controller: _DateController,
                        readOnly: true,
                        decoration:
                            textInputdecoration(context, "Date").copyWith(
                          prefixIcon: Icon(Icons.date_range),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _DateController.text =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        padding: EdgeInsets.only(top: 2, left: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.black),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            //check username
                            bool usernameExists = await checkUsernameExists(
                                usernameController.text);
                            if (usernameExists) {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Username already exists')),
                              );
                              return;
                            }
                            // sign in button
                            if (_formfield.currentState!.validate()) {
                              print("signup tp $emailController");
                              signUpData();
                              signUp();
                              uploadImage();
                              Navigator.popAndPushNamed(context, '/Home');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color.fromARGB(255, 54, 43, 75),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ), // Text color
                          ),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.popAndPushNamed(context, '/login');
                          },
                          child: Text(
                            " Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color.fromARGB(255, 54, 43, 75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
