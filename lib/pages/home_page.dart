import 'package:byhands/pages/menus/mainmenu.dart';
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:byhands/pages/courses/Course_details.dart';
import 'package:byhands/pages/categories/category_details.dart';
import 'package:byhands/pages/profile_pages/UsersProfile.dart';
import 'package:byhands/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;
import 'package:scroll_snap_list/scroll_snap_list.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  final prefix.SupabaseClient supabase = prefix.Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _showDropdown = false;
  List<Map<String, dynamic>> allCategories = [];
  List<Map<String, dynamic>> Users = [];
  List<Map<String, dynamic>> Courses = [];
  String username = "";

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchCourses();
    fetchUsers();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('categories').select();
      setState(() {
        allCategories =
            (response as List<dynamic>?)
                ?.map(
                  (e) => {
                    'Name': e['Name'] ?? 'Unknown', // Handle null values
                    'Description':
                        e['Description'] ?? 'No description available',
                    'icon': e['icon'] ?? '', // Ensure 'icon' exists
                  },
                )
                .toList() ??
            [];
      });
    } catch (error) {
      print('❌ Error fetching categories: $error');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final String? email = user?.email;
      if (email == null) {
        setState(() {
          username = "No user logged in";
        });
        return;
      }

      //use the email to search for username
      final response =
          await supabase.from('User').select().eq('Email', email).maybeSingle();
      setState(() {
        username = response?['Username'] ?? "Unknown User";
      });
      final response2 = await supabase
          .from('Friendship')
          .select()
          .eq('followed_by', username);
      setState(() {
        Users =
            (response2 as List<dynamic>?)
                ?.map(
                  (e) => {
                    'followed_by': e['followed_by'] ?? username,
                    'following_to':
                        e['following_to'] ?? 'Unknown', // Handle null values
                  },
                )
                .toList() ??
            [];
      });
    } catch (error) {
      print('❌ Error fetching users: $error');
    }
  }

  Future<void> fetchCourses() async {
    try {
      final response = await supabase.from('Courses').select();
      setState(() {
        Courses =
            (response as List<dynamic>?)
                ?.map(
                  (e) => {
                    'Name': e['Name'] ?? 'Unknown', // Handle null values
                    'Description':
                        e['Description'] ?? 'No description available',
                    'price': e['price'] ?? '',
                    'location': e['location'] ?? '',
                    'Provider': e['Provider'] ?? '',
                    'CategoryName': e['CategoryName'] ?? '',
                  },
                )
                .toList() ??
            [];
      });
    } catch (error) {
      print('❌ Error fetching courses: $error');
    }
  }

  Future<void> _performSearch(String query) async {
    final prefix.SupabaseClient supabase = prefix.Supabase.instance.client;

    final response = await supabase
        .from('User')
        .select()
        .ilike('Username', '%$query%'); // Perform case-insensitive search

    setState(() {
      _searchResults = List<Map<String, dynamic>>.from(response);
      _showDropdown = query.isNotEmpty && _searchResults.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
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
                          177,
                          167,
                          183,
                        ) // Dark mode color
                        : const Color.fromARGB(
                          255,
                          72,
                          59,
                          75,
                        ), // Light mode color
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: SizedBox(
          // Search Bar
          height: 40,
          child: TextField(
            style: Theme.of(context).textTheme.labelMedium,
            controller: _searchController,
            decoration: InputDecoration(
              hintStyle: Theme.of(context).textTheme.labelMedium,
              contentPadding: EdgeInsets.all(3),
              hintText: 'Search for users...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _performSearch(value);
            },
          ),
        ),
      ),
      drawer: CommonDrawer(),
      body:
          _showDropdown == true
              ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListView.builder(
                  shrinkWrap:
                      true, // Ensures it doesn't take full screen height
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    final response = supabase.storage
                        .from('images')
                        .getPublicUrl(
                          'images/profiles/${user['Username']}/${user['Username']}profile',
                        );

                    return Column(
                      children: [
                        ListTile(
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
                                    ), // border color
                                    width: 2, // Set the width of the border
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    216,
                                    222,
                                    236,
                                  ),
                                  backgroundImage: NetworkImage(
                                    '$response?t=${DateTime.now().millisecondsSinceEpoch}',
                                  ),
                                  onBackgroundImageError: (error, stackTrace) {
                                    print('📛 Error loading image: $error');
                                  },
                                ),
                              ),
                              SizedBox(width: 20),
                              Text(
                                user['Username'],
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),

                          onTap: () {
                            // Navigate to the selected user's profile
                            _searchController.text = '';
                            setState(() {
                              _showDropdown = false;
                            });
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => UsersProfile(
                                      username: user['Username'],
                                    ),
                              ),
                            );
                          },
                        ),
                        Divider(),
                      ],
                    );
                  },
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Align(
                      alignment:
                          Alignment.centerLeft, // Aligns the text to the left
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          'Users followed',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(
                      height: 130,
                      child:
                          Users.isEmpty
                              ? Center(
                                child: Text(
                                  'No Users found.',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              )
                              : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: Users.length,
                                  itemBuilder: (context, index) {
                                    final user = Users[index];
                                    String response = supabase.storage
                                        .from('images')
                                        .getPublicUrl(
                                          'images/profiles/${user['following_to']}/${user['following_to']}profile',
                                        );
                                    String imageUrl =
                                        '$response?t=${DateTime.now().millisecondsSinceEpoch}';
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ), // Reduced vertical padding
                                      child: Center(
                                        child: UserCard(
                                          label:
                                              user['following_to'] ??
                                              'Unknown User',
                                          onTap: () {
                                            String Username =
                                                user['following_to'];
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => UsersProfile(
                                                      username: Username,
                                                    ),
                                              ),
                                            );
                                          },
                                          imageUrl:
                                              imageUrl.isNotEmpty
                                                  ? imageUrl
                                                  : 'assets/logo.png', // Fallback image
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Align(
                          alignment:
                              Alignment
                                  .centerLeft, // Aligns the text to the left
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Text(
                              'Categories',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                        Align(
                          alignment:
                              Alignment
                                  .centerRight, // Aligns the text to the left
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: TextButton(
                              onPressed: () {
                                Navigator.popAndPushNamed(
                                  context,
                                  '/Categories',
                                );
                              },
                              child: Text(
                                'see all',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    SizedBox(
                      height: 160,
                      child:
                          allCategories.isEmpty
                              ? Center(
                                child: Text(
                                  'No categories found.',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              )
                              : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: allCategories.length,
                                  itemBuilder: (context, index) {
                                    final category = allCategories[index];
                                    String response = supabase.storage
                                        .from('images')
                                        .getPublicUrl(
                                          'categories/${category['icon']}',
                                        );
                                    String imageUrl =
                                        '$response?t=${DateTime.now().millisecondsSinceEpoch}';
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ), // Reduced vertical padding
                                      child: Center(
                                        child: CategoryCard(
                                          label:
                                              category['Name'] ??
                                              'Unknown Category',
                                          onTap: () {
                                            String categoryName =
                                                category['Name'];
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        CategoryDetailPage(
                                                          categoryName:
                                                              categoryName,
                                                        ),
                                              ),
                                            );
                                          },
                                          imageUrl:
                                              imageUrl.isNotEmpty
                                                  ? imageUrl
                                                  : 'assets/logo.png', // Fallback image
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                    ),
                    SizedBox(height: 20),
                    // Popular Section
                    Align(
                      alignment:
                          Alignment.centerLeft, // Aligns the text to the left
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          'Popular Courses',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 270,
                      child: ScrollSnapList(
                        itemBuilder: _buildItemList,
                        itemSize: 200,
                        dynamicItemSize: true,
                        itemCount: Courses.length,
                        onItemFocus: (integer) {},
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
      bottomNavigationBar: mainMenu(0),
    );
  }

  Widget _buildItemList(BuildContext context, int index) {
    final course = Courses[index];
    String response = supabase.storage
        .from('images')
        .getPublicUrl('courses/${course['Name']}');

    String courseImageURL =
        '$response?t=${DateTime.now().millisecondsSinceEpoch}';

    if (index == course.length) {
      return Center(child: CircularProgressIndicator());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: customContainerDecoration(context),
          width: 200,
          height: 260,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                courseImageURL,
                width: 120, // Increased size for visibility
                height: 120,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return CircularProgressIndicator(); // Loading spinner
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    size: 70,
                  ); // Fallback if image fails to load
                },
              ),
              SizedBox(height: 8),
              Text(
                course['Name'],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    final course = Courses[index];
                    String courseName = course['Name'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                CourseDetailPage(courseName: courseName),
                      ),
                    );
                  },
                  style: CustomElevatedButtonTheme(context),
                  child: Text("view course", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String imageUrl; // URL of the image from Supabase
  final String label;
  final VoidCallback onTap;

  const CategoryCard({
    required this.imageUrl,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 140,
        decoration: customContainerDecoration(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imageUrl,
              width: 70, // Increased size for visibility
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return CircularProgressIndicator(); // Loading spinner
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported,
                  size: MediaQuery.sizeOf(context).width * 0.10,
                ); // Fallback if image fails to load
              },
            ),
            SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final String imageUrl; // URL of the image from Supabase
  final String label;
  final VoidCallback onTap;

  const UserCard({
    required this.imageUrl,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 120,
        decoration: customContainerDecoration(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                radius: 30,
                backgroundColor: const Color.fromARGB(255, 216, 222, 236),
                backgroundImage: NetworkImage(imageUrl),
                onBackgroundImageError: (error, stackTrace) {
                  print('📛 Error loading image: $error');
                },
              ),
            ),
            SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
