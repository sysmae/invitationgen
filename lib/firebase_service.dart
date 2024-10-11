import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createInvitation({
    required String userId, // userId를 추가
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
  }) async {
    try {
      // users/{userId}/invitations에 문서 추가
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      CollectionReference invitationsRef = userRef.collection('invitations');

      await invitationsRef.add({
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
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Invitation creation failed: $e');
    }
  }
}
