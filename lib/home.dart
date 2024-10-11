import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invitationgen/login.dart'; // 로그인 페이지

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
          return const LoginPage(); // 로그인 페이지로 이동
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("초대장 생성 앱"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut().then(
                          (_) => context.go('/login'),
                    );
                  },
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Successfully logged in!"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/form1'); // 청첩장 생성 폼 페이지로 이동
                    },
                    child: const Text("청첩장 생성하기"),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
