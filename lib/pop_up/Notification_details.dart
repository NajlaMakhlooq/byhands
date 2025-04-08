import 'package:byhands_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationDetailPage extends StatefulWidget {
  final String title;

  const NotificationDetailPage({super.key, required this.title});

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPage();
}

class _NotificationDetailPage extends State<NotificationDetailPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  int userid = 0;
  List<Map<String, dynamic>> NotificationsDetails = [];
  bool isLoading = true; // To show a loading indicator

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

        // Fetch the liked courses after obtaining UserID
        await fetchNotification();
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

  Future<void> fetchNotification() async {
    try {
      final response = await supabase
          .from('Notifications')
          .select()
          .eq('title', widget.title);

      setState(() {
        NotificationsDetails = (response as List<dynamic>?)
                ?.map((e) => {
                      'title': e['title'] ?? 'Unknown', // Handle null values
                      'desc': e['desc'] ?? 'No description available',
                    })
                .toList() ??
            [];
      });
    } catch (error) {
      print('Error fetching Notifications: $error');
    } finally {
      setState(() {
        isLoading = false; // Stop loading regardless of success or failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (NotificationsDetails.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(widget.title),
        ),
      );
    }

    final notification = NotificationsDetails[0];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(widget.title),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
              children: <Widget>[
                Icon(
                  Icons.notifications,
                  size: 60,
                  color: Color.fromARGB(255, 54, 43, 75),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: Center(
                    child: Text(
                      notification['title'].toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Color.fromARGB(255, 54, 43, 75)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Container(
                    decoration: customContainerDecoration(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        notification['desc'].toString(),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
    );
  }
}
