import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart'; // <-- Add this
import 'theme.dart';
import 'pages/main_pages/dashboard.dart';
import 'pages/main_pages/camera.dart';
import 'pages/main_pages/categories.dart';
import 'pages/main_pages/chats/chats.dart';
import 'pages/main_pages/courses.dart';
import 'pages/setting_pages/s_and_p.dart';
import 'pages/userInfo_pages/profile_pages/profile.dart';
import 'pages/userInfo_pages/savedposts.dart';
import 'pages/userInfo_pages/likedcourses.dart';
import 'pages/start_pages/login.dart';
import 'pages/start_pages/signup.dart';
import 'pop_up/start.dart';
import 'pages/help_pages/help.dart';
import 'pages/help_pages/AppOverview.dart';
import 'pages/help_pages/HowToUse.dart';
import 'pages/setting_pages/Notifications.dart';
import 'services/PostTemplete.dart';
import 'services/add_course.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized(); // <-- Add this

  await Supabase.initialize(
    url: 'https://glkepkzkeymwtlfkoemw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdsa2Vwa3prZXltd3RsZmtvZW13Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA0NjI5MzgsImV4cCI6MjA1NjAzODkzOH0.AsEOsn2CsONZK4x58hZtXJhJVsSxq5-wLtU_4WdQ3pk',
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: const BY_HANDSApp(),
    ),
  );
}

class BY_HANDSApp extends StatefulWidget {
  const BY_HANDSApp({super.key});

  @override
  State<BY_HANDSApp> createState() => _BY_HANDSAppState();
}

class _BY_HANDSAppState extends State<BY_HANDSApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleThemeModeSwitch() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      locale: context.locale, // <-- Add this
      supportedLocales: context.supportedLocales, // <-- Add this
      localizationsDelegates: context.localizationDelegates, // <-- Add this
      home: const Start(),
      routes: {
        '/Start': (context) => const Start(),
        '/Home': (context) => DashboardPage(),
        '/Camera': (context) => Camera(),
        '/Categories': (context) => const Categories(),
        '/Chats': (context) => const Chats(),
        '/Courses': (context) => const Courses(),
        '/Help': (context) => const Help(),
        '/likedcourses': (context) => const likedcourses(),
        '/profile': (context) => const Profile(),
        '/SandP': (context) => SettingsPage(
              toggleThemeMode: toggleThemeModeSwitch,
            ),
        '/Savedposts': (context) => const Saved_posts(),
        '/signup': (context) => const Signup(),
        '/login': (context) => const Login(),
        '/Notification': (context) => const Notifications(),
        '/add_course': (context) => const AddCourse(),
        '/HowTo': (context) => const HowTo(),
        '/AppOverView': (context) => const App_Overview(),
        '/postTemplete': (context) => const Posttemplete(),
      },
    );
  }
}
