// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invitationgen/invitations_list.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

import 'package:invitationgen/form0.dart';
import 'package:invitationgen/form1.dart';
import 'package:invitationgen/form2.dart';
import 'package:invitationgen/form3.dart';
import 'package:invitationgen/home.dart';
import 'package:invitationgen/login.dart';
import 'package:invitationgen/signup.dart';
import 'package:invitationgen/my_profile.dart';
import 'package:invitationgen/shareScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: '6bb403c5124d319ac3b194ec57feec15',
    javaScriptAppKey: 'c7f14517962ce3117e2ec63ae4cd7d54',
  );

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
        GoRoute(
          path: '/my_profile',
          builder: (context, state) =>  MyProfilePage(),
        ),
        GoRoute(
          path: '/invitations_list',
          builder: (context, state) => const InvitationsListPage(),
        ),
        GoRoute(
          path: '/form0/:invitationId',
          builder: (context, state) {
            final invitationId = state.pathParameters['invitationId'];
            return Form0Page(invitationId: invitationId);
          },
        ),
        GoRoute(
          path: '/form1/:invitationId',
          builder: (context, state) {
            final invitationId = state.pathParameters['invitationId'];
            return Form1Page(invitationId: invitationId);
          },
        ),
        GoRoute(
          path: '/form2/:invitationId',
          builder: (context, state) {
            final invitationId = state.pathParameters['invitationId'];
            return Form2Page(invitationId: invitationId);
          },
        ),
        GoRoute(
          path: '/form3/:invitationId',
          builder: (context, state) {
            final invitationId = state.pathParameters['invitationId'];
            return Form3Page(invitationId: invitationId);
          },
        ),
        GoRoute(
          path: '/shareScreen/:invitationId',
          builder: (context, state) {
            final invitationId = state.pathParameters['invitationId'];
            return ShareScreen(invitationId: invitationId);
          },
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: _router,
      title: '초대장 생성 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white
      ),
    );
  }
}
