import 'package:byhands_application/pages/userInfo_pages/other_user_profilepages/UsersProfile.dart';
import 'package:byhands_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class FollowerlistDisplay extends StatefulWidget {
  FollowerlistDisplay({super.key, required this.followerList});
  List<dynamic> followerList = [];

  @override
  State<FollowerlistDisplay> createState() => _FollowerlistDisplayState();
}

class _FollowerlistDisplayState extends State<FollowerlistDisplay> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> displayedFollower = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    list();
  }

  Future<void> list() async {
    setState(() {
      displayedFollower = widget.followerList;
    });
    print("List = ${widget.followerList}");
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      displayedFollower = widget.followerList
          .where((user) => user['followed_by']
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
        title: Text("follower.title".tr()),
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
                  labelText: 'follower.search'.tr(),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          Expanded(
            child: displayedFollower.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'follower.noUser'.tr(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: displayedFollower.length,
                    itemBuilder: (context, index) {
                      final UserInfo = displayedFollower[index];
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
                                    username: UserInfo['followed_by'],
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
                                        'images/profiles/${UserInfo['followed_by']}/${UserInfo['followed_by']}profile'),
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
                                  UserInfo['followed_by'] ?? "",
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
