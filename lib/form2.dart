import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Form2Page extends StatefulWidget {
  const Form2Page({super.key});

  @override
  _Form2PageState createState() => _Form2PageState();
}

class _Form2PageState extends State<Form2Page> {
  final _formKey = GlobalKey<FormState>();

  String _weddingLocation = ''; // 결혼식 장소

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('결혼식 장소 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '결혼식 장소'),
                validator: (value) => value!.isEmpty ? '장소를 입력하세요' : null,
                onSaved: (value) => _weddingLocation = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // 입력된 데이터 처리 (예: 데이터베이스 저장)
                    print('결혼식 장소: $_weddingLocation');

                    // 홈 화면으로 이동
                    GoRouter.of(context).go('/home');
                  }
                },
                child: const Text('정보 저장 및 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
