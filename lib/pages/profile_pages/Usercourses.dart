import 'package:byhands/theme.dart';
import 'package:flutter/material.dart';
import 'package:byhands/pages/courses/Course_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Courses extends StatefulWidget {
  final String userName;
  const Courses({super.key, required this.userName});

  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  final SupabaseClient supabase = Supabase.instance.client; // open the database
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;
  int userId = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      final response = await supabase
          .from('Courses')
          .select()
          .eq('Provider', widget.userName);

      courses =
          (response as List<dynamic>)
              .map(
                (course) => {
                  'Name': course['Name'] ?? 'Unknown',
                  'Description':
                      course['Description'] ?? 'No description available',
                },
              )
              .toList();
    } catch (error) {
      print('Error fetching Courses: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : courses.isEmpty
              ? Center(child: Text('No courses provided.'))
              : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return CourseCard(course: course);
                },
              ),
    );
  }
}

class CourseCard extends StatefulWidget {
  final Map<String, dynamic> course;
  const CourseCard({super.key, required this.course});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  final SupabaseClient supabase = Supabase.instance.client; // open the database
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Container(
        decoration: customContainerDecoration(context),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        CourseDetailPage(courseName: widget.course['Name']),
              ),
            );
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 3,
          ),
          title: Row(
            children: [
              Image.network(
                supabase.storage
                    .from('images')
                    .getPublicUrl('courses/${widget.course['Name']}'),
                width: 70, // Increased size for visibility
                height: 70,
                loadingBuilder: (context, child, loadingProgress) {
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
              SizedBox(width: 10),
              Text(
                widget.course['Name'] ?? 'Unknown Course',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 54, 43, 75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
