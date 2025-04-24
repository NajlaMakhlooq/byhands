import 'package:byhands_application/pop_up/Post_detail.dart';
import 'package:byhands_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class Posts extends StatefulWidget {
  final String userName;
  const Posts({super.key, required this.userName});

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  int userId = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response =
          await supabase.from('Post').select().eq('username', widget.userName);

      posts = (response as List<dynamic>)
          .map((post) => {
                'Name': post['Name'] ?? 'Unknown',
              })
          .toList();
    } catch (error) {
      print('Error fetching Courses: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? Center(
                  child: Text('post.noPosts'.tr()),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(
                      post: post,
                      username: widget.userName,
                    );
                  },
                ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final String username;
  const PostCard({super.key, required this.post, required this.username});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Container(
        decoration: customContainerDecoration(context),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Post_DetailPage(
                  postName: widget.post['Name'],
                ),
              ),
            );
          },
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          title: Row(
            children: [
              Image.network(
                supabase.storage.from('images').getPublicUrl(
                    'images/posts/${widget.username}/${widget.post['Name']}'),
                width: 50, // Increased size for visibility
                height: 50,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return CircularProgressIndicator(); // Loading spinner
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ); // Fallback if image fails to load
                },
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                widget.post['Name'] ?? 'Unknown Course',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 54, 43, 75)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
