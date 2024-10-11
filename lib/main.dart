import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invitationgen/form1.dart';
import 'package:invitationgen/home.dart';
import 'package:invitationgen/login.dart';
import 'package:invitationgen/signup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(path: '/form1', builder: (context, state) => const Form1Page())
      ],
    );

    return MaterialApp.router(
      routerConfig: _router,
      title: '초대장 생성 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
