import 'package:byhands/pages/chats/addnewChat.dart';
import 'package:byhands/pages/chats/chatDetails.dart';
import 'package:byhands/pages/menus/mainmenu.dart';
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:byhands/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> conversations = [];
  String username = "";
  List<String> NotChatted = [];

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
        username = "";
      });
      return;
    }

    //use the email to search for the username
    final response =
        await supabase
            .from('User')
            .select('Username')
            .eq('Email', email)
            .maybeSingle();
    setState(() {
      username = response?['Username'] ?? "";
    });
    fetchConversations();
  }

  // Fetch conversations from Supabase
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final response = await supabase
        .from('conversations')
        .select()
        .or('username1.eq.$username,username2.eq.$username');
    setState(() {
      conversations =
          (response as List<dynamic>?)
              ?.map(
                (e) => {
                  'id': e['id'] ?? 0,
                  'username1': e['username1'] ?? 'Unknown',
                  'username2': e['username2'] ?? 'Unknown',
                  'created_at': e['created_at'] ?? '',
                },
              )
              .toList() ??
          [];
    });
    return conversations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text("Conversations"),
        shadowColor: Color.fromARGB(255, 54, 43, 75),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: buttonsDesign(context),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => Addnewchat(conversations: conversations),
                  ),
                );
              },
              child: Text(
                "Add",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color.fromARGB(255, 216, 222, 236),
                ),
              ),
            ),
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
      drawer: CommonDrawer(),
      body:
          conversations.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No conversations',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: 300,
                      child: TextButton(
                        style: buttonsDesign(context),
                        onPressed: () {
                          if (conversations.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => Addnewchat(
                                      conversations: conversations,
                                    ),
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Follow a new user"),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "You are chatting with all your friends follow a new user to chat with or press the button in their profile to chat ",
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text("Cancel"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text("Submit"),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Text(
                          'Start new conversation...',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: Color.fromARGB(255, 216, 222, 236),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  String response = supabase.storage
                      .from('images')
                      .getPublicUrl(
                        'images/profiles/${conversation['username1']}/${conversation['username1']}profile',
                      );
                  String response2 = supabase.storage
                      .from('images')
                      .getPublicUrl(
                        'images/profiles/${conversation['username2']}/${conversation['username2']}profile',
                      );
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Container(
                      height: 80,
                      decoration: UsersListContainerDecoration(context),
                      child: ListTile(
                        onTap: () {
                          conversation['username2'] == username
                              ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatDetailScreen(
                                        username: conversation['username1'],
                                      ),
                                ),
                              )
                              : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatDetailScreen(
                                        username: conversation['username2'],
                                      ),
                                ),
                              );
                        },
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 7,
                        ),
                        title:
                            conversation['username2'] == username
                                ? Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
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
                                      conversation['username1'] ?? " ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 54, 43, 75),
                                      ),
                                    ),
                                  ],
                                )
                                : Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage: NetworkImage(
                                        '$response2?t=${DateTime.now().millisecondsSinceEpoch}',
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
                                      conversation['username2'] ?? " ",
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
      bottomNavigationBar: mainMenu(4),
    );
  }
}
