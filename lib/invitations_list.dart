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

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future _loadInvitations() async {
    String? userId = await _firebaseService.getUserId();
    if (userId != null) {
      List invitations = await _firebaseService.getInvitations(userId);
      setState(() {
        _invitations = invitations;
      });
    }
  }

  Future<void> _createNewInvitation() async {
    String? userId = await _firebaseService.getUserId();
    if (userId != null) {
      // 초대장 생성 후 초대장 ID 반환
      String? newInvitationId = await _firebaseService.initializeInvitation(userId: userId, templateId: "1");

      if (newInvitationId != null) {
        // form1 페이지로 이동하며 invitationId 전달
        context.go('/form1/$newInvitationId');  // URL 경로에 invitationId를 포함
      } else {
        print('초대장 생성에 실패했습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 초대장 목록')),
      body: ListView.builder(
        itemCount: _invitations.length + 1, // +1 for the "Create New Invitation" card
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Create New Invitation" card
            return Card(
              child: ListTile(
                leading: const Icon(Icons.add),
                title: const Text('새 초대장 만들기'),
                onTap: () => _createNewInvitation(), // 새로운 초대장 생성
              ),
            );
          } else {
            // Existing invitation cards
            final invitation = _invitations[index - 1];
            final data = invitation.data() as Map<String, dynamic>;

            // Null check for weddingDateTime
            final weddingDateTime = data['weddingDateTime'] != null
                ? (data['weddingDateTime'] as Timestamp).toDate()
                : '날짜 정보 없음';

            return Card(
              child: ListTile(
                title: Text('${data['groomName']} ♥ ${data['brideName']}'),
                subtitle: Text('날짜: $weddingDateTime'),
                onTap: () => context.go('/form1/${invitation.id}'), // invitationId를 URL 경로에 포함
              ),
            );
          }
        },
      ),
    );
  }
}
