import 'dart:io';
import 'package:byhands/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;
import 'package:image/image.dart' as img; // For cropping functionality

class AddCourse extends StatefulWidget {
  const AddCourse({super.key});

  @override
  State<AddCourse> createState() => _AddCourse();
}

class _AddCourse extends State<AddCourse> {
  final prefix.SupabaseClient supabase =
      prefix.Supabase.instance.client; // open the database
  String username = ""; // course provider username
  final _formfield = GlobalKey<FormState>(); // form of the course details
  final nameController = TextEditingController(); // course name controller
  final descController = TextEditingController(); // description controller
  final priceController = TextEditingController(); // price controller
  final LocationController = TextEditingController(); // location controller
  final _DateController = TextEditingController(); // date picker controller
  String? categorySelctor; // selected category
  List<Map<String, dynamic>> allCategories =
      []; // list of available categories from the database
  List<String> categories = []; // list to display in the form
  String url_pic = ""; // url of the selected picture
  File? _imageFile; // the selected picture for the course
  @override
  void initState() {
    super.initState();
    fetchUsername(); // take the username from the database to be the provider
    fetchCategories(); // take the categories available from the database to the list
  }

  Future<void> fetchCategories() async {
    try {
      final response =
          await supabase
              .from('categories')
              .select(); // select all categories records

      setState(() {
        setState(() {
          allCategories =
              (response as List<dynamic>?) // save the records in the list
                  ?.map((e) => {'Name': e['Name'] ?? 'Unknown'})
                  .toList() ??
              [];
          categories =
              allCategories // convert the list to string list to be displayed
                  .map((category) => category['Name'] as String)
                  .toList();
        });
      });
    } catch (error) {
      print('❌ Error fetching categories : $error');
    }
  }

  //pick image
  Future pickimage() async {
    final ImagePicker picker = ImagePicker(); // open image picker
    //pick from gallery
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    ); // select the image from gallery and save it to the variable
    //update image preview
    if (image != null) {
      setState(() {
        _imageFile = File(image.path); // change the value of the image
        url_pic =
            image
                .path; // change the path of the image to be stored in the database
      });
    }
  }

  //Upload
  Future uploadImage() async {
    if (_imageFile == null) return; // if no image selected
    // Function to crop the image
    final bytes = await _imageFile?.readAsBytes();
    img.Image? decodedImage = img.decodeImage(bytes!);

    if (decodedImage != null) {
      // Crop to square
      int cropSize =
          decodedImage.width > decodedImage.height
              ? decodedImage.height
              : decodedImage.width;

      img.Image croppedImage = img.copyCrop(
        decodedImage,
        x: (decodedImage.width - cropSize) ~/ 2, // Center crop X
        y: (decodedImage.height - cropSize) ~/ 2, // Center crop Y
        width: cropSize,
        height: cropSize,
      );

      // Save cropped image
      final outputFilePath = _imageFile!.path.replaceFirst(
        '.jpg',
        '_cropped.jpg',
      );
      _imageFile = File(outputFilePath);
      await _imageFile?.writeAsBytes(img.encodeJpg(croppedImage));
    }

    //generate a unique filr path
    final path = 'courses/${nameController.text}';
    //upload the image to supabase storage
    await supabase.storage
        .from('images') // to this bucket
        .upload(path, _imageFile!) // in this path put this image
        .then(
          (value) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "✅🗂️ Image upload successfull",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        );
  }

  Future<void> insertData() async {
    try {
      // insert the data in the database if vaild
      await supabase.from('Courses').insert({
        'Name': nameController.text,
        'Description': descController.text,
        'price': priceController.text,
        'location': LocationController.text,
        'Provider': username,
        'CategoryName': categorySelctor,
        'date': _DateController.text,
      });
    } catch (e) {
      print("❌🗂️ Error inserting data: $e");
    }
  }

  Future<void> fetchUsername() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;
    if (email == null) {
      setState(() {
        username = "No user logged in";
      });
      return;
    }

    final response =
        await supabase
            .from('User')
            .select('Username')
            .eq('Email', email)
            .maybeSingle();

    setState(() {
      username = response?['Username'] ?? "Unknown User";
    });
  }

  Future<bool> checkCoursenameExists(String name) async {
    final response =
        await supabase.from('Courses').select().eq('Name', name).maybeSingle();

    if (response != null) {
      return true; // course name exists
    } else {
      return false; // course name does not exist
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    LocationController.dispose();
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
          // title of the page
          "Add new course",
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
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
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _formfield,
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            foregroundImage:
                                _imageFile != null
                                    ? FileImage(
                                      _imageFile!,
                                    ) // the select picutre for the course
                                    : AssetImage(
                                          'assets/logo.png',
                                        ) // initial pic before selecting
                                        as ImageProvider,
                          ),
                          InkWell(
                            onTap: () {
                              pickimage();
                            },
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
                    SizedBox(
                      // name textbox
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: TextFormField(
                        controller: nameController,
                        decoration: textInputdecoration(
                          context,
                          "Name",
                        ).copyWith(prefixIcon: Icon(Icons.title)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter course name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      // description of the course textbox
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: descController,
                        decoration: textInputdecoration(
                          context,
                          "Description",
                        ).copyWith(prefixIcon: Icon(Icons.description)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter course description';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      // price textbox
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: TextFormField(
                        controller: priceController,
                        decoration: textInputdecoration(
                          context,
                          "Price",
                        ).copyWith(prefixIcon: Icon(Icons.attach_money)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the price';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      // category selector
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.09,
                      child: InputDecorator(
                        decoration: textInputdecoration(
                          context,
                          "Category",
                        ).copyWith(prefixIcon: Icon(Icons.category)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: categorySelctor,
                            hint: Text('Select a category'),
                            items:
                                categories.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                categorySelctor = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      // date picker
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: TextFormField(
                        controller: _DateController,
                        readOnly: true,
                        decoration: textInputdecoration(
                          context,
                          "Date",
                        ).copyWith(prefixIcon: Icon(Icons.date_range)),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(), // current date
                            firstDate: DateTime.now(), // current date
                            lastDate: DateTime.now().add(
                              Duration(days: 5 * 365),
                            ), // 5 years from now
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
                    ),
                    SizedBox(height: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: TextFormField(
                        controller: LocationController,
                        decoration: textInputdecoration(
                          context,
                          "Location",
                        ).copyWith(prefixIcon: Icon(Icons.location_pin)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the location';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton(
                        onPressed: () async {
                          //check username
                          bool CoursenameExists = await checkCoursenameExists(
                            nameController.text,
                          );
                          if (CoursenameExists) {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                content: Text(
                                  '⚠️ Course name already exists',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            );
                            return;
                          }
                          // sign in button
                          if (_formfield.currentState!.validate()) {
                            insertData();
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
                          "Add course",
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
}
