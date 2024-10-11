import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore
      .instance; // Firestore 인스턴스

  // 현재 로그인된 사용자 ID 가져오기
  Future<String?> getUserId() async {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  // 초대장 생성
  Future<String?> createInvitation({
    required String userId,
    required String templateId,
    required String groomName,
    required String groomPhone,
    required String groomFatherName,
    required String groomFatherPhone,
    required String groomMotherName,
    required String groomMotherPhone,
    required String brideName,
    required String bridePhone,
    required String brideFatherName,
    required String brideFatherPhone,
    required String brideMotherName,
    required String brideMotherPhone,
    required DateTime weddingDateTime,
    required String weddingLocation,
    String? additionalAddress,
    String? additionalInstructions, // 추가 안내사항
    String? groomAccountNumber, // 신랑측 계좌번호
    String? brideAccountNumber, // 신부측 계좌번호
  }) async {
    try {
      // 필수 입력값 유효성 검사
      if (groomName.isEmpty || brideName.isEmpty || weddingLocation.isEmpty) {
        throw Exception("필수 입력값이 누락되었습니다.");
      }

      // users/{userId}/invitations에 문서 추가
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      CollectionReference invitationsRef = userRef.collection('invitations');

      // Firestore에 저장할 데이터
      Map<String, dynamic> invitationData = {
        'templateId': templateId,
        'groomName': groomName,
        'groomPhone': groomPhone,
        'groomFatherName': groomFatherName,
        'groomFatherPhone': groomFatherPhone,
        'groomMotherName': groomMotherName,
        'groomMotherPhone': groomMotherPhone,
        'brideName': brideName,
        'bridePhone': bridePhone,
        'brideFatherName': brideFatherName,
        'brideFatherPhone': brideFatherPhone,
        'brideMotherName': brideMotherName,
        'brideMotherPhone': brideMotherPhone,
        'weddingDateTime': weddingDateTime,
        'weddingLocation': weddingLocation,
        'additionalAddress': additionalAddress,
        'additionalInstructions': additionalInstructions, // 추가 안내사항 저장
        'createdAt': FieldValue.serverTimestamp(), // 문서 생성 시각 저장
      };

      // 계좌번호가 제공된 경우 추가
      if (groomAccountNumber != null) {
        invitationData['groomAccountNumber'] = groomAccountNumber;
      }
      if (brideAccountNumber != null) {
        invitationData['brideAccountNumber'] = brideAccountNumber;
      }

      // 초대장 생성 후 Document ID 반환
      DocumentReference invitationRef = await invitationsRef.add(
          invitationData);
      return invitationRef.id; // 초대장 Document ID 반환
    } catch (e) {
      print('Invitation creation failed: $e');
      return null; // 실패 시 null 반환
    }
  }

// 초대장 업데이트
  Future<void> updateInvitation({
    required String userId,
    required String invitationId,
    required String? weddingLocation, // null 가능a
    required String? additionalAddress, // null 가능
  }) async {
    try {
      // 사용자 문서 참조
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      // 초대장 문서 참조
      DocumentReference invitationRef = userRef.collection('invitations').doc(
          invitationId);

      // 업데이트할 데이터
      Map<String, dynamic> invitationData = {};

      // weddingLocation이 제공된 경우 추가
      if (weddingLocation != null) {
        invitationData['weddingLocation'] = weddingLocation;
      }

      // additionalAddress가 제공된 경우 추가
      if (additionalAddress != null) {
        invitationData['additionalAddress'] = additionalAddress;
      }

      // 업데이트할 데이터가 존재할 경우 초대장 데이터 업데이트
      if (invitationData.isNotEmpty) {
        await invitationRef.update(invitationData);
      }
    } catch (e) {
      print('Invitation update failed: $e');
    }
  }

  // 초대장 ID 가져오기 (예시)
  Future<String?> getInvitationId() async {
    // 사용자 ID 가져오기
    String? userId = await getUserId();
    if (userId == null) return null;

    // 사용자 초대장 목록에서 첫 번째 초대장 ID를 가져옴
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        // 사용자의 초대장 컬렉션에서 첫 번째 문서 가져오기
        QuerySnapshot invitationsSnapshot = await userDoc.reference.collection('invitations').limit(1).get();
        if (invitationsSnapshot.docs.isNotEmpty) {
          return invitationsSnapshot.docs.first.id; // 첫 번째 초대장 ID 반환
        }
      }
    } catch (e) {
      print('Failed to get invitation ID: $e');
    }
    return null; // 실패 시 null 반환
  }


  // 초대장 목록 가져오기
  Future<List<DocumentSnapshot>> getInvitations(String userId) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      QuerySnapshot querySnapshot = await userRef.collection('invitations').get();
      return querySnapshot.docs; // 초대장 문서 목록 반환
    } catch (e) {
      print('Failed to get invitations: $e');
      return []; // 실패 시 빈 목록 반환
    }
  }

}

