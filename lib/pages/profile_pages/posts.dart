import 'package:byhands/pages/posts/Post_detail.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Posts extends StatefulWidget {
  final String userName;
  const Posts({super.key, required this.userName});

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final SupabaseClient supabase = Supabase.instance.client; // open the database

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
      final response = await supabase
          .from('Post')
          .select()
          .eq('username', widget.userName);

      posts =
          (response as List<dynamic>)
              .map((post) => {'Name': post['Name'] ?? 'Unknown'})
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : posts.isEmpty
              ? Center(child: Text('No Posts provided.'))
              : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostCard(post: post, username: widget.userName);
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
  final SupabaseClient supabase = Supabase.instance.client; // open the database

  @override
  Widget build(BuildContext context) {
    String response = supabase.storage
        .from('images')
        .getPublicUrl('images/posts/${widget.username}/${widget.post['Name']}');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => Post_DetailPage(postName: widget.post['Name']),
            ),
          );
        },
        child: Image.network(
          '$response?t=${DateTime.now().millisecondsSinceEpoch}',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
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
      ),
    );
  }
}
