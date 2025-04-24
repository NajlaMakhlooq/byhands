import 'package:flutter/material.dart';
import 'package:byhands_application/menus/side_menu.dart';
import 'package:byhands_application/theme.dart';
import 'package:easy_localization/easy_localization.dart';

class App_Overview extends StatelessWidget {
  const App_Overview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text("app_overview.title".tr()),
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
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 54, 43, 75),
          ),
        ),
      ),
      drawer: const CommonDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: <Widget>[
          Center(
            child: Text(
              "app_overview.title".tr(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 54, 43, 75),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: customContainerDecoration(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "app_overview.description1".tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "app_overview.description2".tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "app_overview.description3".tr(),
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
