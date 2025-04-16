import 'package:byhands/theme/ThemeCubit.dart';
import 'package:byhands/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;
import 'package:byhands/theme/globals.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback toggleThemeMode;
  String username;

  SettingsPage({
    super.key,
    required this.toggleThemeMode,
    required this.username,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<Map<String, String>> policy = [
    {
      'name': "1. Introduction",

      'desc':
          "This is where you explain the purpose of your app and how you handle user data.",
    },
    {
      'name': "2. Information Collection",

      'desc':
          "Detail the types of information you collect from users, such as personal details, app usage data, etc.",
    },
    {
      'name': "3. Use of Information",
      'desc':
          "Explain how you use the collected information to improve the user experience and provide services.",
    },
    {
      'name': "4. Data Security",

      'desc':
          "Describe the measures you take to protect user data from unauthorized access or disclosure.",
    },
    {
      'name': "5. User Rights",

      'desc':
          "Outline the rights users have regarding their data, such as the ability to access, modify, or delete their information.",
    },
    {
      'name': "6. Changes to the Privacy Policy",
      'desc':
          "Inform users that you may update the privacy policy and how they will be notified of any changes.",
    },
  ];
  final supabase = prefix.Supabase.instance.client;
  bool lang = false;
  String userPass = "";
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> deleteSupabaseUserData() async {
    final String? email = user?.email;
    if (email != null) {
      await supabase.from('User').delete().eq('Email', email);
      final storage = supabase.storage.from('images');

      // Try downloading the file to check if it exists
      final response = await storage.download(
        'images/profiles/${widget.username}/${widget.username}profile',
      );

      if (response.isNotEmpty) {
        // Image exists, proceed to delete it
        await storage.remove(['images/profiles/${widget.username}']);
      } else {
        // Image does not exist
        print('📛 Image does not exist: $response');
      }
      await supabase.auth.signOut();
      print('✅🗑️ User data deleted from Supabase');
    }
  }

  Future<void> deleteFirebaseUser(String email) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("🔄🔐 Reauthenticating with: $email / $userPass");
        // Step 1: Re-authenticate

        try {
          final signInUser = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: userPass);
          print(
            "🔄🔐✅ Reauthentication successful with ${signInUser.user!.email}",
          );
        } on FirebaseAuthException catch (e) {
          print("🔄🔐❌ Reauthentication failed: ${e.code} - ${e.message}");
        }
        // Step 2: Delete Firestore data
        // Get documents where the email field matches the provided email
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance
                .collection('Users')
                .where('username', isEqualTo: widget.username)
                .get();
        // If there are any documents matching the query, delete them
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            await doc.reference.delete();
            print('✅🗑️ User data deleted from firebase');
          }
        } else {
          print("❌ No document found");
        }
        // Step 3: Delete user from Firebase Auth
        await user.delete();
        await FirebaseAuth.instance.signOut();
        print('✅🗑️ Firebase user deleted successfully');
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
    } catch (e) {
      print('❌ General error deleting user: $e');
    }
  }

  Future<void> deleteUserAccount() async {
    final String? email = user?.email;
    await deleteSupabaseUserData();
    await deleteFirebaseUser(email!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "✅🗑️🎉 Account deleted successfully.🎉🗑️✅",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Future<void> _showPasswordDialogAndDeleteAccount(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final passController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Password"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: passController,
              obscureText: true,
              decoration: textInputdecoration(
                context,
                "Enter password...",
              ).copyWith(prefixIcon: const Icon(Icons.lock)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Password required to delete account.";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, passController.text);
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        userPass = result;
      });
      await deleteUserAccount();
      Navigator.pushNamedAndRemoveUntil(context, '/Start', (route) => false);
      print("✅🗑️ Successfully deleted account");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          "Setting and privacy",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            color: Theme.of(context).iconTheme.color,
            iconSize: 30,
            onPressed: () => Navigator.popAndPushNamed(context, '/Home'),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: CommonDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Settings", style: Theme.of(context).textTheme.labelLarge),
            const Divider(),
            Row(
              children: [
                Text(
                  'Dark Mode',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(width: 10),
                Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (_) {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Language',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(width: 10),
                Switch(
                  value: lang,
                  onChanged: (value) => setState(() => lang = value),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Text Size',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                ValueListenableBuilder<double>(
                  valueListenable: textScaleNotifier,
                  builder: (context, scale, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Text Size: ${(scale * 100).toInt()}%'),
                        Slider(
                          value: scale,
                          min: 0.8,
                          max: 1.2,
                          divisions: 4,
                          label: '${(scale * 100).toInt()}%',
                          onChanged: (newScale) {
                            textScaleNotifier.value = newScale;
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () => _showPasswordDialogAndDeleteAccount(context),
                style: CustomElevatedButtonTheme(context),
                child: const Text("Delete account"),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Privacy Policy",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Divider(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ), // Optional padding
                child: ListView.builder(
                  itemCount: policy.length,
                  itemBuilder: (context, index) {
                    final item = policy[index];
                    return ExpansionTile(
                      title: Text(
                        item['name'] ?? '',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            item['desc'] ?? '',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
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
}
