import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_service.dart';
import 'package:flutter/services.dart';

class ShareScreen extends StatelessWidget {
  final String? invitationId;

  ShareScreen({Key? key, this.invitationId}) : super(key: key);

  static const String baseUrl = 'https://invitationgen-7eb56.firebaseapp.com/invitation';

  Future<String> _generateInvitationUrl() async {
    String? userId = await FirebaseService().getUserId();
    if (userId != null) {
      // Return the URL with userId and invitationId
      return '$baseUrl/$userId/$invitationId';
    } else {
      throw '사용자 ID를 가져올 수 없습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('asset/temporary_logo.png'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.go('/invitations_list'),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: FirebaseService().getInvitationData(invitationId!), // Ensure this returns a non-nullable Map
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) { // Check for null data
            return const Center(child: Text('데이터가 없습니다.'));
          }

          final data = snapshot.data!; // Safe to access since we've checked for null

          // Get wedding date time safely
          final weddingDateTime = data['weddingDateTime'];
          String weddingDateTimeString = weddingDateTime != null ? weddingDateTime.toDate().toString() : '정보 없음';

          // Dynamically create the FeedTemplate based on Firebase data
          final FeedTemplate defaultFeed = FeedTemplate(
            content: Content(
              title: '초대장: ${data['groomName']} ♥ ${data['brideName']}',
              description: weddingDateTimeString,
              imageUrl: Uri.parse('https://example.com/image.png'),
              link: Link(
                webUrl: Uri.parse('${data['shareLink']}'), // Update to use the correct URL
                mobileWebUrl: Uri.parse('${data['shareLink']}'), // Update to use the correct URL
              ),

            ),
            // itemContent: ItemContent(
            //   profileText: 'Kakao',
            //   profileImageUrl: Uri.parse('https://example.com/profile.png'), // Update with a profile image if available
            //   titleImageUrl: Uri.parse('https://example.com/title_image.png'), // Update with a title image if available
            //   titleImageText: '초대장 정보',
            //   titleImageCategory: 'invitation',
            //   items: [
            //     ItemInfo(item: '신랑: ${data['groomName'] ?? '정보 없음'}', itemOp: ''),
            //     ItemInfo(item: '신부: ${data['brideName'] ?? '정보 없음'}', itemOp: ''),
            //     ItemInfo(item: '결혼 날짜: $weddingDateTimeString', itemOp: ''),
            //     ItemInfo(item: '장소: ${data['locationName'] ?? '정보 없음'}', itemOp: ''),
            //     ItemInfo(item: '추가 안내: ${data['additionalInstructions'] ?? '정보 없음'}', itemOp: ''),
            //   ],
            //   sum: '총합',
            //   sumOp: '특별한 날!',
            // ),
            // social: Social(likeCount: 286, commentCount: 45, sharedCount: 845),
            buttons: [
              Button(
                title: '웹으로 보기',
                link: Link(
                  webUrl: Uri.parse('${data['shareLink']}'), // Update to use the correct URL
                  mobileWebUrl: Uri.parse('${data['shareLink']}'), // Update to use the correct URL
                ),
              ),
              Button(
                title: '앱으로보기',
                link: Link(
                  androidExecutionParams: {'key1': 'value1', 'key2': 'value2'},
                  iosExecutionParams: {'key1': 'value1', 'key2': 'value2'},
                ),
              ),
            ],
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '초대장 정보',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('신랑: ${data['groomName'] ?? '정보 없음'}'),
                Text('신부: ${data['brideName'] ?? '정보 없음'}'),
                Text('결혼 날짜: $weddingDateTimeString'),
                Text('장소: ${data['locationName'] ?? '정보 없음'}'),
                Text('추가 안내사항: ${data['additionalInstructions'] ?? '정보 없음'}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final invitationUrl = await _generateInvitationUrl();
                      await Clipboard.setData(ClipboardData(text: invitationUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('링크가 클립보드에 복사되었습니다.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$e')),
                      );
                    }
                  },
                  child: const Text('초대장 링크 복사하기'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();

                    if (isKakaoTalkSharingAvailable) {
                      try {
                        Uri uri = await ShareClient.instance.shareDefault(template: defaultFeed);
                        await ShareClient.instance.launchKakaoTalk(uri);
                        print('카카오톡 공유 완료');
                      } catch (error) {
                        print('설치 카카오톡 공유 실패 $error');
                      }
                    } else {
                      try {
                        Uri shareUrl = await WebSharerClient.instance.makeDefaultUrl(template: defaultFeed);
                        await launch(shareUrl.toString());
                      } catch (error) {
                        print('미설치 카카오톡 공유 실패 $error');
                      }
                    }
                  },
                  child: const Text('Share via KakaoTalk'),
                ),
                ElevatedButton(
                  onPressed: () => GoRouter.of(context).go('/form0/${invitationId}'),
                  child: const Text('초대장 수정하기'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final invitationUrl = await _generateInvitationUrl();
                      if (await canLaunch(invitationUrl)) {
                        await launch(invitationUrl);
                      } else {
                        throw 'URL을 열 수 없습니다: $invitationUrl';
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$e')),
                      );
                    }
                  },
                  child: const Text('웹에서 초대장 보기'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).go('/invitations_list');
                  },
                  child: const Text('초대장 목록으로 돌아가기'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      String? userId = await FirebaseService().getUserId();
                      if (userId != null) {
                        await FirebaseService().deleteInvitation(userId, invitationId!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('초대장이 삭제되었습니다.')),
                        );
                        GoRouter.of(context).go('/invitations_list');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('사용자 ID를 가져올 수 없습니다.')),
                      );
                    }
                  },
                  child: const Text('초대장 삭제하기'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
