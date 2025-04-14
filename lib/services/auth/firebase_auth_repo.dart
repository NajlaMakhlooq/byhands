import 'package:byhands/services/auth/app_user.dart';
import 'package:byhands/services/auth/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      //attempt sign in
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //create the user
      AppUser user = AppUser(
        email: email,
        uid: userCredential.user!.uid,
        name: "",
      );

      return user;
    } catch (e) {
      throw Exception('login failed : $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      //attempt sign up
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      //create the user
      AppUser user = AppUser(
        email: email,
        uid: userCredential.user!.uid,
        name: name,
      );

      return user;
    } catch (e) {
      throw Exception('Sign up failed : $e');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    // get current logged in user from firebase
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    //user exist
    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!, name: '');
  }
}
