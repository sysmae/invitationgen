import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Form3Page extends StatefulWidget {
  const Form3Page({Key? key}) : super(key: key);

  @override
  _Form3PageState createState() => _Form3PageState();
}

class _Form3PageState extends State<Form3Page> {
  final _formKey = GlobalKey<FormState>();
  String _additionalInstructions = ''; // 추가 안내사항

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('추가 안내사항 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 추가 안내사항 입력 필드
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '추가 안내사항',
                ),
                maxLines: 3, // 여러 줄 입력 가능
                validator: (value) => value!.isEmpty ? '안내사항을 입력하세요' : null,
                onSaved: (value) => _additionalInstructions = value!,
              ),
              const SizedBox(height: 20),
              // 정보 저장 및 홈으로 이동 버튼
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // 입력된 데이터 처리 (예: Firebase에 저장)
                    // 예를 들어, FirebaseService를 호출하여 데이터를 저장할 수 있습니다.
                    // firebaseService.saveAdditionalInstructions(instructions: _additionalInstructions);

                    // 홈 화면으로 이동
                    GoRouter.of(context).go('/home');
                  }
                },
                child: const Text('정보 저장 및 홈으로'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
