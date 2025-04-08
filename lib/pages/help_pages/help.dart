import 'package:byhands_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:byhands_application/menus/side_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  List<Map<String, dynamic>> FAQsList = [];
  final SupabaseClient supabase = Supabase.instance.client;
  int userID = 0;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchInformation();
  }

  Future<void> fetchInformation() async {
    // get the user email
    final session = supabase.auth.currentSession;
    final user = session?.user;
    final email = user?.email;
    if (email == null) {
      setState(
        () {
          userID = 0;
        },
      );
      return;
    }

    //use the email to search for username
    final response =
        await supabase.from('User').select().eq('Email', email).maybeSingle();
    setState(() {
      userID = response?['UserID'] ?? 0;
    });
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('FAQ').select();
      setState(() {
        FAQsList = (response as List<dynamic>?)
                ?.map(
                  (e) => {
                    'Question':
                        e['Question'] ?? 'Unknown', // Handle null values
                    'Answer': e['Answer'] ?? 'No answer available'
                  },
                )
                .toList() ??
            [];
      });
    } catch (error) {
      print('Error fetching FAQ: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text("Help", style: Theme.of(context).textTheme.titleLarge),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, '/Home');
              },
              icon: const Icon(Icons.home))
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Color.fromARGB(255, 54, 43, 75),
            )),
      ),
      drawer: CommonDrawer(),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Text(
              "Help & Support",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text("App Overview",
                  style: Theme.of(context).textTheme.titleLarge),
              onTap: () {
                Navigator.pushNamed(context, '/AppOverView');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text("How to Use",
                  style: Theme.of(context).textTheme.titleLarge),
              onTap: () {
                Navigator.pushNamed(context, '/HowTo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_support),
              title: Text("Contact Support",
                  style: Theme.of(context).textTheme.titleLarge),
              onTap: () {
                _contactUs(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: Text("Send Feedback",
                  style: Theme.of(context).textTheme.titleLarge),
              onTap: () {
                _NewFeedback(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_quote),
              title:
                  Text("FAQs", style: Theme.of(context).textTheme.titleLarge),
              onTap: () {
                _NewFAQs(context);
              },
            ),
            const SizedBox(height: 20),
            FAQsList.isEmpty
                ? Center(
                    child: Text('No FAQ found.'),
                  )
                : SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: FAQsList.length,
                      itemBuilder: (context, index) {
                        final category = FAQsList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Container(
                            decoration: customContainerDecoration(context),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              title: Text(
                                category['Question'] ?? 'Unknown Question',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                category['Answer'] ?? 'No Answer available',
                                style: Theme.of(context).textTheme.bodyMedium,
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

  void _NewFAQs(BuildContext context) {
    final formfield = GlobalKey<FormState>();
    final QuestionController = TextEditingController();

    Future<void> insertFAQ() async {
      try {
        await Supabase.instance.client.from('FAQ').insert({
          'Question': QuestionController.text,
        });
        print("Data inserted successfully");
      } catch (e) {
        print("Error inserting data: $e");
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add new question ?"),
          content: Form(
            key: formfield,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    QuestionController,
                    "Add your quastion !",
                    "Please enter your quastion",
                  ),
                  SizedBox(height: 15),
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
                  print("Success");
                  insertFAQ();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _contactUs(BuildContext context) {
    final formfield = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    final contentController = TextEditingController();

    Future<void> insertContent() async {
      try {
        await Supabase.instance.client.from('ContactUs').insert(
          {
            'UserID': userID,
            'reason': reasonController.text,
            'content': contentController.text
          },
        );
        print("Data inserted successfully");
      } catch (e) {
        print("Error inserting data: $e");
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Contact Us ?"),
          content: Form(
            key: formfield,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Phone : ",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    "+973 17000000",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "Email : ",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    "byhandsapplication@gmail.com",
                    style: Theme.of(context).textTheme.bodyMedium,
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
                  print("Success");
                  insertContent();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _NewFeedback(BuildContext context) {
    final formfield = GlobalKey<FormState>();
    final FeedbackController = TextEditingController();
    double Rating = 0;

    Future<void> insertFeedback() async {
      try {
        await Supabase.instance.client.from('Feedback').insert(
          {
            'user_id': userID,
            'feedback_content': FeedbackController.text,
            'rate': Rating,
          },
        );
        print("Data inserted successfully");
      } catch (e) {
        print("Error inserting data: $e");
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Feedback ?"),
          content: Form(
            key: formfield,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    FeedbackController,
                    "Your feedback",
                    "Please enter feedback",
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: RatingBar.builder(
                      initialRating: 1,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        Rating = rating;
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
                  print("Success");
                  insertFeedback();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      String validatorText) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        decoration: textInputdecoration(context, labelText).copyWith(
          prefixIcon: Icon(Icons.abc),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorText;
          }
          return null;
        },
      ),
    );
  }
}
