import 'package:bamtol_market_02/src/chat/model/chat_group_model.dart';
import 'package:bamtol_market_02/src/chat/model/chat_model.dart';
import 'package:bamtol_market_02/src/chat/repository/chat_repository.dart';
import 'package:bamtol_market_02/src/common/controller/authentication_controller.dart';
import 'package:bamtol_market_02/src/common/model/product.dart';
import 'package:bamtol_market_02/src/product/repository/product_repository.dart';
import 'package:bamtol_market_02/src/user/model/user_model.dart';
import 'package:bamtol_market_02/src/user/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;
  final ProductRepository _productRepository;

  ChatController(
    this._chatRepository,
    this._userRepository,
    this._productRepository,
  );

  final TextEditingController textController = TextEditingController();

  late String ownerUid;
  late String customerUid;
  late String productId;
  late String myUid;
  late Stream<List<ChatModel>> chatStream;

  // Controller에서 관리하는 상태 변수들
  Rx<Product> product = const Product.empty().obs;
  Rx<UserModel> opponentUser = const UserModel().obs;
  Rx<ChatGroupModel> chatGroupModel = const ChatGroupModel().obs;

  @override
  void onInit() {
    super.onInit();
    ownerUid = Get.parameters['ownerUid'] as String;
    customerUid = Get.parameters['customerUid'] as String;
    productId = Get.parameters['docId'] as String;
    myUid = Get.find<AuthenticationController>().userModel.value.uid ?? '';

    _loadProductInfo();
    _loadOpponentUser(ownerUid == myUid ? customerUid : ownerUid);
    _loadChatInfo();
    _loadChatInfoStream(productId, customerUid);
  }

  Future<void> _loadProductInfo() async {
    var result = await _productRepository.getProduct(productId);
    if (result != null) {
      product(result);
    }
  }

  _loadOpponentUser(String opponentUid) async {
    var userMode = await _userRepository.findUserOne(opponentUid);
    if (userMode != null) {
      opponentUser(userMode);
    }
  }

  submitMessage(String message) async {
    textController.text = '';

    chatGroupModel(
      chatGroupModel.value.copyWith(
        updatedAt: DateTime.now(),
      ),
    );

    var newMessage = ChatModel(
      uid: myUid,
      text: message,
      createdAt: DateTime.now(),
    );

    await _chatRepository.submitMessage(
      customerUid,
      chatGroupModel.value,
      newMessage,
    );
  }

  _loadChatInfo() async {
    var result = await _chatRepository.loadChatInfo(productId);
    if (result != null) {
      chatGroupModel(
        result.copyWith(
          chatters: [...result.chatters ?? [], myUid],
        ),
      );
    } else {
      chatGroupModel(
        ChatGroupModel(
          chatters: [ownerUid, customerUid],
          owner: ownerUid,
          productId: productId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  _loadChatInfoStream(String productId, String customUid) async {
    chatStream = _chatRepository.loadChatInfoOneStream(productId, customUid);
  }
}
