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
  bool _isLoading = false;
  bool _obscurePassword = true;

  // 이메일 유효성 검사를 위한 정규식
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  void _checkUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.go('/');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? _account = await _googleSignIn.signIn();

      if (_account != null) {
        final GoogleSignInAuthentication _auth = await _account.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: _auth.accessToken,
          idToken: _auth.idToken,
        );

        final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'email': userCredential.user?.email,
          'displayName': userCredential.user?.displayName,
          'lastLogin': FieldValue.serverTimestamp(),
          'loginMethod': 'google',
        }, SetOptions(merge: true));

        _showSnackBar('구글 로그인 성공!');
        context.go('/');
      }
    } catch (error) {
      _showSnackBar('구글 로그인 실패: 다시 시도해주세요.', isError: true);
      debugPrint("Google sign-in error: $error");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
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
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          if (_emailController.text.isEmpty) {
                            _showSnackBar('이메일을 입력해주세요.', isError: true);
                            return;
                          }
                          FirebaseAuth.instance.sendPasswordResetEmail(
                            email: _emailController.text,
                          ).then((_) {
                            _showSnackBar('비밀번호 재설정 이메일이 발송되었습니다.');
                          }).catchError((error) {
                            _showSnackBar('이메일 발송 실패: 이메일을 확인해주세요.', isError: true);
                          });
                        },
                        child: const Text("비밀번호 찾기"),
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          loginButton(),
                          const SizedBox(height: 5),
                          TextButton(
                            onPressed: () => context.go('/signup'),
                            child: const Text("회원가입하기"),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "또는",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          googleSignInButton(),
                        ],
                      ),
                  ],
                ),
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
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
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
        labelText: '이메일',
        prefixIcon: Icon(Icons.email),
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
      obscureText: _obscurePassword,
      autofillHints: const [AutofillHints.password],
      validator: (val) {
        if (val == null || val.isEmpty) {
          return '비밀번호를 입력해주세요.';
        }
        return null;
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: '비밀번호를 입력해주세요.',
        labelText: '비밀번호',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        labelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ElevatedButton loginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffffff6d),
      ),
      onPressed: () async {
        if (_key.currentState!.validate()) {
          setState(() => _isLoading = true);

          try {
            final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _emailController.text,
              password: _pwdController.text,
            );

            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user?.uid)
                .set({
              'lastLogin': FieldValue.serverTimestamp(),
              'loginMethod': 'email',
            }, SetOptions(merge: true));

            _showSnackBar('로그인 성공!');
            context.go('/');
          } on FirebaseAuthException catch (e) {
            String errorMessage = '로그인에 실패했습니다.';

            switch (e.code) {
              case 'user-not-found':
                errorMessage = '존재하지 않는 계정입니다.';
                break;
              case 'wrong-password':
                errorMessage = '비밀번호가 올바르지 않습니다.';
                break;
              case 'invalid-email':
                errorMessage = '잘못된 이메일 형식입니다.';
                break;
              case 'user-disabled':
                errorMessage = '비활성화된 계정입니다.';
                break;
              case 'too-many-requests':
                errorMessage = '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
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
          "로그인",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  ElevatedButton googleSignInButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => signInWithGoogle(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      child: Container(
        width: 2000,
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('asset/google_logo.png', height: 25),
            const SizedBox(width: 10),
            const Text(
              "구글로 로그인",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwdController.dispose();
    super.dispose();
  }
}