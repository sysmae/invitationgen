import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_service.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ShareScreen extends StatefulWidget {
  final String? invitationId;

  ShareScreen({Key? key, this.invitationId}) : super(key: key);

  static const String baseUrl =
      'https://invitationgen-7eb56.firebaseapp.com/invitation';

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko', null);
  }

  Future<String> _generateInvitationUrl() async {
    String? userId = await FirebaseService().getUserId();
    if (userId != null) {
      return '${ShareScreen.baseUrl}/$userId/${widget.invitationId}';
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
        future: FirebaseService().getInvitationData(widget.invitationId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('데이터가 없습니다.'));
          }

          final data = snapshot.data!;
          final weddingDateTime = data['weddingDateTime'];
          String weddingDateTimeString = weddingDateTime != null
              ? DateFormat("yyyy년 MM월 dd일 EEEE a hh시 mm분", "ko")
              .format(weddingDateTime.toDate())
              : '정보 없음';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    '초대장 정보',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                _buildCopyLinkButton(context),
                _buildKakaoShareButton(context, data, weddingDateTimeString),
                _buildEditInvitationButton(context),
                _buildViewInvitationButton(context),
                _buildBackToListButton(context),
                _buildDeleteInvitationButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCopyLinkButton(BuildContext context) {
    return ElevatedButton(
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
    );
  }

  Widget _buildKakaoShareButton(
      BuildContext context, Map<String, dynamic> data, String weddingDateTimeString) {
    return ElevatedButton(
      onPressed: () async {
        bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
        int templateId = 113904;
        if (isKakaoTalkSharingAvailable) {
          try {
            Uri uri = await ShareClient.instance.shareCustom(templateId: templateId);
            await ShareClient.instance.launchKakaoTalk(uri);
          } catch (error) {
            print('카카오톡 공유 실패: $error');
          }
        } else {
          try {
            Uri shareUrl = await WebSharerClient.instance.makeCustomUrl(
              templateId: templateId,
              templateArgs: {
                'userId': '${data['userId']}',
                'invitationId': '${data['invitationId']}',
                'groomName': '${data['groomName']}',
                'brideName': '${data['brideName']}',
                'weddingDateTimeString': weddingDateTimeString,
              },
            );
            await launch(shareUrl.toString());
          } catch (error) {
            print('웹 공유 실패: $error');
          }
        }
      },
      child: const Text('Share via KakaoTalk'),
    );
  }

  Widget _buildEditInvitationButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => GoRouter.of(context).go('/form0/${widget.invitationId}'),
      child: const Text('초대장 수정하기'),
    );
  }

  Widget _buildViewInvitationButton(BuildContext context) {
    return ElevatedButton(
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
    );
  }

  Widget _buildBackToListButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => GoRouter.of(context).go('/invitations_list'),
      child: const Text('초대장 목록으로 돌아가기'),
    );
  }

  Widget _buildDeleteInvitationButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          String? userId = await FirebaseService().getUserId();
          if (userId != null) {
            await FirebaseService().deleteInvitation(userId, widget.invitationId!);
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
    );
  }
}
