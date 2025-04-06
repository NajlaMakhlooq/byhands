import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color.fromARGB(200, 54, 43, 75),
  scaffoldBackgroundColor: const Color.fromARGB(255, 251, 251, 252),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
        fontWeight: FontWeight.w900,
        color: const Color.fromARGB(255, 54, 43, 75),
        fontSize: 18),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w600,
      color: const Color.fromARGB(255, 54, 43, 75),
      fontSize: 15,
    ),
    bodySmall: TextStyle(
        fontWeight: FontWeight.w400,
        color: const Color.fromARGB(255, 54, 43, 75),
        fontSize: 12),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w900,
      color: const Color.fromARGB(255, 54, 43, 75),
      fontSize: 20,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w900,
      color: const Color.fromARGB(255, 54, 43, 75),
      fontSize: 24,
    ),
  ),
  buttonTheme: ButtonThemeData(
    textTheme: ButtonTextTheme.normal,
    minWidth: 88.0,
    height: 36.0,
    buttonColor: const Color.fromARGB(200, 54, 43, 75),
    disabledColor: const Color.fromARGB(200, 54, 43, 75),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color.fromARGB(255, 251, 251, 252),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color.fromARGB(200, 54, 43, 75),
  scaffoldBackgroundColor: Colors.grey[700],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[700],
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
        fontWeight: FontWeight.w900,
        color: const Color.fromARGB(255, 251, 251, 252),
        fontSize: 18),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w600,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 15,
    ),
    bodySmall: TextStyle(
      fontWeight: FontWeight.w400,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 12,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w900,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 20,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w900,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 24,
    ),
  ),
);

BoxDecoration customContainerDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 28, 28, 28) // Dark mode color
        : const Color.fromARGB(255, 216, 222, 236), // Light mode color
    borderRadius: BorderRadius.circular(12), // Rounded corners
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.grey,
        spreadRadius: 1,
        blurRadius: 4,
        offset: Offset(0, 2), // Shadow position
      ),
    ],
  );
}

InputDecoration textInputdecoration(BuildContext context, String text) {
  return InputDecoration(
    labelText: text,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  );
}
