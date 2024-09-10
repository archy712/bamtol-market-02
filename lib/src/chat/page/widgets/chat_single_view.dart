import 'package:bamtol_market_02/src/chat/controller/chat_list_controller.dart';
import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatSingleView extends GetView<ChatListController> {
  final String userUid;
  final String message;
  final DateTime time;
  final String productId;
  final Function() onTap;

  const ChatSingleView({
    super.key,
    required this.userUid,
    required this.message,
    required this.time,
    required this.productId,
    required this.onTap,
  });

  String timeagoValue(DateTime timeAt) {
    var value = timeago.format(
      DateTime.now().subtract(DateTime.now().difference(timeAt)),
      locale: 'ko',
    );
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  Image.asset('assets/images/default_profile.png').image,
              backgroundColor: Colors.black,
              radius: 23,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FutureBuilder(
                    future: controller.loadUserInfo(userUid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Row(
                          children: [
                            AppFont(
                              snapshot.data?.nickName ?? '',
                              size: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(width: 7),
                            AppFont(
                              timeagoValue(time),
                              size: 12,
                              color: const Color(0xffABAEB6),
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  const SizedBox(height: 5),
                  AppFont(
                    message,
                    size: 16,
                    maxLine: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            FutureBuilder(
              future: controller.loadProductInfo(productId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.network(
                      snapshot.data?.imageUrls?.first ?? '',
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
