import 'package:byhands_application/pages/userInfo_pages/profile_pages/followerList_display.dart';
import 'package:byhands_application/pages/userInfo_pages/profile_pages/followingList_display.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:byhands_application/pages/userInfo_pages/profile_pages/editProfile.dart';

class profileHeader extends StatefulWidget {
  const profileHeader({super.key});

  @override
  State<profileHeader> createState() => _profileHeader();
}

class _profileHeader extends State<profileHeader> {
  final SupabaseClient supabase = Supabase.instance.client; // open the database
  String username = "";
  String Bio = "";
  String userId = "";
  String url_profile = "";
  List<dynamic> followerList = [];
  List<dynamic> followingList = [];
  List<dynamic> postList = [];

  @override
  void initState() {
    super.initState();
    fetchInformation();
  }

  Future<void> fetchInformation() async {
    // get the user email
    final session = supabase.auth.currentSession;
    final user = session?.user;
    final email = user?.email;
    if (email == null) {
      setState(() {
        username = "No user logged in";
        Bio = "No Bio";
      });
      return;
    }

    //use the email to search for username
    final response =
        await supabase.from('User').select().eq('Email', email).maybeSingle();
    setState(() {
      username = response?['Username'] ?? "Unknown User";
      Bio = response?['Bio'] ?? "No Bio";
    });

    Future<void> getURL() async {
      // Get the public URL for the specified file
      final response = await supabase.storage
          .from('images')
          .getPublicUrl('images/profiles/$username/${username}profile');
      setState(() {
        url_profile = response;
      });
    }

    await getURL();

    // Query the Friendship table for follower count
    final responsefollower =
        await supabase.from('Friendship').select().eq('following_to', username);
    setState(() {
      followerList = (responsefollower as List<dynamic>?)
              ?.map((e) => {
                    'following_to':
                        e['following_to'] ?? 'Unknown', // Handle null values
                    'followed_by':
                        e['followed_by'] ?? 'Unknown', // Handle null values
                  })
              .toList() ??
          [];
    });
    print("follower : ${followerList.length}");

    // Query the Friendship table for following count
    final responsefollowing =
        await supabase.from('Friendship').select().eq('followed_by', username);
    setState(() {
      followingList = (responsefollowing as List<dynamic>?)
              ?.map((e) => {
                    'followed_by':
                        e['followed_by'] ?? 'Unknown', // Handle null values
                    'following_to':
                        e['following_to'] ?? 'Unknown', // Handle null values
                  })
              .toList() ??
          [];
    });
    print("following : ${followingList.length}");

    // Query the Post table for the number of posts
    final responsePosts =
        await supabase.from('Post').select().eq('username', username);
    setState(() {
      postList = (responsePosts as List<dynamic>?)
              ?.map((e) => {
                    'username':
                        e['username'] ?? 'Unknown', // Handle null values
                  })
              .toList() ??
          [];
    });
    print("follower : ${postList.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(url_profile),
                  onBackgroundImageError: (error, stackTrace) {
                    // Handle errors gracefully
                    print('loading image Error: $error');
                  },
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Edit(
                          userName: username,
                        ),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Color.fromARGB(205, 54, 43, 75),
                    child: Icon(Icons.edit, size: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(7.0),
              child: Column(
                children: [
                  Text(
                    username,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    Bio,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )),
          Divider(),
          NumbersWidget(),
          Divider(),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget NumbersWidget() => followingList.isEmpty
      ? Center(child: CircularProgressIndicator())
      : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildButton(text: 'Posts', value: postList.length),
            buildButton(text: 'Followers', value: followerList.length),
            buildButton(text: 'Following', value: followingList.length),
          ],
        );

  Widget buildButton({
    required String text,
    required int value,
  }) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {
          if (text == 'Posts') {}
          if (text == 'Followers') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FollowerlistDisplay(
                  followerList: followerList,
                ),
              ),
            );
          }
          if (text == 'Following') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FollowinglistDisplay(
                  followingList: followingList,
                ),
              ),
            );
          }
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
}
