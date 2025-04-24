import 'package:flutter/material.dart';

TextTheme scaleTextTheme(TextTheme base, double scale) {
  return TextTheme(
    bodySmall: base.bodySmall?.copyWith(
      fontSize: (base.bodySmall?.fontSize ?? 14) * scale,
    ),
    bodyMedium: base.bodyMedium?.copyWith(
      fontSize: (base.bodyMedium?.fontSize ?? 14) * scale,
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      fontSize: (base.bodyLarge?.fontSize ?? 14) * scale,
    ),
    labelSmall: base.labelSmall?.copyWith(
      fontSize: (base.labelSmall?.fontSize ?? 14) * scale,
    ),
    labelMedium: base.labelMedium?.copyWith(
      fontSize: (base.labelMedium?.fontSize ?? 14) * scale,
    ),
    labelLarge: base.labelLarge?.copyWith(
      fontSize: (base.labelLarge?.fontSize ?? 14) * scale,
    ),
    titleSmall: base.titleSmall?.copyWith(
      fontSize: (base.titleSmall?.fontSize ?? 14) * scale,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontSize: (base.titleMedium?.fontSize ?? 14) * scale,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: (base.titleLarge?.fontSize ?? 14) * scale,
    ),
  );
}

ThemeData getScaledTheme(ThemeData baseTheme, double scale) {
  return baseTheme.copyWith(
    textTheme: scaleTextTheme(baseTheme.textTheme, scale),
  );
}

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color.fromARGB(255, 66, 59, 79),
  scaffoldBackgroundColor: const Color.fromARGB(255, 251, 251, 252),
  textTheme: TextTheme(
    bodySmall: TextStyle(
      fontWeight: FontWeight.w400,
      color: const Color.fromARGB(255, 66, 59, 79),
      fontSize: 6,
    ),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w400,
      color: const Color.fromARGB(255, 66, 59, 79),
      fontSize: 10,
    ),
    bodyLarge: TextStyle(
      fontWeight: FontWeight.w400,
      color: const Color.fromARGB(255, 66, 59, 79),
      fontSize: 14,
    ),
    labelSmall: TextStyle(
      fontWeight: FontWeight.w500,
      color: const Color.fromARGB(255, 66, 59, 79),
      fontSize: 18,
    ),
    labelMedium: TextStyle(
      fontWeight: FontWeight.w500,
      color: const Color.fromARGB(255, 66, 59, 79),
      fontSize: 22,
    ),
    labelLarge: TextStyle(
      fontWeight: FontWeight.w600,
      color: const Color.fromARGB(255, 66, 59, 79),
      fontSize: 26,
    ),
    titleSmall: TextStyle(
      fontWeight: FontWeight.w700,
      color: const Color.fromARGB(255, 66, 59, 79),
      fontSize: 30,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w800,
      color: const Color.fromARGB(255, 66, 59, 79),
      fontSize: 36,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w900,
      color: const Color.fromARGB(255, 66, 59, 79),
      fontSize: 40,
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color.fromARGB(255, 251, 251, 252),
  ),
  iconTheme: IconThemeData(color: const Color.fromARGB(255, 66, 59, 79)),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color.fromARGB(255, 66, 59, 79),
  scaffoldBackgroundColor: const Color.fromARGB(198, 51, 49, 53),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color.fromARGB(198, 51, 49, 53),
  ),
  textTheme: TextTheme(
    bodySmall: TextStyle(
      fontWeight: FontWeight.w400,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w400,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 20,
    ),
    bodyLarge: TextStyle(
      fontWeight: FontWeight.w500,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 22,
    ),
    labelSmall: TextStyle(
      fontWeight: FontWeight.w500,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 24,
    ),
    labelMedium: TextStyle(
      fontWeight: FontWeight.w600,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 26,
    ),
    labelLarge: TextStyle(
      fontWeight: FontWeight.w600,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 28,
    ),
    titleSmall: TextStyle(
      fontWeight: FontWeight.w700,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 30,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w800,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 35,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w900,
      color: const Color.fromARGB(255, 251, 251, 252),
      fontSize: 37,
    ),
  ),
  iconTheme: IconThemeData(color: const Color.fromARGB(255, 251, 251, 252)),
);

ButtonStyle CustomElevatedButtonTheme(BuildContext context) {
  return ElevatedButton.styleFrom(
    foregroundColor:
        Theme.of(context).brightness == Brightness.light
            ? const Color.fromARGB(255, 255, 255, 255) // light mode color
            : const Color.fromARGB(255, 66, 59, 79), // dark mode color,
    backgroundColor:
        Theme.of(context).brightness == Brightness.light
            ? const Color.fromARGB(255, 66, 59, 79) // light mode color
            : const Color.fromARGB(255, 255, 255, 255), // dark mode color,
    minimumSize: Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ), // Text color
  );
}

BoxDecoration customContainerDecoration(BuildContext context) {
  return BoxDecoration(
    color:
        Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 135, 128, 139) // Dark mode color
            : const Color.fromARGB(255, 203, 194, 205), // Light mode color
    borderRadius: BorderRadius.circular(12), // Rounded corners
    boxShadow: [
      BoxShadow(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.grey,
        spreadRadius: 1,
        blurRadius: 2,
        offset: Offset(0, 2), // Shadow position
      ),
    ],
  );
}

InputDecoration textInputdecoration(BuildContext context, String text) {
  return InputDecoration(
    errorStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: const Color.fromARGB(255, 193, 58, 49),
      fontWeight: FontWeight.bold,
    ),
    labelText: text,
    labelStyle: Theme.of(context).textTheme.labelSmall,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    filled: true,
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
  );
}

BoxDecoration UsersListContainerDecoration(BuildContext context) {
  return BoxDecoration(
    color:
        Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 66, 59, 79) // Dark mode color
            : const Color.fromARGB(255, 255, 255, 255), // Light mode color
    boxShadow: [
      BoxShadow(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.grey,
        spreadRadius: 1,
        blurRadius: 2,
        offset: Offset(0, 2), // Shadow position
      ),
    ],
  );
}
