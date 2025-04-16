import 'package:byhands/pages/chats/chatDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:byhands/pages/profile_pages/Usercourses.dart';
import 'package:byhands/pages/profile_pages/posts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;

// ignore: must_be_immutable
class UsersProfile extends StatefulWidget {
  const UsersProfile({super.key, required this.username});
  final String username;

  @override
  State<UsersProfile> createState() => _UsersProfileState();
}

class _UsersProfileState extends State<UsersProfile> {
  final prefix.SupabaseClient supabase = prefix.Supabase.instance.client;

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popAndPushNamed(context, '/Home');
          },
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
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
              Expanded(
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
    );
  }
}

class Others_profileHeader extends StatefulWidget {
  const Others_profileHeader({super.key, required this.username});
  final String username;

  @override
  State<Others_profileHeader> createState() => _Others_profileHeader();
}

class _Others_profileHeader extends State<Others_profileHeader> {
  final prefix.SupabaseClient supabase =
      prefix.Supabase.instance.client; // open the database
  String Bio = "";
  String userId = "";
  String url_profile = "";
  List<dynamic> followerList = [];
  List<dynamic> followingList = [];
  List<dynamic> postList = [];
  String currentUser = "";
  var check;

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
      print("⚠️ User data not found.");
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;

    final ThisUser =
        await supabase.from('User').select().eq('Email', email!).maybeSingle();

    if (ThisUser == null) {
      print("⚠️ User data not found.");
      return;
    }

    // Assign the UserID from the response
    setState(() {
      userId = response['Username'].toString();
      Bio = response['Bio'].toString();
      currentUser = ThisUser['Username'].toString();
    });
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

    Future<void> checkfollowed() async {
      final existingFollow =
          await supabase
              .from('Friendship')
              .select()
              .eq('followed_by', currentUser)
              .eq('following_to', widget.username)
              .maybeSingle(); // returns null if not found

      if (existingFollow == null) {
        setState(() {
          check = false;
        });
      } else {
        setState(() {
          check = true;
        });
      }
    }

    checkfollowed();
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
                    print('📛 loading image Error: $error');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.username,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(Bio, style: Theme.of(context).textTheme.bodyMedium),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        if (check == false) {
                          await supabase.from('Friendship').insert({
                            'followed_by': currentUser,
                            'following_to': widget.username,
                          });
                        } else {
                          await supabase.from('Friendship').delete().match({
                            'followed_by': currentUser,
                            'following_to': widget.username,
                          });
                        }
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    UsersProfile(username: widget.username),
                          ),
                        );
                      },
                      child:
                          check == false ? Text("+ follow") : Text("Unfollow"),
                    ),
                    IconButton(
                      onPressed: () async {
                        await supabase.from('conversations').insert({
                          'username1': currentUser,
                          'username2': widget.username,
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ChatDetailScreen(username: widget.username),
                          ),
                        );
                      },
                      icon: Icon(Icons.chat, size: 20),
                    ),
                  ],
                ),
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
