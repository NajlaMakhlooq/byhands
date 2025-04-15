import 'package:byhands/pages/chats/chatDetails.dart';
import 'package:byhands/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Addnewchat extends StatefulWidget {
  Addnewchat({super.key, required this.conversations});
  List<Map<String, dynamic>> conversations;

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
    // Step 1: Get a set of all usernames involved in conversations
    final conversationUsernames =
        widget.conversations
            .expand((conv) => [conv['username1'], conv['username2']])
            .toSet();

    // Step 2: Filter followingList to get only those not in conversationUsernames
    final notInConversationList =
        followingList.where((follow) {
          return !conversationUsernames.contains(follow['following_to']);
        }).toList();
    setState(() {
      displayedFollowing = notInConversationList;
    });
  }

  Future<void> createConversactionRoom(
    String userame1,
    String username2,
  ) async {
    try {
      await Supabase.instance.client.from('conversations').insert({
        'username1': userame1,
        'username2': username2,
      });
    } catch (e) {
      print("❌🗂️ Error creating room : $e");
    }
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
      body:
          displayedFollowing.isEmpty
              ? Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  "You are chatting with all your friends follow a new user to chat with or press the button in their profile to chat ",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
              : Column(
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
                    child: ListView.builder(
                      itemCount: displayedFollowing.length,
                      itemBuilder: (context, index) {
                        final UserInfo = displayedFollowing[index];
                        String response = supabase.storage
                            .from('images')
                            .getPublicUrl(
                              'images/profiles/${UserInfo['following_to']}/${UserInfo['following_to']}profile',
                            );
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Container(
                            decoration: customContainerDecoration(context),
                            child: ListTile(
                              onTap: () async {
                                await Supabase.instance.client
                                    .from('conversations')
                                    .insert({
                                      'username1': username,
                                      'username2': UserInfo['following_to'],
                                    });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ChatDetailScreen(
                                          username: UserInfo['following_to'],
                                        ),
                                  ),
                                );
                              },
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
                                      '$response?t=${DateTime.now().millisecondsSinceEpoch}',
                                    ),
                                    onBackgroundImageError: (
                                      error,
                                      stackTrace,
                                    ) {
                                      // Handle errors gracefully
                                      print('📛 loading image Error: $error');
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
