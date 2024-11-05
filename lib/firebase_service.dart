import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 현재 로그인된 사용자 ID 가져오기
  Future<String?> getUserId() async {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  // 초대장 초기화
  Future<String?> initializeInvitation({
    required String userId,
  }) async {
    try {
      // users/{userId}/invitations에 문서 추가
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      CollectionReference invitationsRef = userRef.collection('invitations');

      // 기본 데이터로 초대장 초기화
      Map<String, dynamic> initialData = {
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 초기화된 초대장 생성 후 Document ID 반환
      DocumentReference invitationRef = await invitationsRef.add(initialData);
      return invitationRef.id; // 생성된 초대장의 ID 반환
    } catch (e) {
      print('Invitation initialization failed: $e');
      return null;
    }
  }

  // 초대장 데이터 가져오기
  Future<Map<String, dynamic>> getInvitationData(String invitationId) async {
    try {
      String? userId = await getUserId();
      if (userId == null) return {}; // Return an empty map if the user ID is null

      DocumentSnapshot invitationDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('invitations')
          .doc(invitationId)
          .get();

      if (invitationDoc.exists) {
        // 데이터 가져오기
        Map<String, dynamic> data = invitationDoc.data() as Map<String, dynamic>;

        // Timestamp 필드 null 체크
        if (data['createdAt'] == null) {
          data['createdAt'] = null; // 기본값 설정 (null 또는 다른 기본값)
        } else {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate(); // Timestamp를 DateTime으로 변환
        }

        return data; // Return the retrieved data
      }
      return {}; // Return an empty map if the document does not exist
    } catch (e) {
      print('Failed to get invitation data: $e');
      return {}; // Return an empty map on error
    }
  }


// 초대장 업데이트
  Future<void> updateInvitation({
    required String invitationId,
    required String userId,
    String? templateId,
    String? groomName,
    String? groomPhone,
    String? groomFatherName,
    String? groomFatherPhone,
    String? groomMotherName,
    String? groomMotherPhone,
    String? brideName,
    String? bridePhone,
    String? brideFatherName,
    String? brideFatherPhone,
    String? brideMotherName,
    String? brideMotherPhone,
    DateTime? weddingDateTime,
    String? weddingLocation,
    String? locationX,
    String? locationY,
    String? locationId,              // 추가된 부분
    String? locationName,            // 추가된 부분
    String? locationUrl,             // 추가된 부분
    String? locationPhoneNumber,     // 추가된 부분
    String? kakaoRoadUrl,
    String? naverRoadUrl,
    String? additionalAddress,
    String? additionalInstructions,
    String? groomAccountNumber,
    String? brideAccountNumber,
  }) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentReference invitationRef =
      userRef.collection('invitations').doc(invitationId);

      Map<String, dynamic> invitationData = {};

      // 모든 필드 추가
      invitationData['userId'] = userId;
      invitationData['invitationId'] =invitationId;
      if (invitationData['userId'] != null && invitationData['invitationId'] != null) {
        // Construct the full URL
        String shareLink = 'https://invitationgen-7eb56.firebaseapp.com/invitation/${invitationData['userId']}/${invitationData['invitationId']}';

        // Encode the entire URL
        invitationData['shareLink'] = Uri.encodeFull(shareLink);
      } else {
        throw 'userId 또는 invitationId가 없습니다.';
      }
      if (templateId != null) invitationData['templateId'] = templateId;
      if (groomName != null) invitationData['groomName'] = groomName;
      if (groomPhone != null) invitationData['groomPhone'] = groomPhone;
      if (groomFatherName != null) invitationData['groomFatherName'] = groomFatherName;
      if (groomFatherPhone != null) invitationData['groomFatherPhone'] = groomFatherPhone;
      if (groomMotherName != null) invitationData['groomMotherName'] = groomMotherName;
      if (groomMotherPhone != null) invitationData['groomMotherPhone'] = groomMotherPhone;
      if (brideName != null) invitationData['brideName'] = brideName;
      if (bridePhone != null) invitationData['bridePhone'] = bridePhone;
      if (brideFatherName != null) invitationData['brideFatherName'] = brideFatherName;
      if (brideFatherPhone != null) invitationData['brideFatherPhone'] = brideFatherPhone;
      if (brideMotherName != null) invitationData['brideMotherName'] = brideMotherName;
      if (brideMotherPhone != null) invitationData['brideMotherPhone'] = brideMotherPhone;
      if (weddingDateTime != null) invitationData['weddingDateTime'] = weddingDateTime;
      if (weddingLocation != null) invitationData['weddingLocation'] = weddingLocation;
      if (locationX != null) invitationData['locationX'] = locationX;
      if (locationY != null) invitationData['locationY'] = locationY;
      if (locationId != null) invitationData['locationId'] = locationId;               // 추가된 부분
      if (locationName != null) invitationData['locationName'] = locationName;         // 추가된 부분
      if (locationUrl != null) invitationData['locationUrl'] = locationUrl;            // 추가된 부분
      if (locationPhoneNumber != null) invitationData['locationPhoneNumber'] = locationPhoneNumber;  // 추가된 부분
      if (kakaoRoadUrl != null) invitationData['kakaoRoadUrl'] = kakaoRoadUrl;
      if (naverRoadUrl != null) invitationData['naverRoadUrl'] = naverRoadUrl;
      if (additionalAddress != null) invitationData['additionalAddress'] = additionalAddress;
      if (additionalInstructions != null) invitationData['additionalInstructions'] = additionalInstructions;
      if (groomAccountNumber != null) invitationData['groomAccountNumber'] = groomAccountNumber;
      if (brideAccountNumber != null) invitationData['brideAccountNumber'] = brideAccountNumber;

      // 데이터가 있을 경우에만 업데이트
      if (invitationData.isNotEmpty) {
        await invitationRef.update(invitationData);
      }
    } catch (e) {
      print('Invitation update failed: $e');
    }
  }

  // 초대장 목록 가져오기
  Future<List<DocumentSnapshot>> getInvitations(String userId) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      QuerySnapshot querySnapshot = await userRef.collection('invitations').get();
      return querySnapshot.docs;
    } catch (e) {
      print('Failed to get invitations: $e');
      return [];
    }
  }

  // 초대장 삭제
  Future<void> deleteInvitation(String userId, String invitationId) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentReference invitationRef = userRef.collection('invitations').doc(invitationId);

      // 초대장 삭제
      await invitationRef.delete();
      // print('Invitation deleted successfully.');
    } catch (e) {
      // print('Failed to delete invitation: $e');
    }
  }
}
