import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                    'asset/temporary_logo.png',
                  height: 200
                ),
                emailInput(),
                const SizedBox(height: 15),
                passwordInput(),
                const SizedBox(height: 15),
                submitButton(),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text("Back to login screen"),
                ),
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

  ElevatedButton submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xffffff6d)
      ),
      onPressed: () async {
        if (_key.currentState!.validate()) {
          try {
            // FirebaseAuth로 사용자 생성
            UserCredential userCredential = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
              email: _emailController.text,
              password: _pwdController.text,
            );

            // Firestore에 사용자 정보 저장
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user?.uid)
                .set({
              'email': _emailController.text,
              'createdAt': FieldValue.serverTimestamp(),
              // 추가로 필요한 필드를 여기에 저장 가능
            });

            // 회원가입 후 홈으로 이동
            context.go('/home'); // 원한다면 다른 경로로 수정 가능
          } on FirebaseAuthException catch (e) {
            if (e.code == 'weak-password') {
              debugPrint('The password provided is too weak.');
            } else if (e.code == 'email-already-in-use') {
              debugPrint('The account already exists for that email.');
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      },
      child: Container(
        width: 2000,
        padding: const EdgeInsets.all(15),
        alignment: Alignment.center,
        child: const Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
