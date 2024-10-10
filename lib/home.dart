import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invitationgen/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> user) {
        if (!user.hasData) {
          return const LoginPage();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("초대장 생성 앱"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut().then(
                          (_) => Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false),
                    );
                  },
                ),
              ],
            ),
            body: const Center(
              child: Text("Successfully logged in!"),
            ),
          );
        }
      },
    );
  }
}
