import 'package:byhands_application/pages/main_pages/chats/addnewChat.dart';
import 'package:byhands_application/pages/main_pages/chats/chatDetails.dart';
import 'package:byhands_application/menus/mainmenu.dart';
import 'package:byhands_application/theme.dart';
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
    final response = await supabase
        .from('User')
        .select('Username')
        .eq('Email', email)
        .maybeSingle();
    setState(() {
      username = response?['Username'] ?? "";
    });
    print(username);
    fetchConversations();
  }

  // Fetch conversations from Supabase
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final response = await supabase
        .from('conversations')
        .select()
        .or('username1.eq.$username,username2.eq.$username');
    setState(() {
      conversations = (response as List<dynamic>?)
              ?.map((e) => {
                    'id': e['id'] ?? 0,
                    'username1': e['username1'] ?? 'Unknown',
                    'username2': e['username2'] ?? 'Unknown',
                    'created_at': e['created_at'] ?? '',
                  })
              .toList() ??
          [];
    });
    print(conversations);
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
                    builder: (context) => Addnewchat(),
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
          )
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No conversations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextButton(
                      style: buttonsDesign(context),
                      onPressed: () {},
                      child: Text(
                        'Start new conversation...',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Color.fromARGB(255, 216, 222, 236),
                            ),
                      ),
                    ),
                  )
                ],
              ),
            )
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Container(
                    height: 80,
                    decoration: ChatsContainerDecoration(context),
                    child: ListTile(
                        onTap: () {
                          String conversationId = conversation['id'].toString();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                  conversationId: conversationId),
                            ),
                          );
                        },
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                        title: conversation['username2'] == username
                            ? Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(
                                      supabase.storage.from('images').getPublicUrl(
                                          'images/profiles/${conversation['username1']}/${conversation['username1']}profile'),
                                    ),
                                    onBackgroundImageError:
                                        (error, stackTrace) {
                                      // Handle errors gracefully
                                      print('loading image Error: $error');
                                    },
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    conversation['username1'] ?? " ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 54, 43, 75)),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(
                                      supabase.storage.from('images').getPublicUrl(
                                          'images/profiles/${conversation['username2']}/${conversation['username2']}profile'),
                                    ),
                                    onBackgroundImageError:
                                        (error, stackTrace) {
                                      // Handle errors gracefully
                                      print('loading image Error: $error');
                                    },
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    conversation['username2'] ?? " ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 54, 43, 75)),
                                  ),
                                ],
                              )),
                  ),
                );
              },
            ),
      bottomNavigationBar: mainMenu(4),
    );
  }
}
