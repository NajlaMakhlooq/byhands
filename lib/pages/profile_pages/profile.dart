import 'package:byhands/pages/profile_pages/profileHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:byhands/pages/profile_pages/Usercourses.dart';
import 'package:byhands/pages/profile_pages/posts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;

// ignore: must_be_immutable
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final prefix.SupabaseClient supabase =
      prefix.Supabase.instance.client; // open the database
  bool loading = true; // Add loading state
  String username = "";
  bool profileHeaderCheck = false;

  @override
  void initState() {
    super.initState();
    fetchUsername();
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

    setState(() {
      loading = false; // Set loading to false once done
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator if data is not yet fetched
    if (loading) {
      return Center(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            title: Text(" $username Profile"),
            shadowColor: Color.fromARGB(255, 54, 43, 75),
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
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Once data is loaded, render the drawer
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(" $username Profile"),
        shadowColor: Color.fromARGB(255, 54, 43, 75),
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
      body: buildHeader(context),
      drawer: CommonDrawer(),
    );
  }

  Widget buildHeader(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child:
          username.isEmpty
              ? Center(child: CircularProgressIndicator())
              : NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        profileHeader(username: username),
                      ]),
                    ),
                  ];
                },
                body: Column(
                  children: <Widget>[
                    Material(
                      color: Colors.white,
                      child: TabBar(
                        labelColor: Color.fromARGB(255, 54, 43, 75),
                        unselectedLabelColor: Colors.grey[400],
                        indicatorWeight: 1,
                        indicatorColor: Colors.black,
                        tabs: [
                          Tab(icon: Icon(Icons.image)),
                          Tab(icon: Icon(Icons.book)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Posts(userName: username),
                          Courses(userName: username),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
