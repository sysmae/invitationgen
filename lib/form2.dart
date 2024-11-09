import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'firebase_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 파싱을 위한 라이브러리

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
  String _locationId = '';
  String _locationName = '';
  String _locationUrl = '';
  String _locationX = ''; // x 좌표
  String _locationY = ''; // y 좌표
  String _locationPhoneNumber = '';
  String _kakaoRoadUrl = '';
  String _naverRoadUrl = '';
  final TextEditingController _weddingLocationController =
      TextEditingController();
  final TextEditingController _additionalAddressController =
      TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  List<dynamic> _searchResults = []; // 검색 결과를 저장할 리스트
  bool _isSearching = false; // 검색 중 상태를 나타내는 플래그

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
    if (data != true) {
      setState(() {
        // 모든 필드 초기화
        _weddingLocation = data['weddingLocation'] ?? '';
        _additionalAddress = data['additionalAddress'] ?? '';
        _locationId = data['locationId'] ?? '';
        _locationName = data['locationName'] ?? '';
        _locationUrl = data['locationUrl'] ?? '';
        _locationPhoneNumber = data['locationPhoneNumber'] ?? '';
        _locationX = data['locationX'] ?? '';
        _locationY = data['locationY'] ?? '';
        _kakaoRoadUrl = data['kakaoRoadUrl'] ?? '';
        _naverRoadUrl = data['naverRoadUrl'] ?? '';

        // 입력 필드에 기존 데이터 채우기
        _weddingLocationController.text = _weddingLocation;
        _additionalAddressController.text = _additionalAddress;
      });
    }
  }

  // 주소 검색 함수
  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true; // 검색 중 상태로 설정
    });

    final String apiUrl =
        "https://dapi.kakao.com/v2/local/search/keyword.json?query=${Uri.encodeComponent(query)}";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization':
              'KakaoAK cc3b6f0b87a18890a26bfa187316dc73', // 'KakaoAK '와 REST API 키를 함께 사용
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _searchResults = responseData['documents']; // 검색 결과 리스트 업데이트
        });
      } else {
        print('카카오 API 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('검색 실패: $e');
    } finally {
      setState(() {
        _isSearching = false; // 검색 완료 후 상태 업데이트
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('asset/temporary_logo.png'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '결혼 장소 설정',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _weddingLocationController,
                decoration: const InputDecoration(
                  labelText: '결혼식 장소 (주소)',
                  suffixIcon: Icon(Icons.search),
                ),
                validator: (value) => value!.isEmpty ? '장소를 선택하세요' : null,
                onChanged: _searchAddress, // 사용자가 입력할 때마다 검색
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
              if (_isSearching)
                const CircularProgressIndicator(), // 검색 중일 때 로딩 아이콘 표시
              if (_searchResults.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true, // 리스트뷰가 다른 위젯과 겹치지 않도록 설정
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    var item = _searchResults[index];
                    return ListTile(
                      title: Text(
                          "${item['place_name']} (${item['address_name']})"),
                      subtitle: Text("전화번호: ${item['phone']}"),
                      onTap: () {
                        setState(() {
                          _weddingLocation = item['address_name'];
                          _weddingLocationController.text = _weddingLocation;
                          _locationId = item['id'];
                          _locationName = item['place_name'];
                          _locationUrl = item['place_url'];
                          _locationPhoneNumber = item['phone'];
                          _locationX = item['x']; // x 좌표 저장
                          _locationY = item['y']; // y 좌표 저장
                          _kakaoRoadUrl =
                              'https://map.kakao.com/link/to/' + item['id'];
                          _naverRoadUrl =
                              'https://map.naver.com/v5/search/${Uri.encodeComponent(item['place_name'] + ' ' + item['address_name'])}';
                          _searchResults = []; // 선택 후 검색 결과 비우기
                        });
                      },
                    );
                  },
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffffff6d)),
                    onPressed: () {
                      context.go('/form1/${widget.invitationId}');
                    },
                    child: const Text('이전'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffffff6d)),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        String? userId = await _firebaseService.getUserId();

                        if (userId != null && widget.invitationId != null) {
                          await _updateWeddingDetails(
                              userId,
                              widget.invitationId!,
                              _weddingLocation,
                              _locationId,
                              _locationName,
                              _locationUrl,
                              _locationPhoneNumber,
                              _additionalAddress,
                              _locationX, // 추가된 매개변수
                              _locationY, // 추가된 매개변수
                              _kakaoRoadUrl,
                              _naverRoadUrl);
                          context.go('/form3/${widget.invitationId}');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('정보를 가져오는 데 실패했습니다.')),
                          );
                        }
                      }
                    },
                    child: const Text('정보 저장 및 다음'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateWeddingDetails(
      String userId,
      String invitationId,
      String location,
      String locationId,
      String locationName,
      String locationUrl,
      String locationPhoneNumber,
      String additionalAddress,
      String locationX, // 추가된 매개변수
      String locationY, // 추가된 매개변수
      String kakaoRoadUrl,
      String naverRoadUrl) async {
    // Firebase에 데이터 업데이트
    await _firebaseService.updateInvitation(
        invitationId: invitationId,
        userId: userId,
        weddingLocation: location,
        locationId: locationId,
        locationName: locationName,
        locationUrl: locationUrl,
        locationPhoneNumber: locationPhoneNumber,
        additionalAddress: additionalAddress,
        locationX: locationX, // 추가된 매개변수
        locationY: locationY, // 추가된 매개변수
        kakaoRoadUrl: kakaoRoadUrl,
        naverRoadUrl: naverRoadUrl);
  }
}
