import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:byhands_application/services/auth_service.dart';

class CommonDrawer extends StatefulWidget {
  const CommonDrawer({super.key});

  @override
  State<CommonDrawer> createState() => _CommonDrawerState();
}

class _CommonDrawerState extends State<CommonDrawer> {
  final SupabaseClient supabase = Supabase.instance.client; // open the database
  String username = "";
  String url_profile = "";
  bool loading = true; // Add loading state
  final authService = AuthService();

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
    final session = supabase.auth.currentSession;
    final user = session?.user;
    final email = user?.email;

    if (email == null) {
      setState(() {
        username = "No user logged in";
      });
      return;
    }

    final response = await supabase
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
      url_profile = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator if data is not yet fetched
    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    // Once data is loaded, render the drawer
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildHeader(context),
          buildMenuItems(context),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) => Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        color: const Color.fromARGB(255, 54, 43, 75),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    await authService.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/Start', (route) => false);
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
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: const Color.fromARGB(255, 216, 222, 236),
                  backgroundImage: NetworkImage(url_profile),
                  onBackgroundImageError: (error, stackTrace) {
                    print('Error loading image: $error');
                  },
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
            const SizedBox(
              height: 10,
            ),
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
              title: Text(
                'Profile',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_rounded),
              title: Text(
                'Liked courses',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, '/likedcourses');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: Text(
                'Saved Posts',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, '/Savedposts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(
                "Notifications",
                style: Theme.of(context).textTheme.bodyMedium,
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
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, '/SandP');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: Text(
                'Help',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, '/Help');
              },
            ),
          ],
        ),
      );
}
