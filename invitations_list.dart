import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'firebase_service.dart';

class InvitationsListPage extends StatefulWidget {
  const InvitationsListPage({Key? key}) : super(key: key);

  @override
  _InvitationsListPageState createState() => _InvitationsListPageState();
}

class _InvitationsListPageState extends State<InvitationsListPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List _invitations = [];
  int _selectedIndex = 0; // "보관함"이 기본 선택된 탭으로 설정

  @override
  void initState() {
    super.initState();
    _loadInvitations(); // 초대장 목록 로드
  }

  // Firebase에서 초대장 목록 불러오기
  Future _loadInvitations() async {
    String? userId = await _firebaseService.getUserId(); // 사용자 ID 가져오기
    if (userId != null) {
      List invitations = await _firebaseService.getInvitations(
          userId); // 초대장 목록 불러오기
      setState(() {
        _invitations = invitations; // 초대장 목록 상태에 저장
      });
    }
  }

  // 새로운 초대장 생성
  Future<void> _createNewInvitation() async {
    String? userId = await _firebaseService.getUserId(); // 사용자 ID 가져오기
    if (userId != null) {
      // 새 초대장 생성
      String? newInvitationId = await _firebaseService.initializeInvitation(
          userId: userId);

      if (newInvitationId != null) {
        // 새 초대장 생성 후 form1 페이지로 이동
        context.go('/form0/$newInvitationId'); // URL에 초대장 ID 포함
      } else {
        print('초대장 생성에 실패했습니다.');
      }
    }
  }

  // 하단 네비게이션 탭 선택 핸들러
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 인덱스 업데이트
    });

    // 각 탭에 맞는 페이지로 이동
    if (index == 0) {
      context.go('/invitations_list'); // 보관함 페이지로 이동
    } else if (index == 1) {
      context.go('/my_profile'); // 내 정보 페이지로 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset(
            'asset/temporary_logo.png'
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            // Adjust padding as needed
            child: Text(
              '보관함',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
            Expanded(
              child: ListView.builder(
                itemCount: _invitations.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text('새 초대장 만들기'),
                        onTap: () => _createNewInvitation(),
                      ),
                    );
                  } else {
                    final invitation = _invitations[index - 1];
                    final data = invitation.data() as Map<String, dynamic>;
                    final weddingDateTime = data['weddingDateTime'] != null
                        ? (data['weddingDateTime'] as Timestamp).toDate()
                        : '날짜 정보 없음';

                    return Card(
                      child: ListTile(
                        title: Text(
                            '${data['groomName']} ♥ ${data['brideName']}'),
                        subtitle: Text('날짜: $weddingDateTime'),
                        onTap: () => context.go('/shareScreen/${invitation.id}'),
                      ),
                    );
                  }
                },
              ),
            ),],
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: '보관함',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
      ),
    );
  }
}
