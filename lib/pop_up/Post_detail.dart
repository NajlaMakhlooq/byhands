import 'package:byhands_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

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
  // Initially, the image URL is null, waiting to be fetched.
  String? description;

  List<Map<String, dynamic>> details = [
    {"no data": "no data"}
  ];
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    fetchPost();
  }

  // Function to fetch the image URL asynchronously
  Future<void> fetchPost() async {
    final response = await supabase
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
      final response =
          await supabase.from('Comment').select().eq('PostID', postID);

      setState(() {
        comments = (response as List<dynamic>?)
                ?.map((e) => {
                      'created_at': e['created_at'] ??
                          DateTime.now(), // Handle null values
                      'PostID': e['PostID'] ?? "",
                      'UserID': e['UserID'] ?? 00,
                      'Content': e['Content'] ?? 'Content',
                    })
                .toList() ??
            [];
      });
      print("comments : $comments");
    } catch (error) {
      print('Error fetching Comments: $error');
    }
  }

  Future<void> fetchPostDetails() async {
    try {
      final response =
          await supabase.from('Post').select().eq('Name', widget.postName);

      setState(() {
        details = (response as List<dynamic>?)
                ?.map((e) => {
                      'Name': e['Name'] ?? 'Unknown', // Handle null values
                      'Content_Text': e['Content_Text'] ?? 'No content',
                      'category': e['category'] ?? 'No category',
                      'username': e['username'] ?? 'Not mentioned',
                      'Post_url': e['Post_url'] ?? 'No post url',
                    })
                .toList() ??
            [];
      });
    } catch (error) {
      print('Error fetching Post: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = details[0];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: imageUrl == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Column(
                    children: [
                      Center(
                        child: Text(
                          widget.postName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Image.network(
                            imageUrl!, // Display the image once the URL is fetched
                            width: 250,
                            height: 250,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Align columns to left and right
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .end, // Align text within this column to the left
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "postd.name".tr(),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                              Text(
                                "postd.category".tr(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                "postd.provider".tr(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                "postd.content".tr(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            child: post.isEmpty
                                ? Center(
                                    child: Text(
                                      'postd.noPost'.tr(),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Align text within this column to the right
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          post['Name'].toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          post['category'].toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          post['username'].toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          post['Content_Text'].toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Container(
                              decoration: customContainerDecoration(context),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.message,
                                    color: Color.fromARGB(255, 54, 43, 75),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "postd.contact".tr(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 54, 43, 75),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            color: Color.fromARGB(255, 54, 43, 75),
                            onPressed: () {},
                            icon: Icon(Icons.favorite),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text("postd.comments".tr(),
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Expanded(
                    child: comments.isEmpty
                        ? Center(
                            child: Text("postd.nocomments".tr()),
                          )
                        : ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final commentdetails = comments[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Container(
                                  decoration:
                                      customContainerDecoration(context),
                                  child: ListTile(
                                    onTap: () {},
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    title: Row(
                                      children: [
                                        Image.network(
                                          supabase.storage
                                              .from('images')
                                              .getPublicUrl(
                                                  'images/profiles/${commentdetails['username']}/${commentdetails['username']}profile'),

                                          width:
                                              50, // Increased size for visibility
                                          height: 50,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return CircularProgressIndicator(); // Loading spinner
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                            ); // Fallback if image fails to load
                                          },
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          commentdetails['UserID'].toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 54, 43, 75)),
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
}
