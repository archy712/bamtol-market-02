import 'dart:developer';

import 'package:bamtol_market_02/src/user/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserRepository extends GetxService {
  FirebaseFirestore db;

  UserRepository(this.db);

  // uid 통해 사용자 조회, UserModel로 바인딩 : authentication 상태
  // 없다면 회원가입 페이지로 이동할 수 있도록 null 반환 : unAuthenticated 상태
  Future<UserModel?> findUserOne(String uid) async {
    try {
      var doc = await db.collection('users').where('uid', isEqualTo: uid).get();
      if (doc.docs.isEmpty) {
        //log('Firestore : findUserOne($uid) : 데이터 미존재 : null');
        return null;
      } else {
        //log('Firestore : findUserOne($uid) : 데이터 존재');
        return UserModel.fromJson(doc.docs.first.data());
      }
    } catch (e) {
      log('Firestore : findUserOne($uid) : 오류 (catch) ${e.toString()}');
      return null;
    }
  }

  // 닉네임 중복 체크
  Future<bool> checkDuplicationNickName(String nickName) async {
    try {
      var doc = await db
          .collection('users')
          .where('nickName', isEqualTo: nickName)
          .get();
      //log('닉네임 중복 체크 : ${doc.docs.isEmpty.toString()}');
      return doc.docs.isEmpty;
    } catch (e) {
      log('닉네임 중복 체크 오류 (catch)');
      return false;
    }
  }

  Future<String?> signup(UserModel user) async {
    try {
      var result = await db.collection('users').add(user.toJson());
      return result.id;
    } catch (e) {
      return null;
    }
  }
}
