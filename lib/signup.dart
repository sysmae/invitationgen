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
  final TextEditingController _confirmPwdController = TextEditingController();
  bool _isLoading = false;

  // 이메일 유효성 검사를 위한 정규식
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: SingleChildScrollView(
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
                  confirmPasswordInput(),
                  const SizedBox(height: 15),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
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
      ),
    );
  }

  TextFormField emailInput() {
    return TextFormField(
      controller: _emailController,
      autofocus: true,
      keyboardType: TextInputType.emailAddress,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return '이메일을 입력해주세요.';
        }
        if (!emailRegex.hasMatch(val)) {
          return '올바른 이메일 형식이 아닙니다.';
        }
        return null;
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: '이메일 주소를 입력해주세요.',
        labelText: '이메일 주소',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(Icons.email),
      ),
    );
  }

  TextFormField passwordInput() {
    return TextFormField(
      controller: _pwdController,
      obscureText: true,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return '비밀번호를 입력해주세요.';
        }
        if (val.length < 6) {
          return '비밀번호는 최소 6자 이상이어야 합니다.';
        }
        if (!val.contains(RegExp(r'[A-Z]'))) {
          return '대문자를 최소 1자 이상 포함해야 합니다.';
        }
        if (!val.contains(RegExp(r'[0-9]'))) {
          return '숫자를 최소 1자 이상 포함해야 합니다.';
        }
        return null;
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: '비밀번호를 입력해주세요.',
        labelText: '비밀번호',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(Icons.lock),
      ),
    );
  }

  TextFormField confirmPasswordInput() {
    return TextFormField(
      controller: _confirmPwdController,
      obscureText: true,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return '비밀번호를 다시 입력해주세요.';
        }
        if (val != _pwdController.text) {
          return '비밀번호가 일치하지 않습니다.';
        }
        return null;
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: '비밀번호를 다시 입력해주세요.',
        labelText: '비밀번호 확인',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(Icons.lock_clock),
      ),
    );
  }

  ElevatedButton submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffffff6d)
      ),
      onPressed: () async {
        if (_key.currentState!.validate()) {
          setState(() => _isLoading = true);

          try {
            UserCredential userCredential = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
              email: _emailController.text,
              password: _pwdController.text,
            );

            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user?.uid)
                .set({
              'email': _emailController.text,
              'createdAt': FieldValue.serverTimestamp(),
            });

            _showSnackBar('회원가입이 완료되었습니다!');
            context.go('/');
          } on FirebaseAuthException catch (e) {
            String errorMessage = '회원가입 중 오류가 발생했습니다.';

            switch (e.code) {
              case 'weak-password':
                errorMessage = '비밀번호가 너무 약합니다.';
                break;
              case 'email-already-in-use':
                errorMessage = '이미 사용 중인 이메일입니다.';
                break;
              case 'invalid-email':
                errorMessage = '잘못된 이메일 형식입니다.';
                break;
            }

            _showSnackBar(errorMessage, isError: true);
          } catch (e) {
            _showSnackBar('예기치 않은 오류가 발생했습니다.', isError: true);
          } finally {
            setState(() => _isLoading = false);
          }
        }
      },
      child: Container(
        width: 2000,
        padding: const EdgeInsets.all(15),
        alignment: Alignment.center,
        child: const Text(
          "회원가입",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }
}