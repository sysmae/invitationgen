import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';
import 'package:go_router/go_router.dart';
import 'firebase_service.dart';

class Form2Page extends StatefulWidget {
  final String? invitationId;
  const Form2Page({Key? key, this.invitationId}) : super(key: key);

  @override
  _Form2PageState createState() => _Form2PageState();
}

class _Form2PageState extends State<Form2Page> {
  final _formKey = GlobalKey<FormState>();
  String _weddingLocation = '';
  String _additionalAddress = '';
  final TextEditingController _weddingLocationController = TextEditingController();
  final TextEditingController _additionalAddressController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

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
    _weddingLocationController.dispose();
    _additionalAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData(String invitationId) async {
    final data = await _firebaseService.getInvitationData(invitationId);
    if (data != null) {
      setState(() {
        _weddingLocation = data['weddingLocation'] ?? '';
        _additionalAddress = data['additionalAddress'] ?? '';
        _weddingLocationController.text = _weddingLocation; // 입력 필드에 기존 데이터 채우기
        _additionalAddressController.text = _additionalAddress;
      });
    }
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
              const SizedBox(height: 20),
              TextFormField(
                controller: _weddingLocationController,
                decoration: const InputDecoration(
                  labelText: '결혼식 장소 (주소)',
                  suffixIcon: Icon(Icons.search),
                ),
                readOnly: true,
                validator: (value) => value!.isEmpty ? '장소를 선택하세요' : null,
                onTap: _searchAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _additionalAddressController,
                decoration: const InputDecoration(
                  labelText: '상세 주소',
                ),
                validator: (value) => value!.isEmpty ? '상세 주소를 입력하세요' : null,
                onSaved: (value) => _additionalAddress = value!,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 버튼을 양쪽으로 배치
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/form1/${widget.invitationId}'), // 이전 페이지로 이동
                    child: const Text('이전'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        String? userId = await _firebaseService.getUserId();

                        if (userId != null && widget.invitationId != null) {
                          await _updateWeddingDetails(
                            userId,
                            widget.invitationId!,
                            _weddingLocation,
                            _additionalAddress,
                          );
                          // Form3Page로 invitationId 전달
                          context.go('/form3/${widget.invitationId}');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('정보를 가져오는 데 실패했습니다.')),
                          );
                        }
                      }
                    },
                    child: const Text('정보 저장 및 다음'), // 텍스트 버튼
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _searchAddress() async {
    Kpostal result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KpostalView()),
    );

    if (result != null) {
      setState(() {
        _weddingLocation = result.address;
        _weddingLocationController.text = _weddingLocation;
      });
    }
  }

  Future<void> _updateWeddingDetails(String userId, String invitationId, String location, String additionalAddress) async {
    try {
      await _firebaseService.updateInvitation(
        userId: userId,
        invitationId: invitationId,
        weddingLocation: location,
        additionalAddress: additionalAddress,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정보 업데이트 실패: $e')),
      );
    }
  }
}
