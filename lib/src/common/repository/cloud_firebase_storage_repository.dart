import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class CloudFirebaseRepository extends GetxService {
  final Reference storageRef;

  // FirebaseStorage 라이브러리를 사용하여 파일을 업로드 가능
  CloudFirebaseRepository(FirebaseStorage storage) : storageRef = storage.ref();

  Future<String> uploadFile(String mainPath, File file) async {
    // uuid 라이브러리 사용
    var uuid = const Uuid();
    // 파일을 업로드 하기 위해 경로를 지정, putFile 함수를 통해 업로드 수행
    final uploadTask =
        storageRef.child('products/$mainPath/${uuid.v4()}.jpg').putFile(file);
    final TaskSnapshot taskSnapshot = await uploadTask;
    // 다운로드 URL 받아옴
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
