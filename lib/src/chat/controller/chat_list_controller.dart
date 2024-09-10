import 'dart:async';

import 'package:bamtol_market_02/src/chat/model/chat_display_info.dart';
import 'package:bamtol_market_02/src/chat/model/chat_group_model.dart';
import 'package:bamtol_market_02/src/chat/repository/chat_repository.dart';
import 'package:bamtol_market_02/src/common/model/product.dart';
import 'package:bamtol_market_02/src/product/repository/product_repository.dart';
import 'package:bamtol_market_02/src/user/model/user_model.dart';
import 'package:bamtol_market_02/src/user/repository/user_repository.dart';
import 'package:get/get.dart';

class ChatListController extends GetxController {
  // 채팅 정보를 불러오기 위해
  final ChatRepository _chatRepository;

  // 채팅과 연결된 상품 정보를 가져오기 위해
  final ProductRepository _productRepository;

  // 채팅 상대가 누구인지 조회하는데 필요
  final UserRepository _userRepository;

  // 채팅 메시지가 내가 보낸 것인지 상대가 보낸 것인지 구별하기 위해
  final String myUid;

  ChatListController(
    this._chatRepository,
    this._productRepository,
    this._userRepository,
    this.myUid,
  );

  // RxList : 여러 명의 구매자(여러 개의 채팅방)가 있을 수 있기 때문에 스트림이 여러개일 수 있음
  // Stream<List<ChatDisplayInfo>> : ChatDisplayInfo가 각 채팅방의 개별 채팅 메시지를 담는 데이터
  final RxList<Stream<List<ChatDislayInfo>>> chatStreams =
      <Stream<List<ChatDislayInfo>>>[].obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   var productId = Get.arguments['productId'] as String?;
  //   if (productId != null) {
  //     _loadAllProductChatList(productId);
  //   }
  // }

  // ChatListPage : initState에서 페이지 생성되면서 호출
  void load({String? productId}) {
    chatStreams.clear();

    if (productId == null) {
      _loadAllMyChatList();
    } else {
      _loadAllProductChatList(productId);
    }
  }

  void _loadAllMyChatList() async {
    var results = await _chatRepository.loadAllChatGroupModelWithMyUid(myUid);
    if (results != null) {
      chatStreams.clear();
      for (var result in results) {
        loadChatInfoStream(result);
      }
    }
  }

  void _loadAllProductChatList(String productId) async {
    var result = await _chatRepository.loadChatInfo(productId);
    if (result != null) {
      loadChatInfoStream(result);
    }
  }

  void loadChatInfoStream(ChatGroupModel info) async {
    // 모든 채팅 상대를 하나씩 순서대로 처리(loop) gkaustj 채팅방별로 스트림을 만듬
    // 이 때 StreamTransformer를 사용하여 ChatDisplayInfo 객체로 변환 후 스트림에 담음
    info.chatters?.forEach(
      (chatDoc) {
        var chatStreamData = _chatRepository
            .loadChatInfoOneStream(info.productId ?? '', chatDoc)
            .transform<List<ChatDislayInfo>>(
          StreamTransformer.fromHandlers(
            handleData: (docSnap, sink) {
              if (docSnap.isNotEmpty) {
                var chatModels = docSnap
                    .map<ChatDislayInfo>((item) => ChatDislayInfo(
                          ownerUid: info.owner,
                          customerUid: chatDoc,
                          isOwner: info.owner == myUid,
                          chatModel: item,
                          productId: info.productId,
                        ))
                    .toList();
                sink.add(chatModels);
              }
            },
          ),
        );
        chatStreams.add(chatStreamData);
      },
    );
  }

  // 회원정보 조회
  Future<UserModel?> loadUserInfo(String uid) async {
    return await _userRepository.findUserOne(uid);
  }

  // 상품정보 조회
  Future<Product?> loadProductInfo(String productId) async {
    return await _productRepository.getProduct(productId);
  }
}
