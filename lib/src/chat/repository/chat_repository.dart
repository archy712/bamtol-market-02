import 'dart:async';

import 'package:bamtol_market_02/src/chat/model/chat_group_model.dart';
import 'package:bamtol_market_02/src/chat/model/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ChatRepository extends GetxService {
  late FirebaseFirestore db;

  ChatRepository(this.db);

  // 채팅방 정보 불러오기
  Future<ChatGroupModel?> loadChatInfo(String productId) async {
    var doc = await db
        .collection('chats')
        .where('productId', isEqualTo: productId)
        .get();

    if (doc.docs.isNotEmpty) {
      return ChatGroupModel.fromJson(doc.docs.first.data());
    }

    return null;
  }

  // 메시지 보내기 (데이터베이스 저장)
  Future<void> submitMessage(String hostUid, ChatGroupModel chatGroupModel,
      ChatModel chatModel) async {
    // 사용자가 채팅한 이력이 있는 모든 채팅 메시지 조회
    var doc = await db
        .collection('chats')
        .where('chatters', arrayContains: chatModel.uid)
        .get();

    var results = doc.docs.where((data) {
      return data.id == chatGroupModel.productId;
    });

    // productId로 채팅한 데이터 있으면 업데이트, 없으면 새로 등록
    if (results.isEmpty) {
      await db
          .collection('chats')
          .doc(chatGroupModel.productId)
          .set(chatGroupModel.toMap());
    } else {
      var chatters = results.first.data()['chatters'] as List<dynamic>;
      chatters.add(chatModel.uid!);
      await db.collection('chats').doc(chatGroupModel.productId).update({
        'chatters': chatters.toSet().toList(),
      });
    }

    // chat 메시지 저장, 컬렉션을 2번 사용
    db
        .collection('chats')
        .doc(chatGroupModel.productId)
        .collection(hostUid)
        .add(chatModel.toMap());
  }

  // 1개의 채팅방 정보
  Stream<List<ChatModel>> loadChatInfoOneStream(
      String productDocId, String targetUid) {
    return db
        .collection('chats')
        .doc(productDocId)
        .collection(targetUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .transform<List<ChatModel>>(
            StreamTransformer.fromHandlers(handleData: (docSnap, sink) {
      if (docSnap.docs.isNotEmpty) {
        var chatModels = docSnap.docs
            .map<ChatModel>((item) => ChatModel.fromJson(item.data()))
            .toList();
        sink.add(chatModels);
      }
    }));
  }

  // 상품 1개에 대한 모든 채팅방 불러오기
  Future<ChatGroupModel?> loadAllChats(String docId) async {
    var doc = await db.collection('chats').doc(docId).get();
    if (doc.exists) {
      return ChatGroupModel.fromJson(doc.data()!);
    }
    return null;
  }

  // 내가 포함된 모든 채팅방 불러오기
  Future<List<ChatGroupModel>?> loadAllChatGroupModelWithMyUid(
      String uid) async {
    var doc = await db
        .collection('chats')
        .where('chatters', arrayContains: uid)
        .get();

    if (doc.docs.isNotEmpty) {
      return doc.docs
          .map<ChatGroupModel>((e) => ChatGroupModel.fromJson(e.data()))
          .toList();
    }
    return null;
  }
}
