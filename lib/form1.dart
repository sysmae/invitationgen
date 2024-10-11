import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth 임포트
import 'package:invitationgen/firebase_service.dart';
import 'package:go_router/go_router.dart';

class Form1Page extends StatefulWidget {
  const Form1Page({super.key});

  @override
  _Form1PageState createState() => _Form1PageState();
}

class _Form1PageState extends State<Form1Page> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService(); // FirebaseService 인스턴스 생성
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth 인스턴스 생성

  // 청첩장 입력 데이터 변수
  String _groomName = '신랑 이름'; // 기본값
  String _groomPhone = '010-0000-0000'; // 기본값
  String _groomFatherName = '신랑 아버지 이름'; // 기본값
  String _groomFatherPhone = '010-0000-0000'; // 기본값
  String _groomMotherName = '신랑 어머니 이름'; // 기본값
  String _groomMotherPhone = '010-0000-0000'; // 기본값
  String _brideName = '신부 이름'; // 기본값
  String _bridePhone = '010-0000-0000'; // 기본값
  String _brideFatherName = '신부 아버지 이름'; // 기본값
  String _brideFatherPhone = '010-0000-0000'; // 기본값
  String _brideMotherName = '신부 어머니 이름'; // 기본값
  String _brideMotherPhone = '010-0000-0000'; // 기본값
  DateTime _weddingDateTime = DateTime.now(); // 결혼식 날짜 및 시간

  String? _userId; // 사용자 ID를 저장할 변수

  @override
  void initState() {
    super.initState();
    _getUserId(); // 사용자 ID 가져오기
  }

  // 사용자 ID를 가져오는 함수
  Future<void> _getUserId() async {
    User? user = _auth.currentUser; // 현재 로그인한 사용자 가져오기
    if (user != null) {
      setState(() {
        _userId = user.uid; // 사용자 ID 설정
      });
    } else {
      // 사용자가 로그인하지 않은 경우 처리
      print('사용자가 로그인하지 않았습니다.');
    }
  }

  // 청첩장 생성 함수
  Future<void> _createInvitation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _firebaseService.createInvitation(
          userId: _userId!, // 사용자 ID 추가
          templateId: 'templateId', // 템플릿 ID를 여기에 추가
          groomName: _groomName,
          groomPhone: _groomPhone,
          groomFatherName: _groomFatherName,
          groomFatherPhone: _groomFatherPhone,
          groomMotherName: _groomMotherName,
          groomMotherPhone: _groomMotherPhone,
          brideName: _brideName,
          bridePhone: _bridePhone,
          brideFatherName: _brideFatherName,
          brideFatherPhone: _brideFatherPhone,
          brideMotherName: _brideMotherName,
          brideMotherPhone: _brideMotherPhone,
          weddingDateTime: _weddingDateTime,
          weddingLocation: '', // 처음에는 공백으로 남겨둡니다.
        );

        // 성공 시 다음 화면으로 이동
        GoRouter.of(context).go('/form2', extra: {
          'weddingDateTime': _weddingDateTime,
          'groomName': _groomName,
          'groomPhone': _groomPhone,
          'groomFatherName': _groomFatherName,
          'groomFatherPhone': _groomFatherPhone,
          'groomMotherName': _groomMotherName,
          'groomMotherPhone': _groomMotherPhone,
          'brideName': _brideName,
          'bridePhone': _bridePhone,
          'brideFatherName': _brideFatherName,
          'brideFatherPhone': _brideFatherPhone,
          'brideMotherName': _brideMotherName,
          'brideMotherPhone': _brideMotherPhone,
        });
      } catch (error) {
        print('청첩장 생성 실패: $error');
      }
    }
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
                initialValue: _groomName, // 기본값 설정
                decoration: const InputDecoration(labelText: '신랑 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
                onSaved: (value) => _groomName = value!,
                keyboardType: TextInputType.name,
              ),
              TextFormField(
                initialValue: _groomPhone, // 기본값 설정
                decoration: const InputDecoration(labelText: '신랑 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
                onSaved: (value) => _groomPhone = value!,
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                initialValue: _groomFatherName, // 기본값 설정
                decoration: const InputDecoration(labelText: '신랑 아버지 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
                onSaved: (value) => _groomFatherName = value!,
                keyboardType: TextInputType.name,
              ),
              TextFormField(
                initialValue: _groomFatherPhone, // 기본값 설정
                decoration: const InputDecoration(labelText: '신랑 아버지 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
                onSaved: (value) => _groomFatherPhone = value!,
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                initialValue: _groomMotherName, // 기본값 설정
                decoration: const InputDecoration(labelText: '신랑 어머니 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
                onSaved: (value) => _groomMotherName = value!,
                keyboardType: TextInputType.name,
              ),
              TextFormField(
                initialValue: _groomMotherPhone, // 기본값 설정
                decoration: const InputDecoration(labelText: '신랑 어머니 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
                onSaved: (value) => _groomMotherPhone = value!,
                keyboardType: TextInputType.phone,
              ),
              // 신부 정보 입력
              TextFormField(
                initialValue: _brideName, // 기본값 설정
                decoration: const InputDecoration(labelText: '신부 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
                onSaved: (value) => _brideName = value!,
                keyboardType: TextInputType.name,
              ),
              TextFormField(
                initialValue: _bridePhone, // 기본값 설정
                decoration: const InputDecoration(labelText: '신부 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
                onSaved: (value) => _bridePhone = value!,
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                initialValue: _brideFatherName, // 기본값 설정
                decoration: const InputDecoration(labelText: '신부 아버지 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
                onSaved: (value) => _brideFatherName = value!,
                keyboardType: TextInputType.name,
              ),
              TextFormField(
                initialValue: _brideFatherPhone, // 기본값 설정
                decoration: const InputDecoration(labelText: '신부 아버지 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
                onSaved: (value) => _brideFatherPhone = value!,
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                initialValue: _brideMotherName, // 기본값 설정
                decoration: const InputDecoration(labelText: '신부 어머니 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
                onSaved: (value) => _brideMotherName = value!,
                keyboardType: TextInputType.name,
              ),
              TextFormField(
                initialValue: _brideMotherPhone, // 기본값 설정
                decoration: const InputDecoration(labelText: '신부 어머니 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
                onSaved: (value) => _brideMotherPhone = value!,
                keyboardType: TextInputType.phone,
              ),
              // 결혼식 날짜 및 시간 입력
              TextButton(
                onPressed: () async {
                  final pickedDateTime = await showDateTimePicker(context);
                  if (pickedDateTime != null) {
                    setState(() {
                      _weddingDateTime = pickedDateTime;
                    });
                  }
                },
                child: Text(
                  '결혼식 날짜 및 시간 선택: ${_weddingDateTime.year}-${_weddingDateTime.month}-${_weddingDateTime.day} ${_weddingDateTime.hour}:${_weddingDateTime.minute}',
                ),
              ),
              const SizedBox(height: 20),
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

  Future<DateTime?> showDateTimePicker(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _weddingDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: _weddingDateTime.hour, minute: _weddingDateTime.minute),
      );
      if (time != null) {
        return DateTime(date.year, date.month, date.day, time.hour, time.minute);
      }
    }
    return null;
  }
}
