import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invitationgen/firebase_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Form1Page extends StatefulWidget {
  final String? invitationId;
  final int initialPage;

  const Form1Page({Key? key, this.invitationId, this.initialPage = 0})
      : super(key: key);

  @override
  _Form1PageState createState() => _Form1PageState();
}

class _Form1PageState extends State<Form1Page> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late PageController _pageController;

  int _currentPage = 0;

  final _groomFormKey = GlobalKey<FormState>();
  final _brideFormKey = GlobalKey<FormState>();
  final _weddingFormKey = GlobalKey<FormState>();
  // Text field controllers
  final TextEditingController _groomNameController = TextEditingController();
  final TextEditingController _groomPhoneController = TextEditingController();
  final TextEditingController _groomFatherNameController =
      TextEditingController();
  final TextEditingController _groomFatherPhoneController =
      TextEditingController();
  final TextEditingController _groomMotherNameController =
      TextEditingController();
  final TextEditingController _groomMotherPhoneController =
      TextEditingController();
  final TextEditingController _brideNameController = TextEditingController();
  final TextEditingController _bridePhoneController = TextEditingController();
  final TextEditingController _brideFatherNameController =
      TextEditingController();
  final TextEditingController _brideFatherPhoneController =
      TextEditingController();
  final TextEditingController _brideMotherNameController =
      TextEditingController();
  final TextEditingController _brideMotherPhoneController =
      TextEditingController();
  final TextEditingController _groomAccountController = TextEditingController();
  final TextEditingController _brideAccountController = TextEditingController();

  DateTime _weddingDate = DateTime.now();
  TimeOfDay _weddingTime = TimeOfDay.now();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
    _pageController = PageController(initialPage: widget.initialPage);
    if (widget.invitationId != null) {
      _loadInvitationData();
    } else {
      _setDefaultData(); // 기본 데이터 설정 함수 호출
    }
    _currentPage = widget.initialPage;
  }

  Future<void> _getUserId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    } else {
      context.go('/login');
    }
  }

  Future<void> _loadInvitationData() async {
    var invitationData =
        await _firebaseService.getInvitationData(widget.invitationId!);
    if (invitationData != null) {
      setState(() {
        _groomNameController.text = invitationData['groomName'] ?? '';
        _groomPhoneController.text = invitationData['groomPhone'] ?? '';
        _groomFatherNameController.text =
            invitationData['groomFatherName'] ?? '';
        _groomFatherPhoneController.text =
            invitationData['groomFatherPhone'] ?? '';
        _groomMotherNameController.text =
            invitationData['groomMotherName'] ?? '';
        _groomMotherPhoneController.text =
            invitationData['groomMotherPhone'] ?? '';
        _brideNameController.text = invitationData['brideName'] ?? '';
        _bridePhoneController.text = invitationData['bridePhone'] ?? '';
        _brideFatherNameController.text =
            invitationData['brideFatherName'] ?? '';
        _brideFatherPhoneController.text =
            invitationData['brideFatherPhone'] ?? '';
        _brideMotherNameController.text =
            invitationData['brideMotherName'] ?? '';
        _brideMotherPhoneController.text =
            invitationData['brideMotherPhone'] ?? '';
        _groomAccountController.text =
            invitationData['groomAccountNumber'] ?? '';
        _brideAccountController.text =
            invitationData['brideAccountNumber'] ?? '';
        _weddingDate =
            (invitationData['weddingDateTime'] as Timestamp).toDate();
        _weddingTime = TimeOfDay.fromDateTime(_weddingDate);
      });
    } else {
      _setDefaultData(); // 데이터가 없을 때 기본 데이터 설정
    }
  }

  void _setDefaultData() {
    setState(() {
      _groomNameController.text = '신랑 이름';
      _groomPhoneController.text = '신랑 전화번호';
      _groomFatherNameController.text = '신랑 아버지 이름';
      _groomFatherPhoneController.text = '신랑 아버지 전화번호';
      _groomMotherNameController.text = '신랑 어머니 이름';
      _groomMotherPhoneController.text = '신랑 어머니 전화번호';
      _brideNameController.text = '신부 이름';
      _bridePhoneController.text = '신부 전화번호';
      _brideFatherNameController.text = '신부 아버지 이름';
      _brideFatherPhoneController.text = '신부 아버지 전화번호';
      _brideMotherNameController.text = '신부 어머니 이름';
      _brideMotherPhoneController.text = '신부 어머니 전화번호';
      _groomAccountController.text = '신랑 계좌번호';
      _brideAccountController.text = '신부 계좌번호';
    });
  }

  String? _validateName(String? value) {
    return value!.isEmpty ? '이름을 입력하세요.' : null;
  }

  String? _validatePhone(String? value) {
    if (value!.isEmpty) return '전화번호를 입력하세요.';
    final phoneRegExp = RegExp(r'^[0-9]+$');
    return phoneRegExp.hasMatch(value) ? null : '유효한 전화번호를 입력하세요.';
  }

  String? _validateAccount(String? value) {
    if (value!.isEmpty) return '계좌번호를 입력하세요.';
    final accountRegExp = RegExp(r'^[0-9]+$');
    return accountRegExp.hasMatch(value) ? null : '유효한 계좌번호를 입력하세요.';
  }

  Future<void> _selectWeddingDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _weddingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _weddingDate)
      setState(() {
        _weddingDate = picked;
      });
  }

  Future<void> _selectWeddingTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _weddingTime,
    );
    if (picked != null && picked != _weddingTime)
      setState(() {
        _weddingTime = picked;
      });
  }

  Future<void> _saveOrUpdateInvitation() async {
    if (_weddingFormKey.currentState!.validate()) {
      _weddingFormKey.currentState!.save();
      try {
        DateTime weddingDateTime = DateTime(
          _weddingDate.year,
          _weddingDate.month,
          _weddingDate.day,
          _weddingTime.hour,
          _weddingTime.minute,
        );

        if (widget.invitationId != null) {
          // Update existing invitation
          await _firebaseService.updateInvitation(
            userId: _userId!,
            invitationId: widget.invitationId!,
            groomName: _groomNameController.text,
            groomPhone: _groomPhoneController.text,
            groomFatherName: _groomFatherNameController.text,
            groomFatherPhone: _groomFatherPhoneController.text,
            groomMotherName: _groomMotherNameController.text,
            groomMotherPhone: _groomMotherPhoneController.text,
            brideName: _brideNameController.text,
            bridePhone: _bridePhoneController.text,
            brideFatherName: _brideFatherNameController.text,
            brideFatherPhone: _brideFatherPhoneController.text,
            brideMotherName: _brideMotherNameController.text,
            brideMotherPhone: _brideMotherPhoneController.text,
            weddingDateTime: weddingDateTime,
            groomAccountNumber: _groomAccountController.text,
            brideAccountNumber: _brideAccountController.text,
          );
        }

        // Navigate to Form2Page
        context.go('/form2/${widget.invitationId}');
      } catch (error) {
        print('청첩장 생성/수정 실패: $error');
      }
    }
  }

  void _nextPage() {
    //다음 페이지로. 마지막 페이지면 작동 하지 않음
    if (_currentPage == 0 && _groomFormKey.currentState!.validate()) {
      // 첫 번째 페이지에서 신랑 정보 폼을 검증한 후에만 다음 페이지로 이동
      _currentPage++;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else if (_currentPage == 1 && _brideFormKey.currentState!.validate()) {
      // 두 번째 페이지에서 신부 정보 폼을 검증한 후에만 다음 페이지로 이동
      _currentPage++;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else if (_currentPage == 2 && _weddingFormKey.currentState!.validate()) {
      // 마지막 페이지에 도달했을 때는 초대장을 저장
      _saveOrUpdateInvitation();
    }
  }

  void _prevPage() {
    //이전 페이지로. 첫 페이지면 작동하지 않음
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _groomNameController.dispose();
    _groomPhoneController.dispose();
    _groomFatherNameController.dispose();
    _groomFatherPhoneController.dispose();
    _groomMotherNameController.dispose();
    _groomMotherPhoneController.dispose();
    _brideNameController.dispose();
    _bridePhoneController.dispose();
    _brideFatherNameController.dispose();
    _brideFatherPhoneController.dispose();
    _brideMotherNameController.dispose();
    _brideMotherPhoneController.dispose();
    _groomAccountController.dispose();
    _brideAccountController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Image.asset('asset/temporary_logo.png'),
          backgroundColor: Colors.white,
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SingleChildScrollView(
              child: Form(
                key: _groomFormKey,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text('신랑 정보 입력',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black))),
                        TextFormField(
                          controller: _groomNameController,
                          decoration: const InputDecoration(labelText: '신랑 이름'),
                          validator: _validateName,
                        ),
                        TextFormField(
                          controller: _groomPhoneController,
                          decoration:
                              const InputDecoration(labelText: '신랑 전화번호'),
                          validator: _validatePhone,
                        ),
                        TextFormField(
                          controller: _groomFatherNameController,
                          decoration:
                              const InputDecoration(labelText: '신랑 아버지 이름'),
                          validator: _validateName,
                        ),
                        TextFormField(
                          controller: _groomFatherPhoneController,
                          decoration:
                              const InputDecoration(labelText: '신랑 아버지 전화번호'),
                          validator: _validatePhone,
                        ),
                        TextFormField(
                          controller: _groomMotherNameController,
                          decoration:
                              const InputDecoration(labelText: '신랑 어머니 이름'),
                          validator: _validateName,
                        ),
                        TextFormField(
                          controller: _groomMotherPhoneController,
                          decoration:
                              const InputDecoration(labelText: '신랑 어머니 전화번호'),
                          validator: _validatePhone,
                        ),
                        TextFormField(
                          controller: _groomAccountController,
                          decoration:
                              const InputDecoration(labelText: '신랑 계좌번호'),
                          validator: _validateAccount,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffffff6d)),
                                onPressed: () {
                                  context.go('/form0/${widget.invitationId}');
                                },
                                child: const Text('템플릿 설정')),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffffff6d)),
                                onPressed: () {
                                  _nextPage();
                                },
                                child: const Text('신부 정보 입력')),
                          ],
                        )
                      ],
                    )),
              ),
            ),
            SingleChildScrollView(
              child: Form(
                  key: _brideFormKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text('신부 정보 입력',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black))),
                        TextFormField(
                          controller: _brideNameController,
                          decoration: const InputDecoration(labelText: '신부 이름'),
                          validator: _validateName,
                        ),
                        TextFormField(
                          controller: _bridePhoneController,
                          decoration:
                              const InputDecoration(labelText: '신부 전화번호'),
                          validator: _validatePhone,
                        ),
                        TextFormField(
                          controller: _brideFatherNameController,
                          decoration:
                              const InputDecoration(labelText: '신부 아버지 이름'),
                          validator: _validateName,
                        ),
                        TextFormField(
                          controller: _brideFatherPhoneController,
                          decoration:
                              const InputDecoration(labelText: '신부 아버지 전화번호'),
                          validator: _validatePhone,
                        ),
                        TextFormField(
                          controller: _brideMotherNameController,
                          decoration:
                              const InputDecoration(labelText: '신부 어머니 이름'),
                          validator: _validateName,
                        ),
                        TextFormField(
                          controller: _brideMotherPhoneController,
                          decoration:
                              const InputDecoration(labelText: '신부 어머니 전화번호'),
                          validator: _validatePhone,
                        ),
                        TextFormField(
                          controller: _brideAccountController,
                          decoration:
                              const InputDecoration(labelText: '신부 계좌번호'),
                          validator: _validateAccount,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffffff6d)),
                                onPressed: () {
                                  _prevPage();
                                },
                                child: const Text('신랑 정보 입력')),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffffff6d)),
                                onPressed: () {
                                  _nextPage();
                                },
                                child: const Text('날짜 및 장소 입력')),
                          ],
                        )
                      ],
                    ),
                  )),
            ),
            Form(
              key: _weddingFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text('날짜 및 시간 선택',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Wedding Date: ${DateFormat('yyyy-MM-dd').format(_weddingDate)}'),
                      ElevatedButton(
                          onPressed: _selectWeddingDate,
                          child: const Text('날짜 선택')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('결혼 시간: ${_weddingTime.format(context)}'),
                      ElevatedButton(
                          onPressed: _selectWeddingTime,
                          child: const Text('시간 선택')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffffff6d)),
                          onPressed: _prevPage,
                          child: const Text('신부 정보 입력')),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffffff6d)),
                          onPressed: _saveOrUpdateInvitation,
                          child: const Text('다음 단계로')),
                    ],
                  ),
                ]),
              ),
            )
          ],
        ));
  }
}
