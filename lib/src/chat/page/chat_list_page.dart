import 'package:bamtol_market_02/src/chat/controller/chat_list_controller.dart';
import 'package:bamtol_market_02/src/chat/page/widgets/chat_scroll_widget.dart';
import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:bamtol_market_02/src/common/layout/common_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ChatListPage extends StatefulWidget {
  final bool useBackBtn;

  const ChatListPage({
    super.key,
    this.useBackBtn = false,
  });

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    String? productId;
    if (Get.arguments != null) {
      productId = Get.arguments['productId'] as String?;
    }
    Get.find<ChatListController>().load(productId: productId);
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      appBar: AppBar(
        title: const AppFont(
          '채팅',
          size: 20,
        ),
        leading: widget.useBackBtn
            ? GestureDetector(
                onTap: Get.back,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: SvgPicture.asset('assets/svg/icons/back.svg'),
                ),
              )
            : Container(),
      ),
      body: const ChatScrollWidget(),
    );
  }
}
