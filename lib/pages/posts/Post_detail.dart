import 'package:byhands/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;

class Post_DetailPage extends StatefulWidget {
  @override
  State<Post_DetailPage> createState() => _Post_DetailPageState();
  final String postName;

  const Post_DetailPage({super.key, required this.postName});
}

class _Post_DetailPageState extends State<Post_DetailPage> {
  final prefix.SupabaseClient supabase = prefix.Supabase.instance.client;
  int postID = 0;
  String? imageUrl;
  String? description;
  String username = "";
  bool? Liked;

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
    final User? user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;
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

      await fetchPostDetails();

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
      Future<void> checkSaved() async {
        final checkSaved =
            await supabase
                .from('Liked_posts')
                .select()
                .eq('username', username)
                .eq('post_id', postID)
                .maybeSingle();

        if (checkSaved != null) {
          setState(() {
            Liked = true;
          });
          print("⏳ Saved? $Liked");
        }
      }

      checkSaved();
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
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.arrow_back,
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
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body:
          imageUrl == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                                  response != ""
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
                                  Liked != true
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
                            onPressed: () {
                              _NewComment(context);
                            },
                            child: Text(
                              "add comment",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: SizedBox(
                        child:
                            comments.isEmpty
                                ? Center(child: Text("No comments"))
                                : ListView.builder(
                                  shrinkWrap: true, // Important!
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
                                        decoration:
                                            UsersListContainerDecoration(
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
                                                    responseComment != ""
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
                    ),
                  ],
                ),
              ),
    );
  }

  void _NewComment(BuildContext context) {
    final formfield = GlobalKey<FormState>();
    final CommentController = TextEditingController();

    Future<void> insertComment() async {
      try {
        await supabase.from('Comment').insert({
          'PostID': postID,
          'Content': CommentController.text,
          'username': username,
        });
      } catch (e) {
        print("❌🗂️ Error inserting data: $e");
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("New Comment"),
          content: Form(
            key: formfield,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: TextFormField(
                      controller: CommentController,
                      decoration: textInputdecoration(
                        context,
                        "Write Comment here",
                      ).copyWith(prefixIcon: Icon(Icons.abc)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your comment first";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
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
                // Insert Data
                if (formfield.currentState!.validate()) {
                  insertComment();
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              Post_DetailPage(postName: widget.postName),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> AddToSavedPosts() async {
    try {
      if (Liked = true) {
        await supabase
            .from('Liked_posts')
            .delete()
            .eq('username', username)
            .eq('post_id', postID);

        setState(() {
          Liked = false;
        });

        return; // Exit if the data is deleted
      } else {
        // Insert data into 'Liked_posts' table
        await supabase.from('Liked_posts').insert({
          'post_id': postID,
          'username': username,
        });
        setState(() {
          Liked = true;
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
