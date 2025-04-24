import 'package:byhands_application/menus/mainmenu.dart';
import 'package:byhands_application/pages/userInfo_pages/other_user_profilepages/UsersProfile.dart';
import 'package:byhands_application/pop_up/Course_details.dart';
import 'package:byhands_application/pop_up/category_details.dart';
import 'package:byhands_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:byhands_application/menus/side_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:easy_localization/easy_localization.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  final SupabaseClient supabase = Supabase.instance.client;
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
        allCategories = (response as List<dynamic>?)
                ?.map((e) => {
                      'Name': e['Name'] ?? 'Unknown', // Handle null values
                      'Description':
                          e['Description'] ?? 'No description available',
                      'icon': e['icon'] ?? '', // Ensure 'icon' exists
                    })
                .toList() ??
            [];
      });
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final session = supabase.auth.currentSession;
      final user = session?.user;
      final email = user?.email;
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
        Users = (response2 as List<dynamic>?)
                ?.map((e) => {
                      'followed_by': e['followed_by'] ?? username,
                      'following_to':
                          e['following_to'] ?? 'Unknown', // Handle null values
                    })
                .toList() ??
            [];
      });
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  Future<void> fetchCourses() async {
    try {
      final response = await supabase.from('Courses').select();
      setState(() {
        Courses = (response as List<dynamic>?)
                ?.map((e) => {
                      'Name': e['Name'] ?? 'Unknown', // Handle null values
                      'Description':
                          e['Description'] ?? 'No description available',
                      'price': e['price'] ?? '',
                      'location': e['location'] ?? '',
                      'Provider': e['Provider'] ?? '',
                      'CategoryName': e['CategoryName'] ?? '',
                    })
                .toList() ??
            [];
      });
    } catch (error) {
      print('Error fetching courses: $error');
    }
  }

  Future<void> _performSearch(String query) async {
    final SupabaseClient supabase = Supabase.instance.client;

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
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Color.fromARGB(255, 39, 66, 1),
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
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "dashboard.title".tr(),
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
      body: _showDropdown == true
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListView.builder(
                shrinkWrap: true, // Ensures it doesn't take full screen height
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    title: Text(
                      user['Username'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onTap: () {
                      // Navigate to the selected user's profile
                      _searchController.text = '';
                      setState(() {
                        _showDropdown = false;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UsersProfile(
                            username: user['Username'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment:
                      Alignment.centerLeft, // Aligns the text to the left
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text(
                      'dashboard.new'.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 130,
                  child: Users.isEmpty
                      ? Center(
                          child: Text(
                            'dashboard.not'.tr(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: Users.length,
                            itemBuilder: (context, index) {
                              final user = Users[index];
                              String imageUrl = supabase.storage
                                  .from('images')
                                  .getPublicUrl(
                                      'images/profiles/${user['following_to']}/${user['following_to']}profile');
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10), // Reduced vertical padding
                                child: Center(
                                  child: UserCard(
                                    label:
                                        user['following_to'] ?? 'Unknown User',
                                    onTap: () {
                                      String Username = user['following_to'];
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UsersProfile(
                                            username: Username,
                                          ),
                                        ),
                                      );
                                    },
                                    imageUrl: imageUrl.isNotEmpty
                                        ? imageUrl
                                        : 'assets/logo.png', // Fallback image
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
                Row(
                  children: [
                    Align(
                      alignment:
                          Alignment.centerLeft, // Aligns the text to the left
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text('dashboard.categories'.tr(),
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ),
                    Align(
                      alignment:
                          Alignment.centerRight, // Aligns the text to the left
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/Categories');
                          },
                          child: Text(
                            'dashboard.see'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 130,
                  child: allCategories.isEmpty
                      ? Center(
                          child: Text(
                            'dashboard.noc'.tr(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: allCategories.length,
                          itemBuilder: (context, index) {
                            final category = allCategories[index];
                            String imageUrl = supabase.storage
                                .from('images')
                                .getPublicUrl('categories/${category['icon']}');
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8), // Reduced vertical padding
                              child: Center(
                                child: CategoryCard(
                                  label: category['Name'] ?? 'Unknown Category',
                                  onTap: () {
                                    String categoryName = category['Name'];
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CategoryDetailPage(
                                          categoryName: categoryName,
                                        ),
                                      ),
                                    );
                                  },
                                  imageUrl: imageUrl.isNotEmpty
                                      ? imageUrl
                                      : 'assets/logo.png', // Fallback image
                                ),
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(
                  height: 20,
                ),
                // Popular Section
                Align(
                  alignment:
                      Alignment.centerLeft, // Aligns the text to the left
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text(
                      'dashboard.courses'.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 250,
                  child: ScrollSnapList(
                    itemBuilder: _buildItemList,
                    itemSize: 200,
                    dynamicItemSize: true,
                    itemCount: Courses.length,
                    onItemFocus: (integer) {},
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
      bottomNavigationBar: mainMenu(0),
    );
  }

  Widget _buildItemList(BuildContext context, int index) {
    final course = Courses[index];
    String courseImageURL = supabase.storage
        .from('images')
        .getPublicUrl('courses/${course['Name']}');

    if (index == course.length) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: customContainerDecoration(context),
          width: 200,
          height: 240,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                courseImageURL,
                width: 120, // Increased size for visibility
                height: 130,
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
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(
                height: 8,
              ),
              TextButton(
                  onPressed: () {
                    final course = Courses[index];
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
                  child: Text(
                    "dashboard.view".tr(),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                  ))
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
        height: 120,
        decoration: customContainerDecoration(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imageUrl,
              width: MediaQuery.sizeOf(context).width *
                  0.17, // Increased size for visibility
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return CircularProgressIndicator(); // Loading spinner
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported,
                  size: MediaQuery.sizeOf(context).width * 0.17,
                ); // Fallback if image fails to load
              },
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
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
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (error, stackTrace) {
                // Handle errors gracefully
                print('loading image Error: $error');
              },
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
