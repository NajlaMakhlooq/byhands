import 'package:byhands/pages/main_pages/chats/addnewChat.dart';
import 'package:byhands/pages/main_pages/chats/chatDetails.dart';
import 'package:byhands/pages/menus/mainmenu.dart';
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:byhands/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> conversations = [];
  String username = "";

  @override
  void initState() {
    super.initState();
    fetchUsername();
    fetchConversations();
  }

  Future<void> fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (email == null) {
      setState(() {
        username = "No user logged in";
      });
      return;
    }

    try {
      // Fetch the user data from Firestore based on email
      final userDoc =
          await FirebaseFirestore.instance
              .collection('Users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (userDoc.docs.isNotEmpty) {
        // Assuming your Firestore collection stores the username field
        setState(() {
          username = userDoc.docs.first['username'] ?? "Unknown User";
        });
      } else {
        setState(() {
          username = "No user found in database";
        });
      }
    } catch (e) {
      setState(() {
        username = "Error fetching username: $e";
      });
    }
  }

  Future<String> fetchUserImage(int index) async {
    String usernameDisplayed = "";
    final conversation = conversations[index];
    if (conversation['username2'] == username) {
      usernameDisplayed = conversation['username1'].toString();
    } else {
      usernameDisplayed = conversation['username2'].toString();
    }
    final path =
        'images/profiles/$usernameDisplayed/${usernameDisplayed}profile';

    final ref = FirebaseStorage.instance.ref().child(path);
    final url = await ref.getDownloadURL();

    return url;
  }

  // Fetch conversations from Supabase
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final response =
        await FirebaseFirestore.instance
            .collection('Users')
            .where(
              Filter.or(
                Filter('username1', isEqualTo: username),
                Filter('username2', isEqualTo: username),
              ),
            )
            .get();

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
                  MaterialPageRoute(builder: (context) => Addnewchat()),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Addnewchat(),
                            ),
                          );
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Container(
                      height: 80,
                      decoration: ChatsContainerDecoration(context),
                      child: ListTile(
                        onTap: () {
                          String conversationId = conversation['id'].toString();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatDetailScreen(
                                    conversationId: conversationId,
                                  ),
                            ),
                          );
                        },
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 7,
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
                                fetchUserImage(index) as String,
                              ),
                              onBackgroundImageError: (error, stackTrace) {
                                // Handle errors gracefully
                                print('loading image Error: $error');
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
                        ),
                      ),
                    ),
                  );
                },
              ),
      drawer: CommonDrawer(),
      bottomNavigationBar: mainMenu(4),
    );
  }
}
