import 'package:byhands/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;

// ignore: camel_case_types
class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _Notifications();
}

class _Notifications extends State<Notifications> {
  final prefix.SupabaseClient supabase = prefix.Supabase.instance.client;
  int userid = 0;
  List<Map<String, dynamic>> Notifications = [];
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
      final User? user = FirebaseAuth.instance.currentUser;
      final String? email = user?.email;

      if (email == null) {
        setState(() {
          userid = 0;
          isLoading = false; // Stop loading if no email found
        });
        return;
      }

      // Fetch UserID based on the email
      final response =
          await supabase
              .from('User')
              .select('UserID')
              .eq('Email', email)
              .maybeSingle();

      if (response != null && response.containsKey('UserID')) {
        setState(() {
          userid = response['UserID'];
        });

        // Fetch the Saved courses after obtaining UserID
        await fetchNotifications();
      } else {
        setState(() {
          userid = 0;
        });
      }
    } catch (error) {
      print("❌ Error fetching UserID: $error");
    } finally {
      setState(() {
        isLoading = false; // Stop loading regardless of success or failure
      });
    }
  }

  Future<void> fetchNotifications() async {
    try {
      // Fetch Saved course IDs for the user
      final response = await supabase
          .from('Notifications')
          .select()
          .eq('user_id', userid);

      List<String> noti_title =
          (response as List<dynamic>?)
              ?.map((e) => e['title'] as String)
              .toList() ??
          [];

      for (String title in noti_title) {
        final courseResponse =
            await supabase
                .from('Notifications')
                .select()
                .eq('title', title)
                .single();

        Notifications.add(courseResponse);
      }
    } catch (error) {
      print('❌ Error fetching Notifications: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          "Notifications",
          style: Theme.of(context).textTheme.titleLarge,
        ),
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
                        Notifications.isEmpty
                            ? Center(
                              child: Text(
                                'No Notifications.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            )
                            : ListView.builder(
                              itemCount: Notifications.length,
                              itemBuilder: (context, index) {
                                final titleNotification = Notifications[index];
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
                                      onTap: () {},
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      title: Row(
                                        children: [
                                          Icon(
                                            Icons.notifications,
                                            size: 30,
                                            color: Color.fromARGB(
                                              255,
                                              54,
                                              43,
                                              75,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            titleNotification['title']
                                                .toString(),
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge,
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        titleNotification['desc'].toString(),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
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
