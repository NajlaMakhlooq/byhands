import 'dart:io';
import 'package:byhands/services/auth/auth_service.dart';
import 'package:byhands/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;
import 'package:path_provider/path_provider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final authService = AuthService();
  final _formfield = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final _BioController = TextEditingController();
  final confirmPassController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedgender;
  final List<String> _genderItems = ['Male', 'Female'];
  File? _imageFile;
  final prefix.SupabaseClient supabase =
      prefix.Supabase.instance.client; // open the database
  bool passToggle = true;
  bool confirmPassToggle = true;

  // Pick image function
  Future pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // Check if username exists in Firestore
  Future<bool> checkUsernameExists(String username) async {
    final response =
        await supabase
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

  // Sign up function to create user and save to Firestore
  Future<void> signUp() async {
    final email = emailController.text;
    final password = passController.text;

    try {
      await authService.signInWithEmailAndPassword(
        "byhandsapplication@gmail.com",
        "ByhandsapplicationDatabase_2025",
      );
      // 1. Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      //await authService.signUpWithEmailAndPassword(email, password);
      String uid = userCredential.user?.uid ?? 'No UID found';

      // 2. Add user data to database after successful registration
      try {
        await supabase.from('User').insert({
          'Username': usernameController.text,
          'Email': emailController.text,
          'Bio': _BioController.text,
          'gender': _selectedgender,
          'dateOfBirth': _ageController.text,
        });
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(usernameController.text)
            .set({
              'username': usernameController.text,
              'email': email,
              'uid': uid,
            });
      } catch (e) {
        print("❌🗂️ Error inserting data: $e");
      }
      User? user = userCredential.user;
      await sendEmailVerification(user!);
      // Navigate to home page after successful sign-up
      print("✅🎉 Account created successfully 🎉✅");
      checkUserVerification(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  void checkUserVerification(BuildContext context) async {
    bool isVerified = await isEmailVerified();

    if (!isVerified) {
      // Show alert or disable access to the app
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please verify your email before proceeding.')),
      );

      // Sign out the user until they verify their email
      FirebaseAuth.instance.signOut();
      Navigator.popAndPushNamed(context, '/login');
    } else {
      // Allow user to proceed in the app
      Navigator.popAndPushNamed(context, '/Home');
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;

    // Check if the email is verified
    if (user != null && user.emailVerified) {
      print("✅ Email is verified");
      return true;
    } else {
      print("❌ Email not verified");
      return false;
    }
  }

  Future<void> resendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
      print("✅ Verification email resent.");
    } on FirebaseAuthException catch (e) {
      print("❌ Error resending email: ${e.message}");
    }
  }

  Future<void> sendEmailVerification(User user) async {
    try {
      // Send email verification
      await user.sendEmailVerification();
      print("✅ Email verification sent to ${user.email}");
    } on FirebaseAuthException catch (e) {
      print("❌ Error sending verification email: ${e.message}");
    }
  }

  // Upload profile image to Firebase Storage
  Future<void> uploadImage(String username, String gender) async {
    final path = 'images/profiles/$username/${username}profile';
    if (_imageFile == null) {
      // 1. Load image from assets as bytes
      ByteData byteData = await rootBundle.load('assets/${gender}Profile.jpg');
      Uint8List imageBytes = byteData.buffer.asUint8List();

      // 2. Save bytes to a temporary file
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/my_temp_image.jpg';
      File tempFile = File(tempPath);
      await tempFile.writeAsBytes(imageBytes);
      try {
        //generate a unique file path
        await supabase.storage.from('images').uploadBinary(path, imageBytes);
      } catch (e) {
        print("📛 Error uploading image: $e");
      }
    } else {
      try {
        //generate a unique file path
        await supabase.storage.from('images').upload(path, _imageFile!);
      } catch (e) {
        print("📛 Error uploading image: $e");
      }
    }
    try {
      //generate a unique file path
      await supabase.storage.from('images').upload(path, _imageFile!);
    } catch (e) {
      print("📛 Error uploading image: $e");
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    _BioController.dispose();
    _ageController.dispose();
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
        title: Text("Sign up", style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(255, 135, 128, 139)
                    : const Color.fromARGB(255, 203, 194, 205),
          ),
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
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              Form(
                key: _formfield,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 15),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color.fromARGB(
                                  255,
                                  216,
                                  222,
                                  236,
                                ), // desired border color
                                width: 2, // Set the width of the border
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: const Color.fromARGB(
                                255,
                                216,
                                222,
                                236,
                              ),
                              backgroundImage: AssetImage('assets/logo.png'),
                              foregroundImage:
                                  _imageFile != null
                                      ? FileImage(_imageFile!)
                                      : AssetImage('assets/logo.png')
                                          as ImageProvider,
                              onBackgroundImageError: (error, stackTrace) {
                                print('📛 Error uploading image: $error');
                              },
                            ),
                          ),
                          InkWell(
                            onTap: pickImage,
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Color.fromARGB(205, 54, 43, 75),
                              child: Icon(
                                Icons.edit,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    // Username Input
                    _buildTextFormField(
                      controller: usernameController,
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      decoration: textInputdecoration(context, "Username"),
                    ),
                    SizedBox(height: 15),
                    // Email Input
                    _buildTextFormField(
                      decoration: textInputdecoration(context, "Email"),
                      controller: emailController,
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
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
                    SizedBox(height: 15),
                    // Password Input
                    _buildTextFormField(
                      decoration: textInputdecoration(context, "Password"),
                      controller: passController,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: passToggle,
                      suffixIcon: IconButton(
                        icon: Icon(
                          passToggle ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            passToggle = !passToggle;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    // Confirm Password Input
                    _buildTextFormField(
                      decoration: textInputdecoration(
                        context,
                        "Confirm Password",
                      ),
                      controller: confirmPassController,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: confirmPassToggle,
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
                    SizedBox(height: 15),
                    // Bio Input
                    _buildTextFormField(
                      decoration: textInputdecoration(context, "Bio"),
                      controller: _BioController,
                      prefixIcon: Icons.note,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your bio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    // Gender Dropdown
                    _buildGenderDropdown(),
                    SizedBox(height: 15),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: TextFormField(
                        controller: _ageController,
                        readOnly: true,
                        decoration: textInputdecoration(
                          context,
                          "Date",
                        ).copyWith(prefixIcon: Icon(Icons.date_range)),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _ageController.text = DateFormat(
                                'yyyy-MM-dd',
                              ).format(pickedDate);
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    // Sign Up Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton(
                        onPressed: () async {
                          bool usernameExists = await checkUsernameExists(
                            usernameController.text,
                          );
                          if (usernameExists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '⚠️ Username already exists',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            );
                            return;
                          }

                          if (_formfield.currentState!.validate()) {
                            uploadImage(
                              usernameController.text,
                              _selectedgender.toString(),
                            );
                            await signUp();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 54, 43, 75),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text form fields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required IconData prefixIcon,
    required InputDecoration decoration,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.06,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: decoration.copyWith(prefixIcon: Icon(prefixIcon)),
        validator: validator,
      ),
    );
  }

  // Helper method to build gender dropdown
  Widget _buildGenderDropdown() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.08,
      child: InputDecorator(
        decoration: textInputdecoration(
          context,
          "Gender",
        ).copyWith(prefixIcon: Icon(Icons.date_range)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedgender,
            hint: Text(
              'Select a gender',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            style: Theme.of(context).textTheme.labelSmall,
            items:
                _genderItems.map((String item) {
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
    );
  }
}
