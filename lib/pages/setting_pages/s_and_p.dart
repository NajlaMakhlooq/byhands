import 'package:byhands/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as prefix;

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
  final supabase = prefix.Supabase.instance.client;
  bool isDarkMode = false;
  bool lang = false;
  String userPass = "";

  Future<void> deleteSupabaseUserData() async {
    final userEmail = supabase.auth.currentUser?.email;
    if (userEmail != null) {
      await supabase.from('User').delete().eq('Email', userEmail);
      final storage = supabase.storage.from('images');

      // Try downloading the file to check if it exists
      final response = await storage.download(
        'images/profiles/${widget.username}/${widget.username}profile',
      );

      if (response.isNotEmpty) {
        // Image exists, proceed to delete it
        final deleteResponse = await storage.remove([
          'images/profiles/${widget.username}',
        ]);

        if (deleteResponse.isNotEmpty) {
          // Success message
          print('Image deleted successfully');
        } else {
          // Error message during deletion
          print('Error deleting image: $deleteResponse');
        }
      } else {
        // Image does not exist
        print('Image does not exist: $response');
      }
      await prefix.Supabase.instance.client.from('Deleted_users').insert({
        'Email': userEmail,
      });
      await prefix.Supabase.instance.client.auth.signOut();
      print('✅ User data deleted from Supabase');
    }
  }

  Future<void> deleteFirebaseUser(String email, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Step 1: Re-authenticate
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);

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
            print(
              "🗑 Document with username ${widget.username} deleted successfully!",
            );
            print('✅ User data deleted from firebase');
          }
        } else {
          print("❌ No document found");
        }

        // Step 3: Delete user from Firebase Auth
        await user.delete();
        await FirebaseAuth.instance.signOut();
        print('✅ Firebase user deleted successfully');
      }
    } catch (e) {
      print('❌ Error deleting Firebase user: $e');
    }
  }

  Future<void> deleteUserAccount() async {
    final userEmail = supabase.auth.currentUser?.email;
    if (userEmail == null || userPass.isEmpty) return;

    final response =
        await supabase
            .from('User')
            .select('Password')
            .eq('Email', userEmail)
            .maybeSingle();

    if (response?['Password'] == userPass) {
      print("✅ Passwords match. Proceeding with deletion...");
      await deleteSupabaseUserData();
      print("🔐 Reauthenticating with: $userEmail / $userPass");
      await deleteFirebaseUser(userEmail, userPass);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deleted successfully.")),
      );
    } else {
      print("❌ Password mismatch. Account deletion aborted.");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Incorrect password.")));
    }
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
        print("userpassword : $userPass");
      });
      await deleteUserAccount();
      Navigator.pushNamedAndRemoveUntil(context, '/Start', (route) => false);
      print("✅ Successfully deleted account");
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.popAndPushNamed(context, '/Home'),
          ),
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(255, 135, 128, 139)
                    : const Color.fromARGB(255, 203, 194, 205),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: CommonDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text("Settings", style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          Row(
            children: [
              Text('Dark Mode', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 10),
              Switch(
                value: isDarkMode,
                onChanged: (value) {
                  setState(() => isDarkMode = value);
                  widget.toggleThemeMode();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Language', style: Theme.of(context).textTheme.titleMedium),
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
              Text('Text Size', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () => _showPasswordDialogAndDeleteAccount(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 54, 43, 75),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                "Delete account",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildPrivacyPolicy(context),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Privacy Policy", style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        _policySection(
          "1. Introduction",
          "This is where you explain the purpose of your app and how you handle user data.",
        ),
        _policySection(
          "2. Information Collection",
          "Detail the types of information you collect from users, such as personal details, app usage data, etc.",
        ),
        _policySection(
          "3. Use of Information",
          "Explain how you use the collected information to improve the user experience and provide services.",
        ),
        _policySection(
          "4. Data Security",
          "Describe the measures you take to protect user data from unauthorized access or disclosure.",
        ),
        _policySection(
          "5. User Rights",
          "Outline the rights users have regarding their data, such as the ability to access, modify, or delete their information.",
        ),
        _policySection(
          "6. Changes to the Privacy Policy",
          "Inform users that you may update the privacy policy and how they will be notified of any changes.",
        ),
        _policySection(
          "7. Contact Information",
          "Provide contact details for users to reach out with any questions or concerns regarding the privacy policy.",
        ),
      ],
    );
  }

  Widget _policySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 5),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
