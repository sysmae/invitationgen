import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invitationgen/firebase_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Form1Page extends StatefulWidget {
  final String? invitationId;

  const Form1Page({Key? key, this.invitationId}) : super(key: key);

  @override
  _Form1PageState createState() => _Form1PageState();
}

class _Form1PageState extends State<Form1Page> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    if (widget.invitationId != null) {
      _loadInvitationData();
    } else {
      _setDefaultData(); // 기본 데이터 설정 함수 호출
    }
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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.invitationId == null ? '청첩장 생성' : '청첩장 수정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _groomNameController,
                decoration: const InputDecoration(labelText: '신랑 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요.' : null,
              ),
              TextFormField(
                controller: _groomPhoneController,
                decoration: const InputDecoration(labelText: '신랑 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요.' : null,
              ),
              TextFormField(
                controller: _groomFatherNameController,
                decoration: const InputDecoration(labelText: '신랑 아버지 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요.' : null,
              ),
              TextFormField(
                controller: _groomFatherPhoneController,
                decoration: const InputDecoration(labelText: '신랑 아버지 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요.' : null,
              ),
              TextFormField(
                controller: _groomMotherNameController,
                decoration: const InputDecoration(labelText: '신랑 어머니 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요.' : null,
              ),
              TextFormField(
                controller: _groomMotherPhoneController,
                decoration: const InputDecoration(labelText: '신랑 어머니 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요.' : null,
              ),
              TextFormField(
                controller: _brideNameController,
                decoration: const InputDecoration(labelText: '신부 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요.' : null,
              ),
              TextFormField(
                controller: _bridePhoneController,
                decoration: const InputDecoration(labelText: '신부 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요.' : null,
              ),
              TextFormField(
                controller: _brideFatherNameController,
                decoration: const InputDecoration(labelText: '신부 아버지 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요.' : null,
              ),
              TextFormField(
                controller: _brideFatherPhoneController,
                decoration: const InputDecoration(labelText: '신부 아버지 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요.' : null,
              ),
              TextFormField(
                controller: _brideMotherNameController,
                decoration: const InputDecoration(labelText: '신부 어머니 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요.' : null,
              ),
              TextFormField(
                controller: _brideMotherPhoneController,
                decoration: const InputDecoration(labelText: '신부 어머니 전화번호'),
                validator: (value) => value!.isEmpty ? '전화번호를 입력하세요.' : null,
              ),
              TextFormField(
                controller: _groomAccountController,
                decoration: const InputDecoration(labelText: '신랑 계좌번호'),
                validator: (value) => value!.isEmpty ? '계좌번호를 입력하세요.' : null,
              ),
              TextFormField(
                controller: _brideAccountController,
                decoration: const InputDecoration(labelText: '신부 계좌번호'),
                validator: (value) => value!.isEmpty ? '계좌번호를 입력하세요.' : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '결혼 날짜: ${DateFormat('yyyy-MM-dd').format(_weddingDate)}'),
                  ElevatedButton(
                    onPressed: _selectWeddingDate,
                    child: const Text('날짜 선택'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('결혼 시간: ${_weddingTime.format(context)}'),
                  ElevatedButton(
                    onPressed: _selectWeddingTime,
                    child: const Text('시간 선택'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/form0/${widget.invitationId}'),
                    child: const Text('이전'),
                  ),
                  ElevatedButton(
                    onPressed: _saveOrUpdateInvitation,
                    child: const Text('다음'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
