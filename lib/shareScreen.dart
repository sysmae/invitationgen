import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // url_launcher 패키지를 import 합니다.
import 'firebase_service.dart'; // FirebaseService를 import 합니다.

class ShareScreen extends StatelessWidget {
  final String? invitationId;

  const ShareScreen({Key? key, this.invitationId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('초대장 공유')),
      body: FutureBuilder(
        future: FirebaseService().getInvitationData(invitationId!), // 초대장 데이터 가져오기
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('데이터가 없습니다.'));
          }

          final data = snapshot.data as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '초대장 정보',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text('신랑: ${data['groomName'] ?? '정보 없음'}'),
                Text('신부: ${data['brideName'] ?? '정보 없음'}'),
                Text('결혼 날짜: ${data['weddingDate'] ?? '정보 없음'}'),
                Text('장소: ${data['location'] ?? '정보 없음'}'),
                Text('추가 안내사항: ${data['additionalInstructions'] ?? '정보 없음'}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // 공유할 텍스트 생성
                    final String shareContent =
                        '신랑: ${data['groomName']}\n'
                        '신부: ${data['brideName']}\n'
                        '결혼 날짜: ${data['weddingDate']}\n'
                        '장소: ${data['location']}\n'
                        '추가 안내사항: ${data['additionalInstructions']}';

                    // 공유 기능 호출
                  },
                  child: const Text('초대장 공유하기'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // 초대장 목록으로 돌아가기
                    Navigator.of(context).pop(); // 이전 화면으로 돌아가기
                  },
                  child: const Text('초대장 목록으로 돌아가기'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // 사용자 ID를 가져옵니다.
                    String? userId = await FirebaseService().getUserId(); // FirebaseService를 통해 userId 가져오기
                    if (userId != null) {
                      final String invitationUrl =
                          'https://invitationgen-7eb56.firebaseapp.com/invitation/$userId/$invitationId';

                      // URL을 웹 브라우저에서 열기
                      if (await canLaunch(invitationUrl)) {
                        await launch(invitationUrl);
                      } else {
                        throw 'URL을 열 수 없습니다: $invitationUrl';
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('사용자 ID를 가져올 수 없습니다.')),
                      );
                    }
                  },
                  child: const Text('웹에서 초대장 보기'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
