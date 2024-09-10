import 'package:bamtol_market_02/src/chat/controller/chat_controller.dart';
import 'package:bamtol_market_02/src/chat/page/widgets/chat_body.dart';
import 'package:bamtol_market_02/src/chat/page/widgets/header_item_info.dart';
import 'package:bamtol_market_02/src/chat/page/widgets/text_field_widget.dart';
import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:bamtol_market_02/src/common/components/user_temperature_widget.dart';
import 'package:bamtol_market_02/src/common/layout/common_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppFont(
                controller.opponentUser.value.nickName ?? '',
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(width: 6),
              UserTemperatureWidget(
                temperature: controller.opponentUser.value.temperature ?? 0,
                isSimpled: true,
              ),
            ],
          ),
        ),
        actions: const [
          SizedBox(width: 50),
        ],
      ),
      body: Column(
        children: [
          const HeaderItemInfo(),
          //const Spacer(),
          const Expanded(
            child: ChatBody(),
          ),
          const TextFieldWidget(),
          KeyboardVisibilityBuilder(builder: (context, visible) {
            return SizedBox(
              height: visible
                  ? MediaQuery.of(context).viewInsets.bottom
                  : Get.mediaQuery.padding.bottom,
            );
          }),
        ],
      ),
    );
  }
}
