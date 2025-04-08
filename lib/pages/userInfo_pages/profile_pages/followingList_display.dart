import 'package:byhands_application/pages/userInfo_pages/other_user_profilepages/UsersProfile.dart';
import 'package:byhands_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowinglistDisplay extends StatefulWidget {
  FollowinglistDisplay({super.key, required this.followingList});
  List<dynamic> followingList = [];

  @override
  State<FollowinglistDisplay> createState() => _FollowinglistDisplayState();
}

class _FollowinglistDisplayState extends State<FollowinglistDisplay> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> displayedFollowing = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    list();
  }

  Future<void> list() async {
    setState(() {
      displayedFollowing = widget.followingList;
    });
    print("List = ${widget.followingList}");
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      displayedFollowing = widget.followingList
          .where((user) => user['following_to']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("Following List"),
      ),
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
                  labelText: 'Search Categories',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          Expanded(
            child: displayedFollowing.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No User found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: displayedFollowing.length,
                    itemBuilder: (context, index) {
                      final UserInfo = displayedFollowing[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Container(
                          decoration: customContainerDecoration(context),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UsersProfile(
                                    username: UserInfo['following_to'],
                                  ),
                                ),
                              );
                            },
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            title: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                    supabase.storage.from('images').getPublicUrl(
                                        'images/profiles/${UserInfo['following_to']}/${UserInfo['following_to']}profile'),
                                  ),
                                  onBackgroundImageError: (error, stackTrace) {
                                    // Handle errors gracefully
                                    print('loading image Error: $error');
                                  },
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  UserInfo['following_to'] ?? "",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 54, 43, 75)),
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
    );
  }
}

Future<bool> checkCategorynameExists(String name) async {
  final response = await Supabase.instance.client
      .from('categories')
      .select()
      .eq('Name', name)
      .maybeSingle();

  if (response != null) {
    return true; // Username exists
  } else {
    return false; // Username does not exist
  }
}
