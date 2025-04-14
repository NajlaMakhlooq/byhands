import 'package:byhands/pages/menus/side_menu.dart';
import 'package:flutter/material.dart';

class HowTo extends StatelessWidget {
  HowTo({super.key});
  final List<Map<String, String>> HowToUse = [
    {
      'name': 'Navigating the App',
      'desc':
          'To navigate through the app, use the menu on the left side. Tap the menu icon on the top left to open the side menu.',
    },
    {
      'name': 'Viewing Help',
      'desc':
          'If you need help, you can find the Help section in the side menu. This section provides information on how to use the app and get support.',
    },
    {
      'name': 'Submitting Feedback',
      'desc':
          'To submit feedback, navigate to the Feedback section from the side menu. Fill out the form with your feedback and tap Submit.',
    },
    {
      'name': 'FAQs',
      'desc':
          'The FAQ section contains frequently asked questions and their answers. You can access this section from the side menu.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("How to Use"),
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
        ),
      ),
      drawer: CommonDrawer(),
      body: ListView.builder(
        itemCount: HowToUse.length,
        itemBuilder: (context, index) {
          final item = HowToUse[index];
          return ExpansionTile(
            title: Text(
              item['name'] ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  item['desc'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
