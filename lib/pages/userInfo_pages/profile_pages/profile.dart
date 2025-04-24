import 'package:flutter/material.dart';
import 'package:byhands_application/menus/side_menu.dart';
import 'package:byhands_application/pages/userInfo_pages/profile_pages/profileHeader.dart';
import 'package:byhands_application/pages/userInfo_pages/profile_pages/Usercourses.dart';
import 'package:byhands_application/pages/userInfo_pages/profile_pages/posts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: must_be_immutable
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final SupabaseClient supabase = Supabase.instance.client;
  String username = "";
  bool profileHeaderCheck = false;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    // get the user email
    final session = supabase.auth.currentSession;
    final user = session?.user;
    final email = user?.email;
    if (email == null) {
      setState(() {
        username = "No user logged in";
      });
      return;
    }

    //use the email to search for the username
    final response = await supabase
        .from('User')
        .select('Username')
        .eq('Email', email)
        .maybeSingle();
    setState(() {
      username = response?['Username'] ?? "Unknown User";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(" $username "),
        shadowColor: Color.fromARGB(255, 54, 43, 75),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, '/Home');
              },
              icon: const Icon(Icons.home))
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
      body: DefaultTabController(
        length: 2,
        child: username.isEmpty
            ? Center(child: CircularProgressIndicator())
            : NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          profileHeader(),
                        ],
                      ),
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
                          Tab(
                            icon: Icon(Icons.image),
                          ),
                          Tab(
                            icon: Icon(
                              Icons.book,
                            ),
                          ),
                        ],
                      ),
                    ),
                    username.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : Expanded(
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
      ),
      drawer: CommonDrawer(),
    );
  }
}
