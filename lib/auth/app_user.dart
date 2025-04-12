class AppUser {
  final String uid;
  final String email;
  final String name;

  AppUser({required this.uid, required this.email, required this.name});

  // convert app user => json
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'name': name};
  }

  // convert json => app user
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      email: jsonUser['email'],
      uid: jsonUser['uid'],
      name: jsonUser['name'],
    );
  }
}
