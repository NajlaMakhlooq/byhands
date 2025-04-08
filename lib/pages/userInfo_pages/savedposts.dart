import 'package:byhands_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:byhands_application/menus/side_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:byhands_application/pop_up/Post_detail.dart';

// ignore: camel_case_types
class Saved_posts extends StatefulWidget {
  const Saved_posts({super.key});

  @override
  State<Saved_posts> createState() => _Saved_posts();
}

class _Saved_posts extends State<Saved_posts> {
  final SupabaseClient supabase = Supabase.instance.client;
  int userid = 0;
  List<Map<String, dynamic>> savedPosts = [];
  bool isLoading = true; // To show a loading indicator
  String username = "";

  @override
  void initState() {
    super.initState();
    fetchUserID();
  }

  Future<void> fetchUserID() async {
    try {
      setState(() {
        isLoading = true; // Start loading
      });

      // Get the user session and email
      final session = supabase.auth.currentSession;
      final user = session?.user;
      final email = user?.email;

      if (email == null) {
        setState(() {
          userid = 0;
          isLoading = false; // Stop loading if no email found
        });
        return;
      }

      // Fetch UserID based on the email
      final response = await supabase
          .from('User')
          .select('UserID')
          .eq('Email', email)
          .maybeSingle();

      if (response != null && response.containsKey('UserID')) {
        setState(() {
          userid = response['UserID'];
        });
        final response2 = await supabase
            .from('User')
            .select()
            .eq('Email', email)
            .maybeSingle();
        setState(() {
          username = response2?['Username'] ?? "Unknown User";
        });
        // Fetch the liked courses after obtaining UserID
        await fetchPosts();
      } else {
        setState(() {
          userid = 0;
        });
      }
    } catch (error) {
      print("Error fetching UserID: $error");
    } finally {
      setState(() {
        isLoading = false; // Stop loading regardless of success or failure
      });
    }
  }

  Future<void> fetchPosts() async {
    try {
      final response =
          await supabase.from('Saved_posts').select().eq('User_id', userid);

      print('Fetched Saved Posts: $response'); // Debugging output
      List<int> Saved_postsId = (response as List<dynamic>?)
              ?.map((e) => e['post_id'] as int)
              .toList() ??
          [];
      print('All Posts Length: ${savedPosts.length}'); // Debugging output
      for (int i = 0; i < Saved_postsId.length; i++) {
        final response = await supabase
            .from('Post')
            .select()
            .eq('postID', Saved_postsId[i])
            .single(); // Fetch a single item

        savedPosts.add(response);
      }
      print(savedPosts);
    } catch (error) {
      print('Error fetching courses: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("Saved posts"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, '/Home');
              },
              icon: const Icon(Icons.home))
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
      drawer: CommonDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
              children: [
                Expanded(
                  child: savedPosts.isEmpty
                      ? Center(child: Text('No Posts Saved.'))
                      : ListView.builder(
                          itemCount: savedPosts.length,
                          itemBuilder: (context, index) {
                            final Post = savedPosts[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Container(
                                decoration: customContainerDecoration(context),
                                child: ListTile(
                                  onTap: () {
                                    String postName = Post['postID'];
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Post_DetailPage(
                                          postName: postName,
                                        ),
                                      ),
                                    );
                                  },
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  title: Text(
                                    Post['Name'].toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 54, 43, 75)),
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
