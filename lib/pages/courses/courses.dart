import 'package:byhands/pages/menus/mainmenu.dart';
import 'package:byhands/theme.dart';
import 'package:flutter/material.dart';
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:byhands/pages/courses/Course_details.dart';

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> allCourses = [];
  List<Map<String, dynamic>> displayedCourses = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      final response = await supabase.from('Courses').select();
      setState(() {
        allCourses =
            (response as List<dynamic>?)
                ?.map(
                  (e) => {
                    'Name': e['Name'] ?? 'Unknown', // Handle null values
                    'Description':
                        e['Description'] ?? 'No description available',
                  },
                )
                .toList() ??
            [];

        displayedCourses = allCourses;
      });
    } catch (error) {
      print('Error fetching Courses: $error');
    }
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      displayedCourses =
          allCourses
              .where(
                (course) => course['Name'].toString().toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text("Courses", style: Theme.of(context).textTheme.titleLarge),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add_course');
            },
            child: Text(
              "+ new course",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
      body: Column(
        children: [
          SizedBox(
            height: 40,
            width: 340,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextField(
                onChanged: updateSearchQuery,
                decoration: InputDecoration(
                  labelText: 'Search Courses',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child:
                displayedCourses.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: displayedCourses.length,
                      itemBuilder: (context, index) {
                        final course = displayedCourses[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Container(
                            decoration: customContainerDecoration(context),
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
                                vertical: 2,
                              ),
                              title: Row(
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
                                        ), //desired border color
                                        width: 2, // Set the width of the border
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        216,
                                        222,
                                        236,
                                      ),
                                      backgroundImage: NetworkImage(
                                        supabase.storage
                                            .from('images')
                                            .getPublicUrl(
                                              'courses/${course['Name']}',
                                            ),
                                      ),
                                      onBackgroundImageError: (
                                        error,
                                        stackTrace,
                                      ) {
                                        print('Error loading image: $error');
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    course['Name'] ?? 'Unknown Course',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: mainMenu(3),
    );
  }
}
