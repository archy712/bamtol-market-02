import 'package:bamtol_market_02/src/chat/controller/chat_list_controller.dart';
import 'package:bamtol_market_02/src/chat/model/chat_display_info.dart';
import 'package:bamtol_market_02/src/chat/page/widgets/chat_single_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScrollWidget extends GetView<ChatListController> {
  const ChatScrollWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Obx(
        () => Column(
          children: List.generate(
            controller.chatStreams.length,
            (index) => StreamBuilder<List<ChatDislayInfo>>(
              stream: controller.chatStreams[index],
              builder: (context, snapshot) {
                var chats = snapshot;
                if (chats.hasData) {
                  return ChatSingleView(
                    userUid: chats.data?.last.customerUid ?? '',
                    message: chats.data?.last.chatModel!.text ?? '',
                    productId: chats.data?.last.productId ?? '',
                    time:
                        chats.data?.last.chatModel!.createdAt ?? DateTime.now(),
                    onTap: () {
                      Get.toNamed(
                        '/chat/${chats.data?.last.productId}/${chats.data?.last.ownerUid}/${chats.data?.last.customerUid}',
                      );
                    },
                  );
                }
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}
