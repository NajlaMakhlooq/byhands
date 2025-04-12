import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// ignore: camel_case_types
class mainMenu extends StatelessWidget {
  final int index;
  const mainMenu(this.index, {super.key});
  @override
  Widget build(BuildContext context) => GNav(
        haptic: true, // haptic feedback
        tabBorderRadius: 20,
        curve: Curves.easeOutExpo, // tab animation curves
        duration: const Duration(milliseconds: 80), // tab animation duration
        gap: 0, // the tab button gap between icon and text
        color: const Color.fromARGB(255, 54, 43, 75), // unselected icon color
        activeColor: const Color.fromARGB(255, 54, 43, 75),
        iconSize: 25, // tab button icon size
        tabBackgroundColor: const Color.fromARGB(
            255, 247, 246, 251), // selected tab background color
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        selectedIndex: index,
        tabs: [
          GButton(
            icon: Icons.dashboard,
            text: 'Dashboard',
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Home');
            },
          ),
          GButton(
            icon: Icons.list,
            text: 'Category',
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Categories');
            },
          ),
          GButton(
            icon: Icons.add_a_photo,
            text: 'Camera',
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Camera');
            },
          ),
          GButton(
            icon: Icons.menu_book,
            text: 'Courses',
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Courses');
            },
          ),
          GButton(
            icon: Icons.chat,
            text: 'Chats',
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Chats');
            },
          ),
        ],
      );
}
