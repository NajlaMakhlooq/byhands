import 'dart:io';
import 'package:byhands/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;

  const ImagePreviewScreen({super.key, required this.imageFile});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final SupabaseClient supabase = Supabase.instance.client; // open the database
  final _formfield = GlobalKey<FormState>();
  String username = "";
  final content_text = TextEditingController();
  final Post_name = TextEditingController();
  String Post_url = '';
  String? categorySelctor;
  List<Map<String, dynamic>> allCategories = [];
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    fetchUsername();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('categories').select();

      setState(() {
        setState(() {
          allCategories =
              (response as List<dynamic>?)
                  ?.map((e) => {'Name': e['Name'] ?? 'Unknown'})
                  .toList() ??
              [];
          categories =
              allCategories
                  .map((category) => category['Name'] as String)
                  .toList();
        });
      });
    } catch (error) {
      print('❌ Error fetching categories : $error');
    }
  }

  //Upload
  Future uploadImage() async {
    //generate a unique filr path
    final path = 'images/posts/$username/${Post_name.text}';
    setState(() {
      Post_url = path;
    });

    //upload the image to supabase storage
    await Supabase.instance.client.storage
        .from('images') // to this bucket
        .upload(path, widget.imageFile);
  }

  Future<void> insertData() async {
    try {
      await Supabase.instance.client.from('Post').insert({
        'Content_Text': content_text.text,
        'category': categorySelctor,
        'Name': Post_name.text,
        'username': username,
        'Post_url': Post_url,
      });
    } catch (e) {
      print("❌🗂️ Error inserting data: $e");
    }
  }

  Future<void> fetchUsername() async {
    final session = supabase.auth.currentSession;
    final user = session?.user;
    final email = user?.email;

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

  @override
  void dispose() {
    Post_name.dispose();
    content_text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        shadowColor: Color.fromARGB(255, 54, 43, 75),
        title: Text(
          "Add new Post",
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
      body: Column(
        children: [
          SizedBox(height: 30),
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.80,
            height: MediaQuery.sizeOf(context).height * 0.25,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                10.0,
              ), // Same as border radius
              child: Image.file(widget.imageFile),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Retake',
                      style: TextStyle(color: Color.fromARGB(255, 54, 43, 75)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Form(
                key: _formfield,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: TextFormField(
                        controller: Post_name,
                        decoration: textInputdecoration(
                          context,
                          "Name",
                        ).copyWith(prefixIcon: Icon(Icons.title_rounded)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter post name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
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
                    SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: content_text,
                        decoration: textInputdecoration(
                          context,
                          "Content",
                        ).copyWith(prefixIcon: Icon(Icons.description)),
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        decoration: customContainerDecoration(context),
                        child: ElevatedButton(
                          onPressed: () async {
                            // sign in button
                            if (_formfield.currentState!.validate()) {
                              uploadImage();
                              insertData();
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
                            "Add Post",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
