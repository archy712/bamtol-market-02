import 'package:bamtol_market_02/src/chat/controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class TextFieldWidget extends GetView<ChatController> {
  const TextFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xff696D75)),
                hintText: '메시지 보내기',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                fillColor: Color(0xff2B2E32),
              ),
              maxLines: null,
              onSubmitted: controller.submitMessage,
            ),
          ),
          GestureDetector(
            onTap: () async {
              controller.submitMessage(controller.textController.text);
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              padding: const EdgeInsets.all(7),
              child: SvgPicture.asset('assets/svg/icons/icon_sender.svg'),
            ),
          ),
        ],
      ),
    );
  }
}
