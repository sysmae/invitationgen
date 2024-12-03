import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'firebase_service.dart';

class InvitationsListPage extends StatefulWidget {
  const InvitationsListPage({super.key});

  @override
  _InvitationsListPageState createState() => _InvitationsListPageState();
}

class _InvitationsListPageState extends State<InvitationsListPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List _invitations = [];

  @override
  void initState() {
    super.initState();
    _loadInvitations(); // 초대장 목록 로드
  }

  // Firebase에서 초대장 목록 불러오기
  Future<void> _loadInvitations() async {
    String? userId = await _firebaseService.getUserId(); // 사용자 ID 가져오기
    if (userId != null) {
      List invitations = await _firebaseService.getInvitations(userId); // 초대장 목록 불러오기
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
      String? newInvitationId = await _firebaseService.initializeInvitation(userId: userId);

      if (newInvitationId != null) {
        // 새 초대장 생성 후 form0 페이지로 이동
        context.go('/form0/$newInvitationId'); // URL에 초대장 ID 포함
      } else {
        print('초대장 생성에 실패했습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset('asset/temporary_logo.png'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        title: Text('${data['groomName']} ♥ ${data['brideName']}'),
                        subtitle: Text('날짜: $weddingDateTime'),
                        onTap: () => context.go('/shareScreen/${invitation.id}'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Adjust this depending on the current page
        onTap: (index) {
          // Each tab should navigate to the appropriate page
          if (index == 0) {
            context.go('/invitations_list'); // Go to invitations list
          } else {
            context.go('/my_profile'); // Go to my profile
          }
        },
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
