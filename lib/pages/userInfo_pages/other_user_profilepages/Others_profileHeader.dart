import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:byhands_application/pages/userInfo_pages/profile_pages/editProfile.dart';
import 'package:easy_localization/easy_localization.dart';

class Others_profileHeader extends StatefulWidget {
  const Others_profileHeader({super.key, required this.username});
  final String username;

  @override
  State<Others_profileHeader> createState() => _Others_profileHeader();
}

class _Others_profileHeader extends State<Others_profileHeader> {
  final SupabaseClient supabase = Supabase.instance.client; // open the database
  String Bio = "";
  String userId = "";
  String url_profile = "";
  int postNum = 0;
  int follower = 0;
  int following = 0;

  @override
  void initState() {
    super.initState();
    fetchInformation();
  }

  Future<void> fetchInformation() async {
    Future<void> getURL() async {
      // Get the public URL for the specified file
      final response = await supabase.storage.from('images').getPublicUrl(
          'images/profiles/${widget.username}/${widget.username}profile');
      setState(() {
        url_profile = response;
      });
    }

    await getURL();
    // Use the email to search for information in the User table
    final response = await supabase
        .from('User')
        .select()
        .eq('Username', widget.username)
        .maybeSingle();

    if (response == null) {
      print("User data not found.");
      setState(() {
        postNum = 0;
        follower = 0;
        following = 0;
      });
      return;
    }

    // Assign the UserID from the response
    setState(() {
      userId = response['UserID'].toString();
      Bio = response['Bio'].toString();
    });

    print("UserID: $userId");

    // Query the Friendship table for follower count
    final responsefollower = await supabase
        .from('Friendship')
        .select()
        .eq('followerID', userId)
        .count();

    print("follower : $responsefollower");

    // Query the Friendship table for following count
    final responsefollowing = await supabase
        .from('Friendship')
        .select()
        .eq('followedID', userId)
        .count();
    print("following : $responsefollowing");

    // Query the Post table for the number of posts
    final responsePosts =
        await supabase.from('Post').select().eq('UserID', userId).count();

    print("Follower Count: ${responsefollower.count}");
    print("Following Count: ${responsefollowing.count}");
    print("Post Count: ${responsePosts.count}");

    // Update state with fetched counts
    setState(() {
      postNum = responsePosts.count;
      follower = responsefollower.count;
      following = responsefollowing.count;
    });
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
                          userName: widget.username,
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
                    widget.username,
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

  Widget NumbersWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildButton(text: 'other.posts'.tr(), value: postNum),
          buildButton(text: 'other.followers'.tr(), value: follower),
          buildButton(text: 'other.following'.tr(), value: following),
        ],
      );

  Widget buildButton({
    required String text,
    required int value,
  }) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
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
