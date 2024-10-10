import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      Navigator.pushNamed(context, "/");
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

        await FirebaseAuth.instance.signInWithCredential(credential);
        // 로그인 성공 후 메인 화면으로 이동
        Navigator.pushNamed(context, "/");
      }
    } catch (error) {
      debugPrint("Google sign-in failed: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase App")),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                emailInput(),
                const SizedBox(height: 15),
                passwordInput(),
                const SizedBox(height: 15),
                loginButton(),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text("Sign Up"),
                ),
                const SizedBox(height: 15),
                googleSignInButton(),
              ],
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
      onPressed: () async {
        if (_key.currentState!.validate()) {
          try {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: _emailController.text,
                password: _pwdController.text)
                .then((_) => Navigator.pushNamed(context, "/"));
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
        padding: const EdgeInsets.all(15),
        child: const Text(
          "Login",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  ElevatedButton googleSignInButton() {
    return ElevatedButton(
      onPressed: () => signInWithGoogle(context),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: const Text(
          "Login with Google",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
