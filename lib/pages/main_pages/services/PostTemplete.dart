import 'package:flutter/material.dart';

class Posttemplete extends StatefulWidget {
  const Posttemplete({super.key});

  @override
  State<Posttemplete> createState() => _Posttemplete();
}

class _Posttemplete extends State<Posttemplete> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 135, 128, 139) // Dark mode color
                : const Color.fromARGB(255, 203, 194, 205), // Light mode color
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Post",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 320,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.1),
                  border: Border.all(
                    color: Color.fromARGB(255, 54, 43, 75),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 6,
                    ),
                    Container(
                      height: 260,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.1),
                        border: Border.all(
                          color: Color.fromARGB(255, 54, 43, 75),
                          width: 2,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.favorite,
                            color: Color.fromARGB(255, 54, 43, 75),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.chat,
                            color: Color.fromARGB(255, 54, 43, 75),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.bookmark,
                            color: Color.fromARGB(255, 54, 43, 75),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
