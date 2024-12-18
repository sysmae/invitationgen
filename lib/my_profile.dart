import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    setState(() {
      _user = _auth.currentUser;
    });
  }

  Future<void> _updateDisplayName(String newDisplayName) async {
    if (_user != null) {
      try {
        await _user!.updateDisplayName(newDisplayName);
        await _user!.reload();
        _loadUserProfile(); // 프로필 새로고침
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 업데이트 성공')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 업데이트 실패: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (_user != null) {
      try {
        final userId = _user!.uid;

        // Firestore에서 사용자 데이터 삭제
        await _firestore.collection('users').doc(userId).delete();

        // Firestore에서 사용자와 관련된 서브 콜렉션 삭제 (예시로 'userId'라는 이름의 콜렉션을 삭제)
        final userCollectionRef = _firestore.collection(userId);
        final subCollectionSnapshots = await userCollectionRef.get();

        for (var doc in subCollectionSnapshots.docs) {
          await doc.reference.delete();
        }

        // Firebase Authentication에서 사용자 삭제
        await _user!.delete();

        // 계정 삭제 후 로그인 페이지로 이동
        context.go('/');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('계정이 삭제되었습니다.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계정 삭제 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('asset/temporary_logo.png'),
        backgroundColor: Colors.white,
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '사용자 정보',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Text(
                        _user?.displayName?.isNotEmpty == true
                            ? _user!.displayName![0].toUpperCase()
                            : 'U', // Default letter
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _user?.displayName ?? '이름 정보 없음',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _user?.email ?? '이메일 정보 없음',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffffff6d),
                      ),
                      onPressed: () async {
                        // 이름 업데이트를 위한 다이얼로그 띄우기
                        final newDisplayName =
                        await _showUpdateNameDialog();
                        if (newDisplayName != null &&
                            newDisplayName.isNotEmpty) {
                          _updateDisplayName(newDisplayName);
                        }
                      },
                      child: const Text('이름 수정'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffffff6d),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        context.go('/'); // 로그아웃 후 보관함으로 이동
                      },
                      child: const Text('로그아웃'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        // 계정 삭제 확인 다이얼로그 표시
                        final confirm = await _showDeleteConfirmDialog();
                        if (confirm == true) {
                          _deleteAccount();
                        }
                      },
                      child: const Text('계정 삭제'),
                    ),
                  ],
                ),
              ],
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

  Future<String?> _showUpdateNameDialog() async {
    String? newName;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('이름 수정'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: const InputDecoration(hintText: '새 이름 입력'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 취소
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(newName); // 새 이름 반환
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('계정 삭제'),
          content: const Text('정말로 계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 취소
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 확인
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
