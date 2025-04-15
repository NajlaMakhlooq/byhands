import 'package:byhands/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Post_DetailPage extends StatefulWidget {
  @override
  State<Post_DetailPage> createState() => _Post_DetailPageState();
  final String postName;

  const Post_DetailPage({super.key, required this.postName});
}

class _Post_DetailPageState extends State<Post_DetailPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  int postID = 0;
  String? imageUrl;
  String? description;
  String username = "";
  bool? liked;

  List<Map<String, dynamic>> details = [
    {"no data": "no data"},
  ];
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    fetchusername();
  }

  Future<void> fetchusername() async {
    final session = supabase.auth.currentSession;
    final user = session?.user;
    final email = user?.email;
    if (email != null) {
      final response =
          await supabase.from('User').select().eq('Email', email).maybeSingle();
      setState(() {
        username = response?['Username'] ?? "Unknown User";
      });
    }

    // Function to fetch the image URL asynchronously
    Future<void> fetchPost() async {
      final response =
          await supabase
              .from('Post')
              .select()
              .eq('Name', widget.postName)
              .maybeSingle();

      fetchPostDetails();

      if (response != null) {
        // Fetch the public URL for the image
        final imageUrlResponse = supabase.storage
            .from('images')
            .getPublicUrl('${response['Post_url']}');
        setState(() {
          imageUrl = imageUrlResponse; // Set the image URL once fetched
          postID = response['postID'];
        });
      }

      try {
        final response = await supabase
            .from('Comment')
            .select()
            .eq('PostID', postID);

        setState(() {
          comments =
              (response as List<dynamic>?)
                  ?.map(
                    (e) => {
                      'created_at':
                          e['created_at'] ??
                          DateTime.now(), // Handle null values
                      'PostID': e['PostID'] ?? "",
                      'username': e['username'] ?? "",
                      'Content': e['Content'] ?? 'Content',
                    },
                  )
                  .toList() ??
              [];
        });
      } catch (error) {
        print('❌ Error fetching Comments: $error');
      }
      Future<void> checkLiked() async {
        final checkLiked =
            await supabase
                .from('Saved_posts')
                .select()
                .eq('username', username)
                .eq('post_id', postID)
                .maybeSingle();

        if (checkLiked != null) {
          setState(() {
            liked = true;
          });
          print("⏳ liked? $liked");
        }
      }

      checkLiked();
    }

    fetchPost();
  }

  Future<void> fetchPostDetails() async {
    try {
      final response = await supabase
          .from('Post')
          .select()
          .eq('Name', widget.postName);

      setState(() {
        details =
            (response as List<dynamic>?)
                ?.map(
                  (e) => {
                    'Name': e['Name'] ?? 'Unknown', // Handle null values
                    'Content_Text': e['Content_Text'] ?? 'No content',
                    'category': e['category'] ?? 'No category',
                    'username': e['username'] ?? 'Not mentioned',
                    'Post_url': e['Post_url'] ?? 'No post url',
                  },
                )
                .toList() ??
            [];
      });
    } catch (error) {
      print('❌ Error fetching Post: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = details[0];
    String response = supabase.storage
        .from('images')
        .getPublicUrl(
          'images/profiles/${post['username']}/${post['username']}profile',
        );
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          widget.postName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body:
          imageUrl == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Column(
                      children: [
                        Divider(),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color.fromARGB(
                                    255,
                                    216,
                                    222,
                                    236,
                                  ), // desired border color
                                  width: 2, // Set the width of the border
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  216,
                                  222,
                                  236,
                                ),
                                backgroundImage: NetworkImage(
                                  username != ""
                                      ? '$response?t=${DateTime.now().millisecondsSinceEpoch}'
                                      : "",
                                ),
                                onBackgroundImageError: (error, stackTrace) {
                                  print('📛 Error loading image: $error');
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              post['username'].toString(),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: Image.network(
                              imageUrl!, // Display the image once the URL is fetched
                              width: 250,
                            ),
                          ),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              color: Color.fromARGB(255, 54, 43, 75),
                              onPressed: () {},
                              icon: Icon(Icons.comment),
                            ),
                            IconButton(
                              color:
                                  liked != true
                                      ? Color.fromARGB(255, 54, 43, 75)
                                      : Color.fromARGB(255, 213, 16, 16),
                              onPressed: () {
                                AddToSavedPosts();
                              },
                              icon: Icon(Icons.favorite),
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              color: Color.fromARGB(255, 54, 43, 75),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "category : ",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),

                                Text(
                                  post['username'].toString(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              child:
                                  post.isEmpty
                                      ? Center(
                                        child: Text(
                                          'No Post found.',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                        ),
                                      )
                                      : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start, // Align text within this column to the right
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              post['category'].toString(),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),

                                            Text(
                                              post['Content_Text'].toString(),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Comments",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "add comment",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          comments.isEmpty
                              ? Center(child: Text("No comments"))
                              : ListView.builder(
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final commentdetails = comments[index];
                                  String responseComment = supabase.storage
                                      .from('images')
                                      .getPublicUrl(
                                        'images/profiles/${commentdetails['username']}/${commentdetails['username']}profile',
                                      );
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    child: Container(
                                      decoration: UsersListContainerDecoration(
                                        context,
                                      ),
                                      child: ListTile(
                                        onTap: () {},
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        title: Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                    255,
                                                    216,
                                                    222,
                                                    236,
                                                  ), // desired border color
                                                  width:
                                                      2, // Set the width of the border
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                      255,
                                                      216,
                                                      222,
                                                      236,
                                                    ),
                                                backgroundImage: NetworkImage(
                                                  username != ""
                                                      ? '$responseComment?t=${DateTime.now().millisecondsSinceEpoch}'
                                                      : "",
                                                ),
                                                onBackgroundImageError: (
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  print(
                                                    '📛 Error loading image: $error',
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Column(
                                              children: [
                                                Text(
                                                  commentdetails['username']
                                                      .toString(),
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.bodyLarge,
                                                ),
                                                Text(
                                                  commentdetails['Content']
                                                      .toString(),
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.bodyMedium,
                                                ),
                                              ],
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
              ),
    );
  }

  Future<void> AddToSavedPosts() async {
    try {
      if (liked = true) {
        await supabase
            .from('Saved_posts')
            .delete()
            .eq('username', username)
            .eq('post_id', postID);

        setState(() {
          liked = false;
        });

        return; // Exit if the data is deleted
      } else {
        // Insert data into 'liked_course' table
        await Supabase.instance.client.from('Saved_posts').insert({
          'post_id': postID,
          'username': username,
        });
        setState(() {
          liked = true;
        });
        final formfield = GlobalKey<FormState>();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Saved successfully"),
              content: Form(
                key: formfield,
                child: SingleChildScrollView(
                  child: Text("The post Saved successfully"),
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("❌ Error : $e");
    }
  }
}
