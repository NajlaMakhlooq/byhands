import 'package:byhands/pages/userInfo_pages/other_user_profilepages/Others_profileHeader.dart';
import 'package:flutter/material.dart';
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:byhands/pages/userInfo_pages/profile_pages/Usercourses.dart';
import 'package:byhands/pages/userInfo_pages/profile_pages/posts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: must_be_immutable
class UsersProfile extends StatefulWidget {
  const UsersProfile({super.key, required this.username});
  final String username;

  @override
  State<UsersProfile> createState() => _UsersProfileState();
}

class _UsersProfileState extends State<UsersProfile> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(" ${widget.username} Profile"),
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
      body: DefaultTabController(
        length: 2,
        child:
            {widget.username}.isEmpty
                ? Center(child: CircularProgressIndicator())
                : NestedScrollView(
                  headerSliverBuilder: (context, _) {
                    return [
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Others_profileHeader(username: widget.username),
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
                      {widget.username}.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : Expanded(
                            child: TabBarView(
                              children: [
                                Posts(userName: widget.username),
                                Courses(userName: widget.username),
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
