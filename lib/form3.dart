import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'firebase_service.dart'; // FirebaseService를 import 합니다.

class Form3Page extends StatefulWidget {
  final String? invitationId;

  const Form3Page({Key? key, this.invitationId}) : super(key: key);

  @override
  _Form3PageState createState() => _Form3PageState();
}

class _Form3PageState extends State<Form3Page> {
  final _formKey = GlobalKey<FormState>();
  String _additionalInstructions = ''; // 추가 안내사항
  final TextEditingController _additionalInstructionsController = TextEditingController(); // 컨트롤러 추가
  final FirebaseService _firebaseService = FirebaseService(); // FirebaseService 인스턴스

  @override
  void initState() {
    super.initState();
    // 기존 데이터 로드
    if (widget.invitationId != null) {
      _loadExistingData(widget.invitationId!);
    }
  }

  @override
  void dispose() {
    _additionalInstructionsController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  Future<void> _loadExistingData(String invitationId) async {
    final data = await _firebaseService.getInvitationData(invitationId);
    if (data != null) {
      setState(() {
        _additionalInstructions = data['additionalInstructions'] ?? ''; // 기존 데이터 가져오기
        _additionalInstructionsController.text = _additionalInstructions; // 입력 필드에 기존 데이터 채우기
      });
    }
  }

  // 정보 업데이트 함수
  Future<void> _updateWeddingDetails(String userId) async {
    try {
      await _firebaseService.updateInvitation(
        userId: userId,
        invitationId: widget.invitationId!,
        additionalInstructions: _additionalInstructions,
      );
      // 성공적으로 업데이트된 경우
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정보가 성공적으로 업데이트되었습니다.')),
      );
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정보 업데이트 실패: $e')),
      );
    }
  }

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
                controller: _additionalInstructionsController, // 컨트롤러 설정
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    String? userId = await _firebaseService.getUserId();

                    // 입력된 데이터 처리 (예: Firebase에 저장)
                    if (userId != null && widget.invitationId != null) {
                      await _updateWeddingDetails(userId);
                    }

                    // 홈 화면으로 이동
                    GoRouter.of(context).go('/shareScreen/${widget.invitationId}');
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
