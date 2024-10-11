import 'package:flutter/material.dart';
import 'package:invitationgen/.private/firebase_service.dart'; // Firebase 서비스

class InvitationFormScreen extends StatefulWidget {
  const InvitationFormScreen({super.key});

  @override
  _InvitationFormScreenState createState() => _InvitationFormScreenState();
}

class _InvitationFormScreenState extends State<InvitationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // 청첩장 입력 데이터 변수
  String _groomName = '';
  String _groomPhone = '';
  String _brideName = '';
  String _bridePhone = '';

  // 청첩장 생성 함수
  Future<void> _createInvitation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await createInvitation(
          groomName: _groomName,
          groomPhone: _groomPhone,
          brideName: _brideName,
          bridePhone: _bridePhone,
        );
        // 성공 시 다음 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (error) {
        print('청첩장 생성 실패: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('청첩장 생성')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 신랑 정보 입력
              TextFormField(
                decoration: InputDecoration(labelText: '신랑 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
                onSaved: (value) => _groomName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '신랑 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
                onSaved: (value) => _groomPhone = value!,
              ),
              // 신부 정보 입력
              TextFormField(
                decoration: InputDecoration(labelText: '신부 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
                onSaved: (value) => _brideName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '신부 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
                onSaved: (value) => _bridePhone = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createInvitation,
                child: Text('청첩장 생성하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
