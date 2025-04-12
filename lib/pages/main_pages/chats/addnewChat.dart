import 'package:byhands/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Addnewchat extends StatefulWidget {
  const Addnewchat({super.key});

  @override
  State<Addnewchat> createState() => _AddnewchatState();
}

class _AddnewchatState extends State<Addnewchat> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> followingList = [];
  List<dynamic> displayedFollowing = [];
  String searchQuery = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    list();
  }

  Future<void> list() async {
    final session = supabase.auth.currentSession;
    final user = session?.user;
    final email = user?.email;

    //use the email to search for username
    final response =
        await supabase
            .from('User')
            .select()
            .eq('Email', email ?? "")
            .maybeSingle();
    setState(() {
      username = response?['Username'] ?? "Unknown User";
    });
    print("user = $username");

    final responsefollowing = await supabase
        .from('Friendship')
        .select()
        .eq('followed_by', username);
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
    setState(() {
      displayedFollowing = followingList;
    });
    print("List = $followingList");
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      displayedFollowing =
          followingList
              .where(
                (user) => user['following_to']
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("Start Chatting with"),
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
            child:
                displayedFollowing.isEmpty
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
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Container(
                            decoration: customContainerDecoration(context),
                            child: ListTile(
                              onTap: () {},
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      216,
                                      222,
                                      236,
                                    ),
                                    backgroundImage: NetworkImage(
                                      supabase.storage
                                          .from('images')
                                          .getPublicUrl(
                                            'images/profiles/${UserInfo['following_to']}/${UserInfo['following_to']}profile',
                                          ),
                                    ),
                                    onBackgroundImageError: (
                                      error,
                                      stackTrace,
                                    ) {
                                      // Handle errors gracefully
                                      print('loading image Error: $error');
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    UserInfo['following_to'] ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 54, 43, 75),
                                    ),
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
  final response =
      await Supabase.instance.client
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
