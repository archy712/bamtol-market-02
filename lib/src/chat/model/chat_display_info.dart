import 'package:bamtol_market_02/src/chat/model/chat_model.dart';

class ChatDislayInfo {
  final String? ownerUid;
  final String? customerUid;
  final bool? isOwner;
  final ChatModel? chatModel;
  final String? productId;

  const ChatDislayInfo({
    this.ownerUid,
    this.customerUid,
    this.isOwner,
    this.chatModel,
    this.productId,
  });
}
