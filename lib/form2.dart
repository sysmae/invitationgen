import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart'; // Kpostal 패키지
import 'package:go_router/go_router.dart';
import 'firebase_service.dart'; // FirebaseService import

class Form2Page extends StatefulWidget {
  const Form2Page({Key? key}) : super(key: key); // 초대장 ID 제거

  @override
  _Form2PageState createState() => _Form2PageState();
}

class _Form2PageState extends State<Form2Page> {
  final _formKey = GlobalKey<FormState>();
  String _weddingLocation = ''; // 결혼식 장소
  String _selectedAddress = ''; // 선택된 주소
  final TextEditingController _addressController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService(); // FirebaseService 인스턴스 생성
  String? _invitationId; // 초대장 ID 변수 추가

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchInvitationId(); // 초대장 ID 가져오기
  }

  Future<void> _fetchInvitationId() async {
    // FirebaseService를 통해 초대장 ID 가져오기
    _invitationId = await _firebaseService.getInvitationId();
    setState(() {}); // 상태 업데이트
  }

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
              // 결혼식 장소 입력 필드
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '결혼식 장소 (주소)',
                ),
                validator: (value) => value!.isEmpty ? '장소를 입력하세요' : null,
                onSaved: (value) => _weddingLocation = value!,
              ),
              const SizedBox(height: 20),
              // 주소 선택 필드
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: '주소 선택',
                  suffixIcon: Icon(Icons.search),
                ),
                readOnly: true, // 텍스트 필드를 읽기 전용으로 설정
                validator: (value) => value!.isEmpty ? '주소를 선택하세요' : null,
                onTap: _searchAddress, // 텍스트 필드 클릭 시 주소 검색
              ),
              const SizedBox(height: 20),
              // 정보 저장 및 다음 페이지 이동 버튼
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // 현재 사용자 ID 가져오기
                    String? userId = await _firebaseService.getUserId();
                    if (userId != null && _invitationId != null) {
                      // 입력된 데이터 처리 (예: 데이터베이스 업데이트)
                      _updateWeddingDetails(userId, _invitationId!, _weddingLocation, _selectedAddress);

                      // Form3Page로 이동
                      GoRouter.of(context).go('/form3'); // /form3 경로로 이동
                    }
                  }
                },
                child: const Text('정보 저장 및 다음'),
              ),
            ],
          ),
        ),
      ),
      // FloatingActionButton으로 검색 버튼 추가
      floatingActionButton: FloatingActionButton(
        onPressed: _searchAddress,
        child: const Icon(Icons.search),
      ),
    );
  }

  void _searchAddress() async {
    // Kpostal 주소 선택 화면으로 이동
    Kpostal result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KpostalView()),
    );

    // 선택된 주소 출력 및 텍스트 필드에 설정
    if (result != null) {
      setState(() {
        _selectedAddress = result.address; // 선택된 주소 저장
        _addressController.text = _selectedAddress; // 텍스트 필드에 주소 설정
      });
    }
  }

  void _updateWeddingDetails(String userId, String invitationId, String location, String address) {
    // Firebase 또는 다른 데이터베이스에 데이터 업데이트 로직
    _firebaseService.updateInvitation(
      userId: userId,
      invitationId: invitationId,
      weddingLocation: location, // 결혼식 장소 업데이트
      additionalAddress: address, // 선택된 주소를 추가
    );
  }
}
