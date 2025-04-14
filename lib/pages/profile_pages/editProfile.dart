import 'dart:io';
import 'package:byhands/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Edit extends StatefulWidget {
  final String userName;
  const Edit({super.key, required this.userName});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  String username = "";
  String email = "";
  String password = "";
  String Bio = "";
  String gender = "";
  String dateOfBirth = "";
  String url_profile = "";

  // Text controllers
  final _formfield = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final _BioController = TextEditingController();
  final _DateController = TextEditingController();
  String? _selectedgender;
  final List<String> _genderItems = ['Male', 'Female'];
  final SupabaseClient supabase = Supabase.instance.client; // open the database
  bool passToggle = true;
  bool confirmPassToggle = true;
  bool _isLoading = true; // Loading state for the data fetch
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    _BioController.dispose();
    _DateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchInformation();
  }

  // Fetching user information from Supabase
  Future<void> fetchInformation() async {
    setState(() {
      _isLoading = true; // Set loading to true while fetching data
    });

    try {
      final response =
          await supabase
              .from('User')
              .select()
              .eq('Username', widget.userName)
              .maybeSingle();

      if (response != null) {
        setState(() {
          username = response['Username'] ?? "Unknown User";
          Bio = response['Bio'] ?? "No Bio";
          email = response['Email'] ?? "No Email";
          password = response['Password'] ?? "No password";
          gender = response['gender'] ?? "No gender";
          dateOfBirth = response['dateOfBirth'] ?? "No date";

          // Set the controller values with the fetched data
          usernameController.text = username;
          emailController.text = email;
          _BioController.text = Bio;
          _DateController.text = dateOfBirth;
          _selectedgender = gender;
          _isLoading = false; // Set loading to false after data is fetched
        });
      }
      Future<void> getURL() async {
        // Get the public URL for the specified file
        final response = supabase.storage
            .from('images')
            .getPublicUrl(
              'images/profiles/${widget.userName}/${widget.userName}profile',
            );
        setState(() {
          url_profile = '$response?t=${DateTime.now().millisecondsSinceEpoch}';
        });
      }

      getURL();
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false; // Set loading to false in case of an error
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        print(_selectedImage);
      });
    }
  }

  // Updating user data
  Future<void> upDateData() async {
    try {
      // Proceed with the update operation in Supabase
      final update =
          await Supabase.instance.client
              .from('User')
              .update({
                'Username': usernameController.text,
                'Email': emailController.text,
                'Password': password, // Keep the old password
                'Bio': _BioController.text,
                'gender': _selectedgender,
                'dateOfBirth': _DateController.text,
              })
              .eq('Username', widget.userName)
              .select(); // This returns a PostgrestResponse
      print("update : $update");
      Navigator.pop(context);
      Navigator.popAndPushNamed(context, '/profile');
    } catch (e) {
      // Handle any other errors
      print("Error updating data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Text('Unexpected error: $e'),
        ),
      );
    }
  }

  //Upload
  Future uploadImage() async {
    if (_selectedImage != null) {
      //generate a unique file path
      final path = 'images/profiles/$username/${username}profile';
      //Update the file exists in the storage
      final removedFiles = await Supabase.instance.client.storage
          .from('images')
          .remove([path]);
      // remove is a StorageResponse, not a plain List, so access `.data`
      for (var file in removedFiles) {
        print('Deleted file: ${file.name}');
      }

      final upload = await Supabase.instance.client.storage
          .from('images')
          .upload(path, _selectedImage!);
      print("upload new image : $upload");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          "Edit Profile",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        ),
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(
                      255,
                      135,
                      128,
                      139,
                    ) // Dark mode color
                    : const Color.fromARGB(
                      255,
                      203,
                      194,
                      205,
                    ), // Light mode color
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                padding: EdgeInsets.only(left: 16, top: 25, right: 16),
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: ListView(
                    children: [
                      // Profile image and edit button
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  _selectedImage != null
                                      ? FileImage(_selectedImage!)
                                          as ImageProvider<
                                            Object
                                          > // If user selected an image
                                      : url_profile.isNotEmpty
                                      ? NetworkImage(url_profile)
                                          as ImageProvider<
                                            Object
                                          > // Use url if there's a saved profile
                                      : const AssetImage('assets/logo.png')
                                          as ImageProvider<
                                            Object
                                          >, // Default image if no profile set
                              onBackgroundImageError: (error, stackTrace) {
                                // Handle errors gracefully
                                print('Error loading image: $error');
                              },
                            ),
                            InkWell(
                              onTap: _pickImageFromGallery,
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Color.fromARGB(
                                  205,
                                  54,
                                  43,
                                  75,
                                ),
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
                      SizedBox(height: 35),
                      Form(
                        key: _formfield,
                        child: Column(
                          children: <Widget>[
                            // Username TextField
                            buildTextFormField(
                              usernameController,
                              'Username',
                              Icons.person,
                            ),
                            SizedBox(height: 12),
                            // Email TextField
                            buildTextFormField(
                              emailController,
                              'Email',
                              Icons.email,
                            ),
                            SizedBox(height: 12),
                            // Bio TextField
                            buildTextFormField(
                              _BioController,
                              'Bio',
                              Icons.note,
                            ),
                            SizedBox(height: 12),
                            // Gender Dropdown
                            buildGenderDropdown(),
                            SizedBox(height: 12),
                            // Date of Birth Picker
                            buildDateOfBirthPicker(),
                            SizedBox(height: 20),
                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Cancel Button
                                MaterialButton(
                                  padding: EdgeInsets.symmetric(horizontal: 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "CANCEL",
                                    style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 2.2,
                                    ),
                                  ),
                                ),
                                // Save Button
                                MaterialButton(
                                  onPressed: () async {
                                    // Form validation
                                    if (_formfield.currentState!.validate()) {
                                      await uploadImage();
                                      await upDateData();
                                    }
                                  },
                                  color: Color.fromARGB(255, 54, 43, 75),
                                  padding: EdgeInsets.symmetric(horizontal: 50),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "SAVE",
                                    style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 2.2,
                                      color: Colors.white,
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

  // Helper method for building TextFormField
  Widget buildTextFormField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.07,
      child: TextFormField(
        controller: controller,
        decoration: textInputdecoration(
          context,
          label,
        ).copyWith(prefixIcon: Icon(icon)),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }

  // Gender dropdown builder
  Widget buildGenderDropdown() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.09,
      child: InputDecorator(
        decoration: textInputdecoration(
          context,
          "Gender",
        ).copyWith(prefixIcon: Icon(Icons.person)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedgender,
            hint: Text(gender),
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

  // Date picker builder
  Widget buildDateOfBirthPicker() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.07,
      child: TextFormField(
        controller: _DateController,
        readOnly: true,
        decoration: textInputdecoration(
          context,
          dateOfBirth,
        ).copyWith(prefixIcon: Icon(Icons.today)),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            setState(() {
              _DateController.text = DateFormat(
                'yyyy-MM-dd',
              ).format(pickedDate);
            });
          }
        },
      ),
    );
  }
}
