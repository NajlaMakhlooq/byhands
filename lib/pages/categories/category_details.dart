import 'package:byhands/pages/posts/Post_detail.dart';
import 'package:byhands/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryName;

  const CategoryDetailPage({super.key, required this.categoryName});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  String? imageUrl; // Initially, the image URL is null, waiting to be fetched.
  String? description;
  List<Map<String, dynamic>> details = [];

  @override
  void initState() {
    super.initState();
    fetchCategoryName();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await supabase
          .from('Post')
          .select()
          .eq('category', widget.categoryName);

      details =
          (response as List<dynamic>)
              .map(
                (post) => {
                  'Content_Text': post['Content_Text'] ?? 'Unknown',
                  'category': post['category'] ?? 'No category available',
                  'Name': post['Name'] ?? 'Unknown',
                  'username': post['username'] ?? 'Unknown',
                  'Post_url': post['Post_url'] ?? '',
                },
              )
              .toList();
    } catch (error) {
      print('❌ Error fetching Posts: $error');
    }
  }

  // Function to fetch the image URL asynchronously
  Future<void> fetchCategoryName() async {
    final response =
        await supabase
            .from('categories')
            .select()
            .eq('Name', widget.categoryName)
            .maybeSingle();

    if (response != null) {
      String icon = response['icon'];
      if (icon.isNotEmpty) {
        // Fetch the public URL for the image
        final imageUrlResponse = supabase.storage
            .from('images')
            .getPublicUrl('categories/$icon');
        setState(() {
          imageUrl = imageUrlResponse; // Set the image URL once fetched
          description = response['Description'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body:
          imageUrl == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Center(
                          child: Image.network(
                            imageUrl!, // Display the image once the URL is fetched
                            width: 50,
                            height: 50,
                          ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            // Display the category name right away without waiting for the image.
                            Center(
                              child: Text(
                                widget.categoryName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 54, 43, 75),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Center(
                      child: Text(
                        description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 54, 43, 75),
                        ),
                      ),
                    ),
                    Divider(color: Color.fromARGB(200, 54, 43, 75), height: 20),
                    details.isEmpty
                        ? Center(child: Text('No Posts provided.'))
                        : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: details.length,
                            itemBuilder: (context, index) {
                              final post = details[index];
                              return PostCard(post: post);
                            },
                          ),
                        ),
                  ],
                ),
              ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

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
                builder:
                    (context) => Post_DetailPage(postName: widget.post['Name']),
              ),
            );
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 3,
          ),
          title: Row(
            children: [
              Image.network(
                supabase.storage
                    .from('images')
                    .getPublicUrl('${widget.post['Post_url']}'),
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
              SizedBox(width: 10),
              Text(
                widget.post['Name'] ?? 'Unknown Course',
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
  }
}
