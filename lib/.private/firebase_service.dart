import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createInvitation({
  required String groomName,
  required String groomPhone,
  required String brideName,
  required String bridePhone,
}) async {
  // Firestore의 'invitations' 컬렉션에 접근
  CollectionReference invitations = FirebaseFirestore.instance.collection('invitations');

  // 데이터 추가
  await invitations.add({
    'groomName': groomName,
    'groomPhone': groomPhone,
    'brideName': brideName,
    'bridePhone': bridePhone,
    // 추가 필드가 필요한 경우 여기에 추가
  });
}
