import 'package:byhands/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseName;

  const CourseDetailPage({super.key, required this.courseName});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  int userid = 0;
  List<Map<String, dynamic>> CourseDetails = [];
  bool isLoading = true; // To show a loading indicator

  @override
  void initState() {
    super.initState();
    fetchUserID();
  }

  Future<void> fetchUserID() async {
    try {
      setState(() {
        isLoading = true; // Start loading
      });

      // Get the user session and email
      final session = supabase.auth.currentSession;
      final user = session?.user;
      final email = user?.email;

      if (email == null) {
        setState(() {
          userid = 0;
        });
        return;
      }

      // Fetch UserID based on the email
      final response =
          await supabase
              .from('User')
              .select('UserID')
              .eq('Email', email)
              .maybeSingle();

      if (response != null && response.containsKey('UserID')) {
        setState(() {
          userid = response['UserID'];
        });

        // Fetch the liked courses after obtaining UserID
        await fetchCourses();
      } else {
        setState(() {
          userid = 0;
        });
      }
    } catch (error) {
      print("❌ Error fetching UserID: $error");
    } finally {
      setState(() {
        isLoading = false; // Stop loading regardless of success or failure
      });
    }
  }

  Future<void> fetchCourses() async {
    try {
      final response = await supabase
          .from('Courses')
          .select()
          .eq('Name', widget.courseName);

      setState(() {
        CourseDetails =
            (response as List<dynamic>?)
                ?.map(
                  (e) => {
                    'Name': e['Name'] ?? 'Unknown', // Handle null values
                    'Description':
                        e['Description'] ?? 'No description available',
                    'Provider': e['Provider'] ?? 'No Provider',
                    'price': e['price'] ?? 'No price',
                    'location': e['location'] ?? 'Not mentioned',
                    'CategoryName': e['CategoryName'] ?? 'No category',
                  },
                )
                .toList() ??
            [];
      });
    } catch (error) {
      print('❌ Error fetching Courses: $error');
    } finally {
      setState(() {
        isLoading = false; // Stop loading regardless of success or failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (CourseDetails.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(widget.courseName),
        ),
      );
    }

    final course = CourseDetails[0];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(widget.courseName),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  SizedBox(
                    child: Center(
                      child: Text(
                        course['Name'].toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Color.fromARGB(255, 54, 43, 75),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(
                        supabase.storage
                            .from('images')
                            .getPublicUrl('courses/${course['Name']}'),
                      ),
                      backgroundColor: Color.fromARGB(255, 216, 222, 236),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: Container(
                      decoration: customContainerDecoration(context),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Description : ${course['Description'].toString()}",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center, // Align columns to left and right
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .end, // Align text within this column to the left
                        children: [
                          Text(
                            "Category : ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 54, 43, 75),
                            ),
                          ),
                          Text(
                            "Provider : ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 54, 43, 75),
                            ),
                          ),
                          Text(
                            "Price : ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 54, 43, 75),
                            ),
                          ),
                          Text(
                            "Location : ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 54, 43, 75),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start, // Align text within this column to the right
                        children: [
                          Text(
                            course['CategoryName'].toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 54, 43, 75),
                            ),
                          ),
                          Text(
                            course['Provider'].toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 54, 43, 75),
                            ),
                          ),
                          Text(
                            "${course['price'].toString()} BD",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 54, 43, 75),
                            ),
                          ),
                          Text(
                            course['location'].toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 54, 43, 75),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Container(
                          decoration: customContainerDecoration(context),
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Icon(
                                Icons.message,
                                color: Color.fromARGB(255, 54, 43, 75),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Contact provider",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 54, 43, 75),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        color: Color.fromARGB(255, 54, 43, 75),
                        onPressed: () {
                          AddToLikedCourses();
                        },
                        icon: Icon(Icons.favorite),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Future<void> AddToLikedCourses() async {
    try {
      // Fetch course ID based on course name
      final courseResponse =
          await supabase
              .from('Courses')
              .select('id')
              .eq('Name', widget.courseName)
              .maybeSingle();

      if (courseResponse == null) {
        print("❌ No course found with the given name.");
        return;
      }

      int C_id = courseResponse['id'];

      // Check if the same data already exists in 'liked_course'
      final existingEntry =
          await supabase
              .from('liked_course')
              .select('*')
              .eq('user_id', userid)
              .eq('course_id', C_id)
              .maybeSingle();

      if (existingEntry != null) {
        final formfield = GlobalKey<FormState>();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Already Liked"),
              content: Form(
                key: formfield,
                child: SingleChildScrollView(
                  child: Text("This course is already in the liked courses."),
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return; // Exit if the data is already present
      }

      // Insert data into 'liked_course' table
      await Supabase.instance.client.from('liked_course').insert({
        'user_id': userid,
        'course_id': C_id,
      });
    } catch (e) {
      print("❌🗂️ Error inserting data: $e");
    }
  }
}
