import 'package:byhands/pages/courses/Course_details.dart';
import 'package:byhands/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;

// ignore: camel_case_types
class Savedcourses extends StatefulWidget {
  const Savedcourses({super.key});

  @override
  State<Savedcourses> createState() => _Savedcourses();
}

class _Savedcourses extends State<Savedcourses> {
  final prefix.SupabaseClient supabase = prefix.Supabase.instance.client;
  int userid = 0;
  List<Map<String, dynamic>> SavedCourses = [];
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
      final User? user = FirebaseAuth.instance.currentUser;
      final String? email = user?.email;

      if (email == null) {
        setState(() {
          userid = 0;
          isLoading = false; // Stop loading if no email found
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

        // Fetch the Saved courses after obtaining UserID
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
      // Fetch Saved course IDs for the user
      final response = await supabase
          .from('Saved_course')
          .select()
          .eq('user_id', userid);

      List<int> SavedCoursesId =
          (response as List<dynamic>?)
              ?.map((e) => e['course_id'] as int)
              .toList() ??
          [];

      // Fetch course details for each Saved course ID
      List<Map<String, dynamic>> fetchedCourses = [];
      for (int courseId in SavedCoursesId) {
        final courseResponse =
            await supabase.from('Courses').select().eq('id', courseId).single();

        fetchedCourses.add(courseResponse);
      }

      setState(() {
        SavedCourses = fetchedCourses; // Update the SavedCourses state
      });
    } catch (error) {
      print('❌ Error fetching courses: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("Saved Courses"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Home');
            },
            icon: const Icon(Icons.home),
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
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
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: CommonDrawer(),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : Column(
                children: [
                  Expanded(
                    child:
                        SavedCourses.isEmpty
                            ? Center(child: Text('No Courses Saved.'))
                            : ListView.builder(
                              itemCount: SavedCourses.length,
                              itemBuilder: (context, index) {
                                final course = SavedCourses[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  child: Container(
                                    decoration: customContainerDecoration(
                                      context,
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        String courseName = course['Name'];
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => CourseDetailPage(
                                                  courseName: courseName,
                                                ),
                                          ),
                                        );
                                      },
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      title: Row(
                                        children: [
                                          Image.network(
                                            supabase.storage
                                                .from('images')
                                                .getPublicUrl(
                                                  'courses/${course['Name']}',
                                                ),
                                            width:
                                                50, // Increased size for visibility
                                            height: 50,
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return CircularProgressIndicator(); // Loading spinner
                                            },
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                              ); // Fallback if image fails to load
                                            },
                                          ),
                                          Text(
                                            course['Name'].toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                255,
                                                54,
                                                43,
                                                75,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onLongPress: () {
                                        final formfield =
                                            GlobalKey<FormState>();
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Unlike course ?"),
                                              content: Form(
                                                key: formfield,
                                                child: SingleChildScrollView(
                                                  child: Text(
                                                    "If you press Ok the course will be deleted from Saved courses.",
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text("Ok"),
                                                  onPressed: () async {
                                                    await supabase
                                                        .from('Saved_course')
                                                        .delete()
                                                        .eq('user_id', userid)
                                                        .eq(
                                                          'course_id',
                                                          course['id'],
                                                        );
                                                    Navigator.of(context).pop();

                                                    Navigator.of(
                                                      context,
                                                    ).pushNamed(
                                                      '/Savedcourses',
                                                    );
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
