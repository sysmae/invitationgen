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
        // 사용자가 로그인되어 있으면 바로 /invitations_list로 이동
        if (user.connectionState == ConnectionState.active) {
          if (user.hasData) {
            Future.microtask(() => context.go('/invitations_list'));
          } else {
            return const LoginPage(); // 로그인 페이지로 이동
          }
        }

        // 데이터를 기다리는 동안 로딩 표시
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
