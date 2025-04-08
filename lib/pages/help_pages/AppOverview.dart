import 'package:byhands_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:byhands_application/menus/side_menu.dart';

class App_Overview extends StatelessWidget {
  const App_Overview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("App Overview"),
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
        padding: const EdgeInsets.all(10.0),
        children: <Widget>[
          Center(
            child: const Text(
              "App Overview",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 54, 43, 75),
              ),
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Container(
            decoration: customContainerDecoration(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "By Hands is a mobile application designed to bring together talented individuals and hobbyists in Bahrain, providing a dedicated social media platform for networking, collaboration, and sharing creative works.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "This application serves as a digital hub where users with similar interests can connect, interact, and showcase their skills in various fields such as art, music, photography, writing, and more.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Through By Hands, talented individuals in Bahrain can gain visibility, find inspiration, and form valuable connections with like-minded people, ultimately enriching the creative landscape of the country.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
