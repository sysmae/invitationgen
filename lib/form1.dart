import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invitationgen/firebase_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // intl 패키지 임포트

class Form1Page extends StatefulWidget {
  const Form1Page({super.key});

  @override
  _Form1PageState createState() => _Form1PageState();
}

class _Form1PageState extends State<Form1Page> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 텍스트 필드 컨트롤러
  final TextEditingController _groomNameController = TextEditingController(text: '신랑 이름');
  final TextEditingController _groomPhoneController = TextEditingController(text: '신랑 전화번호');
  final TextEditingController _groomFatherNameController = TextEditingController(text: '신랑 아버지 이름');
  final TextEditingController _groomFatherPhoneController = TextEditingController(text: '신랑 아버지 전화번호');
  final TextEditingController _groomMotherNameController = TextEditingController(text: '신랑 어머니 이름');
  final TextEditingController _groomMotherPhoneController = TextEditingController(text: '신랑 어머니 전화번호');
  final TextEditingController _brideNameController = TextEditingController(text: '신부 이름');
  final TextEditingController _bridePhoneController = TextEditingController(text: '신부 전화번호');
  final TextEditingController _brideFatherNameController = TextEditingController(text: '신부 아버지 이름');
  final TextEditingController _brideFatherPhoneController = TextEditingController(text: '신부 아버지 전화번호');
  final TextEditingController _brideMotherNameController = TextEditingController(text: '신부 어머니 이름');
  final TextEditingController _brideMotherPhoneController = TextEditingController(text: '신부 어머니 전화번호');

  // 계좌번호 입력 필드 추가
  final TextEditingController _groomAccountController = TextEditingController();
  final TextEditingController _brideAccountController = TextEditingController();

  DateTime _weddingDate = DateTime.now(); // 결혼식 날짜
  TimeOfDay _weddingTime = TimeOfDay.now(); // 결혼식 시간
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    } else {
      GoRouter.of(context).go('/login');
    }
  }

  Future<void> _createInvitation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        DateTime weddingDateTime = DateTime(
          _weddingDate.year,
          _weddingDate.month,
          _weddingDate.day,
          _weddingTime.hour,
          _weddingTime.minute,
        );

        await _firebaseService.createInvitation(
          userId: _userId!,
          templateId: 'templateId',
          groomName: _groomNameController.text,
          groomPhone: _groomPhoneController.text,
          groomFatherName: _groomFatherNameController.text,
          groomFatherPhone: _groomFatherPhoneController.text,
          groomMotherName: _groomMotherNameController.text,
          groomMotherPhone: _groomMotherPhoneController.text,
          brideName: _brideNameController.text,
          bridePhone: _bridePhoneController.text,
          brideFatherName: _brideFatherNameController.text,
          brideFatherPhone: _brideFatherPhoneController.text,
          brideMotherName: _brideMotherNameController.text,
          brideMotherPhone: _brideMotherPhoneController.text,
          weddingDateTime: weddingDateTime,
          weddingLocation: '',
          additionalAddress: '', // 필요한 경우 추가 주소 필드 추가
        );

        // Form2Page에 필요한 데이터를 전달
        GoRouter.of(context).go('/form2', extra: {
          'weddingDateTime': weddingDateTime,
          'groomName': _groomNameController.text,
          'groomPhone': _groomPhoneController.text,
          'groomFatherName': _groomFatherNameController.text,
          'groomFatherPhone': _groomFatherPhoneController.text,
          'groomMotherName': _groomMotherNameController.text,
          'groomMotherPhone': _groomMotherPhoneController.text,
          'brideName': _brideNameController.text,
          'bridePhone': _bridePhoneController.text,
          'brideFatherName': _brideFatherNameController.text,
          'brideFatherPhone': _brideFatherPhoneController.text,
          'brideMotherName': _brideMotherNameController.text,
          'brideMotherPhone': _brideMotherPhoneController.text,
          'groomAccount': _groomAccountController.text, // 신랑 계좌번호
          'brideAccount': _brideAccountController.text, // 신부 계좌번호
        });
      } catch (error) {
        print('청첩장 생성 실패: $error');
      }
    }
  }

  @override
  void dispose() {
    _groomNameController.dispose();
    _groomPhoneController.dispose();
    _groomFatherNameController.dispose();
    _groomFatherPhoneController.dispose();
    _groomMotherNameController.dispose();
    _groomMotherPhoneController.dispose();
    _brideNameController.dispose();
    _bridePhoneController.dispose();
    _brideFatherNameController.dispose();
    _brideFatherPhoneController.dispose();
    _brideMotherNameController.dispose();
    _brideMotherPhoneController.dispose();
    _groomAccountController.dispose(); // 계좌번호 컨트롤러 dispose
    _brideAccountController.dispose(); // 계좌번호 컨트롤러 dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('청첩장 생성')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 신랑 정보 입력
              TextFormField(
                controller: _groomNameController,
                decoration: const InputDecoration(labelText: '신랑 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
              ),
              TextFormField(
                controller: _groomPhoneController,
                decoration: const InputDecoration(labelText: '신랑 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
              ),
              TextFormField(
                controller: _groomFatherNameController,
                decoration: const InputDecoration(labelText: '신랑 아버지 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
              ),
              TextFormField(
                controller: _groomFatherPhoneController,
                decoration: const InputDecoration(labelText: '신랑 아버지 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
              ),
              TextFormField(
                controller: _groomMotherNameController,
                decoration: const InputDecoration(labelText: '신랑 어머니 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
              ),
              TextFormField(
                controller: _groomMotherPhoneController,
                decoration: const InputDecoration(labelText: '신랑 어머니 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
              ),
              // 신랑 계좌번호 입력
              TextFormField(
                controller: _groomAccountController,
                decoration: const InputDecoration(labelText: '신랑 계좌번호 (선택사항)'),
                validator: (value) => value!.isEmpty ? null : null, // 선택사항이므로 빈 값 허용
              ),
              // 신부 정보 입력
              TextFormField(
                controller: _brideNameController,
                decoration: const InputDecoration(labelText: '신부 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
              ),
              TextFormField(
                controller: _bridePhoneController,
                decoration: const InputDecoration(labelText: '신부 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
              ),
              TextFormField(
                controller: _brideFatherNameController,
                decoration: const InputDecoration(labelText: '신부 아버지 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
              ),
              TextFormField(
                controller: _brideFatherPhoneController,
                decoration: const InputDecoration(labelText: '신부 아버지 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
              ),
              TextFormField(
                controller: _brideMotherNameController,
                decoration: const InputDecoration(labelText: '신부 어머니 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
              ),
              TextFormField(
                controller: _brideMotherPhoneController,
                decoration: const InputDecoration(labelText: '신부 어머니 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
              ),
              // 신부 계좌번호 입력
              TextFormField(
                controller: _brideAccountController,
                decoration: const InputDecoration(labelText: '신부 계좌번호 (선택사항)'),
                validator: (value) => value!.isEmpty ? null : null, // 선택사항이므로 빈 값 허용
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _createInvitation,
                child: const Text('다음'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
