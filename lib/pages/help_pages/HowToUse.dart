import 'package:flutter/material.dart';
import 'package:byhands_application/menus/side_menu.dart';

class HowTo extends StatelessWidget {
  const HowTo({super.key});

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
          )
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          const Text(
            "How to Use the App",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Navigating the App"),
          const Text(
            "To navigate through the app, use the menu on the left side. Tap the menu icon on the top left to open the side menu.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Viewing Help"),
          const Text(
            "If you need help, you can find the Help section in the side menu. This section provides information on how to use the app and get support.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Submitting Feedback"),
          const Text(
            "To submit feedback, navigate to the Feedback section from the side menu. Fill out the form with your feedback and tap Submit.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("FAQs"),
          const Text(
            "The FAQ section contains frequently asked questions and their answers. You can access this section from the side menu.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}
