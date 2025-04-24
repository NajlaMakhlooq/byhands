import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: camel_case_types
class mainMenu extends StatelessWidget {
  final int index;
  const mainMenu(this.index, {super.key});

  @override
  Widget build(BuildContext context) => GNav(
        haptic: true,
        tabBorderRadius: 20,
        curve: Curves.easeOutExpo,
        duration: const Duration(milliseconds: 80),
        gap: 0,
        color: const Color.fromARGB(255, 54, 43, 75),
        activeColor: const Color.fromARGB(255, 54, 43, 75),
        iconSize: 25,
        tabBackgroundColor: const Color.fromARGB(255, 247, 246, 251),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        selectedIndex: index,
        tabs: [
          GButton(
            icon: Icons.dashboard,
            text: 'menu.dashboard'.tr(),
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Home');
            },
          ),
          GButton(
            icon: Icons.list,
            text: 'menu.category'.tr(),
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Categories');
            },
          ),
          GButton(
            icon: Icons.add_a_photo,
            text: 'menu.camera'.tr(),
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Camera');
            },
          ),
          GButton(
            icon: Icons.menu_book,
            text: 'menu.courses'.tr(),
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Courses');
            },
          ),
          GButton(
            icon: Icons.chat,
            text: 'menu.chats'.tr(),
            onPressed: () {
              Navigator.popAndPushNamed(context, '/Chats');
            },
          ),
        ],
      );
}
