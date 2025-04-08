import 'package:byhands_application/menus/mainmenu.dart';
import 'package:byhands_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:byhands_application/menus/side_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:byhands_application/pop_up/Course_details.dart';

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
        allCourses = (response as List<dynamic>?)
                ?.map((e) => {
                      'Name': e['Name'] ?? 'Unknown', // Handle null values
                      'Description':
                          e['Description'] ?? 'No description available'
                    })
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
      displayedCourses = allCourses
          .where((course) => course['Name']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
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
              child: Text("+ new course",
                  style: Theme.of(context).textTheme.bodyMedium))
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
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
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: displayedCourses.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: displayedCourses.length,
                    itemBuilder: (context, index) {
                      final course = displayedCourses[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Container(
                          decoration: customContainerDecoration(context),
                          child: ListTile(
                            onTap: () {
                              String courseName = course['Name'];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailPage(
                                    courseName: courseName,
                                  ),
                                ),
                              );
                            },
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            title: Row(
                              children: [
                                Image.network(
                                  supabase.storage.from('images').getPublicUrl(
                                      'courses/${course['Name']}'),
                                  width: 50, // Increased size for visibility
                                  height: 50,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return CircularProgressIndicator(); // Loading spinner
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                    ); // Fallback if image fails to load
                                  },
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  course['Name'] ?? 'Unknown Course',
                                  style: Theme.of(context).textTheme.bodyLarge,
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
