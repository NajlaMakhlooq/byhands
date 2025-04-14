/*
AUTH GATE - will continously listen for auth state changes
----------------------------------------------------------------------------

unauthenticated -> Login page
authenticated -> profile page

*/

import 'package:byhands/pages/home_page.dart';
import 'package:byhands/pages/start_pages/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // lIsten to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,

      // Build appropriate page based on auth state
      builder: (context, snapshot) {
        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // check if there is valid session currently
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return DashboardPage();
        } else {
          return Login();
        }
      },
    );
  }
}
