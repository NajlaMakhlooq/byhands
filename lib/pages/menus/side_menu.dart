import 'package:byhands/pages/profile_pages/savedposts.dart';
import 'package:byhands/services/auth/auth_service.dart';
import 'package:byhands/pages/setting_pages/s_and_p.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;

class CommonDrawer extends StatefulWidget {
  const CommonDrawer({super.key});

  @override
  State<CommonDrawer> createState() => _CommonDrawerState();
}

class _CommonDrawerState extends State<CommonDrawer> {
  final prefix.SupabaseClient supabase =
      prefix.Supabase.instance.client; // open the database
  final authService = AuthService();

  ThemeMode _themeMode = ThemeMode.light;
  void toggleThemeModeSwitch() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  String username = "";
  String url_profile = "";
  bool loading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      loading = true; // Indicate loading
    });

    await fetchUsername();
    await getURL();

    setState(() {
      loading = false; // Set loading to false once done
    });
  }

  Future<void> fetchUsername() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;

    if (email == null) {
      setState(() {
        username = "No user logged in";
      });
      return;
    }

    final response =
        await supabase
            .from('User')
            .select('Username')
            .eq('Email', email)
            .maybeSingle();

    setState(() {
      username = response?['Username'] ?? "Unknown User";
    });
  }

  Future<void> getURL() async {
    final response = supabase.storage
        .from('images')
        .getPublicUrl('images/profiles/$username/${username}profile');

    setState(() {
      url_profile = '$response?t=${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator if data is not yet fetched
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    // Once data is loaded, render the drawer
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[buildHeader(context), buildMenuItems(context)],
      ),
    );
  }

  Widget buildHeader(BuildContext context) => Container(
    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
    color: const Color.fromARGB(255, 102, 102, 103),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                AuthService authService = AuthService();
                await authService.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/Start',
                  (route) => false,
                );
              },
              child: Row(
                children: [
                  Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.logout, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color.fromARGB(255, 216, 222, 236), // border color
                  width: 2, // Set the width of the border
                ),
              ),
              child: CircleAvatar(
                radius: 42,
                backgroundColor: const Color.fromARGB(255, 216, 222, 236),
                backgroundImage: NetworkImage(url_profile),
                onBackgroundImageError: (error, stackTrace) {
                  print('📛 Error loading image: $error');
                },
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    ),
  );

  Widget buildMenuItems(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    child: Wrap(
      runSpacing: 1,
      children: [
        ListTile(
          leading: const Icon(Icons.person_rounded),
          title: Text('Profile', style: Theme.of(context).textTheme.labelSmall),
          onTap: () {
            Navigator.popAndPushNamed(context, '/profile');
          },
        ),
        ListTile(
          leading: const Icon(Icons.bookmark),
          title: Text(
            'Saved courses',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          onTap: () {
            Navigator.popAndPushNamed(context, '/Savedcourses');
          },
        ),
        ListTile(
          leading: const Icon(Icons.favorite_rounded),
          title: Text(
            'Liked Posts',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Liked_posts(username: username),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: Text(
            "Notifications",
            style: Theme.of(context).textTheme.labelSmall,
          ),
          onTap: () {
            Navigator.pushNamed(context, '/Notification');
          },
        ),
        const Divider(color: Color.fromARGB(200, 54, 43, 75)),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text(
            'Setting & policy',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => SettingsPage(
                      toggleThemeMode:
                          toggleThemeModeSwitch, // ✅ Pass the callback
                      username: username,
                    ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: Text('Help', style: Theme.of(context).textTheme.labelSmall),
          onTap: () {
            Navigator.popAndPushNamed(context, '/Help');
          },
        ),
      ],
    ),
  );
}
