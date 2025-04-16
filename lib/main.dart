import 'package:byhands/services/auth/firebase_options.dart';
import 'package:byhands/pages/help_pages/AppOverview.dart';
import 'package:byhands/pages/help_pages/HowToUse.dart';
import 'package:byhands/pages/help_pages/help.dart';
import 'package:byhands/pages/camera.dart';
import 'package:byhands/pages/categories/categories.dart';
import 'package:byhands/pages/chats/chats.dart';
import 'package:byhands/pages/courses/courses.dart';
import 'package:byhands/pages/courses/add_course.dart';
import 'package:byhands/pages/setting_pages/Notifications.dart';
import 'package:byhands/pages/profile_pages/Savedcourses.dart';
import 'package:byhands/pages/profile_pages/profile.dart';
import 'package:byhands/services/forgetpassword.dart';
import 'package:byhands/theme/ThemeCubit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:byhands/services/auth/firebase_auth_repo.dart';
import 'package:byhands/services/auth/Auth_cubit.dart';
import 'package:byhands/pages/start_pages/login.dart';
import 'package:byhands/pages/home_page.dart';
import 'package:byhands/pages/start_pages/start.dart';
import 'package:byhands/pages/start_pages/signup.dart';
import 'package:byhands/theme/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:byhands/theme/globals.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://glkepkzkeymwtlfkoemw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdsa2Vwa3prZXltd3RsZmtvZW13Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA0NjI5MzgsImV4cCI6MjA1NjAzODkzOH0.AsEOsn2CsONZK4x58hZtXJhJVsSxq5-wLtU_4WdQ3pk',
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(BlocProvider(create: (_) => ThemeCubit(), child: const BY_HANDSApp()));
  print("🚀 Starting up...");
}

class FontSizeController {
  // Shared font size notifier
  static ValueNotifier<double> fontSize = ValueNotifier(16.0);
}

class BY_HANDSApp extends StatelessWidget {
  const BY_HANDSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocProvider(
          create:
              (context) => AuthCubit(authRepo: FirebaseAuthRepo())..checkAuth(),
          child: ValueListenableBuilder<double>(
            valueListenable: textScaleNotifier,
            builder: (context, scale, _) {
              // Ensure that theme changes are applied based on themeMode
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: getScaledTheme(lightTheme, scale),
                darkTheme: getScaledTheme(darkTheme, scale),
                themeMode: themeMode, // Bind themeMode to Bloc state
                home: const Start(),
                routes: {
                  '/Start': (context) => const Start(),
                  '/Home': (context) => DashboardPage(),
                  '/Camera': (context) => Camera(),
                  '/Categories': (context) => const Categories(),
                  '/Chats': (context) => const Chats(),
                  '/Courses': (context) => const Courses(),
                  '/Help': (context) => const Help(),
                  '/Savedcourses': (context) => const Savedcourses(),
                  '/profile': (context) => const Profile(),
                  '/signup': (context) => const Signup(),
                  '/login': (context) => const Login(),
                  '/Notification': (context) => const Notifications(),
                  '/add_course': (context) => const AddCourse(),
                  '/HowTo': (context) => HowTo(),
                  '/AppOverView': (context) => const App_Overview(),
                  '/forgot_password': (context) => EmailVerificationPage(),
                },
              );
            },
          ),
        );
      },
    );
  }
}
