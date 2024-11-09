import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 사용자가 로그인 상태인지 확인
    _checkUserLoggedIn();
  }

  void _checkUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 사용자가 로그인된 상태이면 메인 화면으로 이동
      context.go('/');
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn();
      GoogleSignInAccount? _account = await _googleSignIn.signIn();
      if (_account != null) {
        final GoogleSignInAuthentication _auth = await _account.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: _auth.accessToken,
          idToken: _auth.idToken,
        );

        // Firebase 인증
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // Firestore에 사용자 정보 저장
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'email': userCredential.user?.email,
          'displayName': userCredential.user?.displayName,
          'createdAt': FieldValue.serverTimestamp(),
          // 필요시 추가 필드 작성
        }, SetOptions(merge: true)); // merge 옵션으로 기존 데이터 유지 가능

        // 로그인 성공 후 메인 화면으로 이동
        context.go('/');
      }
    } catch (error) {
      debugPrint("Google sign-in failed: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Form(
              key: _key,
              child: Column(
                children: [
                  Image.asset(
                    'asset/login_screen.png',
                    height: 300,
                  ),
                  const SizedBox(height: 10),
                  emailInput(),
                  const SizedBox(height: 15),
                  passwordInput(),
                  const SizedBox(height: 15),
                  loginButton(),
                  const SizedBox(height: 0),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    child: const Text("Sign Up"),
                  ),
                  const SizedBox(height: 30),
                  googleSignInButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField emailInput() {
    return TextFormField(
      controller: _emailController,
      autofocus: true,
      validator: (val) {
        if (val!.isEmpty) {
          return 'The input is empty.';
        } else {
          return null;
        }
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Input your email address.',
        labelText: 'Email Address',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TextFormField passwordInput() {
    return TextFormField(
      controller: _pwdController,
      obscureText: true,
      validator: (val) {
        if (val!.isEmpty) {
          return 'The input is empty.';
        } else {
          return null;
        }
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Input your password.',
        labelText: 'Password',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ElevatedButton loginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Color(0xffffff6d)),
      onPressed: () async {
        if (_key.currentState!.validate()) {
          try {
            // 이메일과 비밀번호로 로그인
            UserCredential userCredential = await FirebaseAuth.instance
                .signInWithEmailAndPassword(
                    email: _emailController.text,
                    password: _pwdController.text);

            // Firestore에 사용자 정보 저장 (존재하지 않으면 새로 추가)
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user?.uid)
                .set({
              'email': userCredential.user?.email,
              'displayName': userCredential.user?.displayName ?? '',
              'createdAt': FieldValue.serverTimestamp(),
              // 필요시 추가 필드 작성
            }, SetOptions(merge: true));

            // 로그인 성공 후 메인 화면으로 이동
            context.go('/');
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              debugPrint('No user found for that email.');
            } else if (e.code == 'wrong-password') {
              debugPrint('Wrong password provided for that user.');
            }
          }
        }
      },
      child: Container(
        width: 2000,
        padding: const EdgeInsets.all(15),
        alignment: Alignment.center,
        child: const Text(
          "Login",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }

  ElevatedButton googleSignInButton() {
    return ElevatedButton(
      onPressed: () => signInWithGoogle(context),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
      child: Container(
        width: 2000,
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Image.asset('asset/google_logo.png', height: 25),
            const Spacer(),
            const Text(
              "Login with Google",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const Spacer()
          ],
        ),
      ),
    );
  }
}
