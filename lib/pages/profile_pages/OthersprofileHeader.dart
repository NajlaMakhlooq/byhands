import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  List<dynamic> followerList = [];
  List<dynamic> followingList = [];
  List<dynamic> postList = [];

  @override
  void initState() {
    super.initState();
    fetchInformation();
  }

  Future<void> fetchInformation() async {
    Future<void> getURL() async {
      // Get the public URL for the specified file
      final response = supabase.storage
          .from('images')
          .getPublicUrl(
            'images/profiles/${widget.username}/${widget.username}profile',
          );
      setState(() {
        url_profile = '$response?t=${DateTime.now().millisecondsSinceEpoch}';
      });
    }

    await getURL();
    // Use the username to search for information in the User table
    final response =
        await supabase
            .from('User')
            .select()
            .eq('Username', widget.username)
            .maybeSingle();

    if (response == null) {
      print("User data not found.");
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
        .eq('following_to', widget.username);
    setState(() {
      followerList =
          (responsefollower as List<dynamic>?)
              ?.map(
                (e) => {
                  'following_to':
                      e['following_to'] ?? 'Unknown', // Handle null values
                  'followed_by':
                      e['followed_by'] ?? 'Unknown', // Handle null values
                },
              )
              .toList() ??
          [];
    });
    print("follower : ${followerList.length}");

    // Query the Friendship table for following count
    final responsefollowing = await supabase
        .from('Friendship')
        .select()
        .eq('followed_by', widget.username);
    setState(() {
      followingList =
          (responsefollowing as List<dynamic>?)
              ?.map(
                (e) => {
                  'followed_by':
                      e['followed_by'] ?? 'Unknown', // Handle null values
                  'following_to':
                      e['following_to'] ?? 'Unknown', // Handle null values
                },
              )
              .toList() ??
          [];
    });
    print("following : ${followingList.length}");

    // Query the Post table for the number of posts
    final responsePosts = await supabase
        .from('Post')
        .select()
        .eq('username', widget.username);
    setState(() {
      postList =
          (responsePosts as List<dynamic>?)
              ?.map(
                (e) => {
                  'username': e['username'] ?? 'Unknown', // Handle null values
                },
              )
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
                  radius: 60,
                  backgroundImage: NetworkImage(url_profile),
                  onBackgroundImageError: (error, stackTrace) {
                    // Handle errors gracefully
                    print('loading image Error: $error');
                  },
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
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(Bio, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Divider(),
          NumbersWidget(),
          Divider(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget NumbersWidget() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildButton(text: 'Posts', value: postList.length),
      buildButton(text: 'Followers', value: followerList.length),
      buildButton(text: 'Following', value: followingList.length),
    ],
  );

  Widget buildButton({required String text, required int value}) =>
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
            SizedBox(height: 2),
            Text(text, style: TextStyle(fontSize: 12)),
          ],
        ),
      );
}
