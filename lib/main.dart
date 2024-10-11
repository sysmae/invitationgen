  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:go_router/go_router.dart';
import 'package:invitationgen/form3.dart';
  import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';


  import 'package:invitationgen/form1.dart';
  import 'package:invitationgen/form2.dart';
  import 'package:invitationgen/home.dart';
  import 'package:invitationgen/login.dart';
  import 'package:invitationgen/signup.dart';


  Future<void> main() async {
    // 웹 환경에서 카카오 로그인을 정상적으로 완료하려면 runApp() 호출 전 아래 메서드 호출 필요
    WidgetsFlutterBinding.ensureInitialized();

    // runApp() 호출 전 Flutter SDK 초기화
    KakaoSdk.init(
      nativeAppKey: '6bb403c5124d319ac3b194ec57feec15',
      javaScriptAppKey: 'c7f14517962ce3117e2ec63ae4cd7d54',
    );

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
          GoRoute(path: '/form1', builder: (context, state) => const Form1Page()),
          GoRoute(path: '/form2', builder: (context, state) => const Form2Page()),
          GoRoute(path: '/form3', builder: (context, state) => const Form3Page()),
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
