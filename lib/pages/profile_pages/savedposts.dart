import 'package:byhands/theme.dart';
import 'package:flutter/material.dart';
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:byhands/pages/posts/Post_detail.dart';

// ignore: camel_case_types
class Saved_posts extends StatefulWidget {
  Saved_posts({super.key, required this.username});
  String username;

  @override
  State<Saved_posts> createState() => _Saved_posts();
}

class _Saved_posts extends State<Saved_posts> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> savedPosts = [];
  bool isLoading = true; // To show a loading indicator

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await supabase
          .from('Saved_posts')
          .select()
          .eq('username', widget.username);

      List<int> Saved_postsId =
          (response as List<dynamic>?)
              ?.map((e) => e['post_id'] as int)
              .toList() ??
          [];
      for (int i = 0; i < Saved_postsId.length; i++) {
        final response =
            await supabase
                .from('Post')
                .select()
                .eq('postID', Saved_postsId[i])
                .single(); // Fetch a single item

        savedPosts.add(response);
      }
      setState(() {
        isLoading = false;
      });
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
            icon: const Icon(Icons.home),
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
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : Column(
                children: [
                  Expanded(
                    child:
                        savedPosts.isEmpty
                            ? Center(child: Text('No Posts Saved.'))
                            : ListView.builder(
                              itemCount: savedPosts.length,
                              itemBuilder: (context, index) {
                                final Post = savedPosts[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  child: Container(
                                    decoration: customContainerDecoration(
                                      context,
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        String postName = Post['Name'];
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => Post_DetailPage(
                                                  postName: postName,
                                                ),
                                          ),
                                        );
                                      },
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      title: Row(
                                        children: [
                                          Image.network(
                                            supabase.storage
                                                .from('images')
                                                .getPublicUrl(
                                                  '${Post['Post_url']}',
                                                ),
                                            width:
                                                50, // Increased size for visibility
                                            height: 50,
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return CircularProgressIndicator(); // Loading spinner
                                            },
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                              ); // Fallback if image fails to load
                                            },
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            Post['Name'] ?? 'Unknown Post',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                255,
                                                54,
                                                43,
                                                75,
                                              ),
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
