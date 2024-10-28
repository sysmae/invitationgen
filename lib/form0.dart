import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'firebase_service.dart';

class Form0Page extends StatefulWidget {
  final String? invitationId;

  const Form0Page({Key? key, this.invitationId}) : super(key: key);

  @override
  _Form0PageState createState() => _Form0PageState();
}

class _Form0PageState extends State<Form0Page> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedTemplateId = '';
  int _currentPageIndex = 0; // 현재 페이지 인덱스

  @override
  void initState() {
    super.initState();
    // 기존 데이터 로드
    if (widget.invitationId != null) {
      _loadExistingData(widget.invitationId!);
    }
  }

  Future<void> _loadExistingData(String invitationId) async {
    final data = await _firebaseService.getInvitationData(invitationId);
    if (data != null) {
      setState(() {
        _selectedTemplateId = data['templateId'] ?? '';
        // 페이지 인덱스를 선택한 템플릿 ID에 맞게 설정
        _currentPageIndex = int.tryParse(_selectedTemplateId) != null
            ? int.parse(_selectedTemplateId) - 1 // 0부터 시작하므로 1을 빼줍니다.
            : 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('템플릿 선택')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: PageView(
              controller: PageController(initialPage: _currentPageIndex),
              onPageChanged: (index) {
                setState(() {
                  _selectedTemplateId = (index + 1).toString(); // 페이지 변경 시 템플릿 ID 업데이트
                });
              },
              children: [
                _buildTemplateCard('1', '템플릿 1'),
                _buildTemplateCard('2', '템플릿 2'),
                _buildTemplateCard('3', '템플릿 3'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_selectedTemplateId.isNotEmpty) {
                String? userId = await _firebaseService.getUserId();
                if (userId != null && widget.invitationId != null) {
                  await _updateTemplateId(userId, widget.invitationId!, _selectedTemplateId);
                  // Form1Page로 invitationId 전달
                  context.go('/form1/${widget.invitationId}');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('정보를 가져오는 데 실패했습니다.')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('템플릿을 선택하세요.')),
                );
              }
            },
            child: const Text('정보 저장 및 다음'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(String templateId, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTemplateId = templateId; // 선택한 템플릿 ID 저장
          // 템플릿 ID 선택 시 페이지 변경
          _navigateToNextPage(templateId);
        });
      },
      child: Card(
        color: _selectedTemplateId == templateId ? Colors.blue : Colors.white,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _selectedTemplateId == templateId ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToNextPage(String templateId) {
    // 선택한 템플릿 ID에 따라 다음 페이지로 이동
    context.go('/form1/${widget.invitationId}');
  }

  Future<void> _updateTemplateId(String userId, String invitationId, String templateId) async {
    try {
      await _firebaseService.updateInvitation(
        userId: userId,
        invitationId: invitationId,
        templateId: templateId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('템플릿 ID가 업데이트되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정보 업데이트 실패: $e')),
      );
    }
  }
}