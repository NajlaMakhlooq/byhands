import 'package:flutter/material.dart';
import 'package:byhands_application/menus/side_menu.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback toggleThemeMode;

  const SettingsPage({
    super.key,
    required this.toggleThemeMode,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false; // Tracks the state of the switch
  String selectedLanguage = 'en'; // Default language

  final Map<String, String> languages = {
    'en': 'English',
    'ar': 'العربية',
  };

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
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Home');
            },
            icon: const Icon(Icons.home),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 54, 43, 75),
          ),
        ),
      ),
      drawer: CommonDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            "Settings",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Dark Mode',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 10),
              Switch(
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                  widget.toggleThemeMode(); // Toggles the theme
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Language',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 20),
          Text(
            "Privacy Policy",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          Text(
            "1. Introduction",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            "This is where you explain the purpose of your app and how you handle user data.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            "2. Information Collection",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            "Detail the types of information you collect from users, such as personal details, app usage data, etc.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            "3. Use of Information",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            "Explain how you use the collected information to improve the user experience and provide services.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            "4. Data Security",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            "Describe the measures you take to protect user data from unauthorized access or disclosure.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            "5. User Rights",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            "Outline the rights users have regarding their data, such as the ability to access, modify, or delete their information.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            "6. Changes to the Privacy Policy",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            "Inform users that you may update the privacy policy and how they will be notified of any changes.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            "7. Contact Information",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            "Provide contact details for users to reach out with any questions or concerns regarding the privacy policy.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
