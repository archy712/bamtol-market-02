import 'package:bamtol_market_02/src/chat/controller/chat_controller.dart';
import 'package:bamtol_market_02/src/chat/model/chat_model.dart';
import 'package:bamtol_market_02/src/chat/page/widgets/message_box.dart';
import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatBody extends GetView<ChatController> {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // 최신 내용이 채팅 창 아래에 쌓이도록 하기 위해
      reverse: true,
      child: StreamBuilder<List<ChatModel>>(
        stream: controller.chatStream,
        builder: (context, snapshot) {
          var useProfileImage = false;
          String lastDateYYYYMMDD = '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(
              // 스트림 데이터인 List<ChatModel> 크기만큼 위젯 생성
              snapshot.data?.length ?? 0,
              (index) {
                var chat = snapshot.data![index];
                var isMine = chat.uid == controller.myUid;

                var messageGroupWidget = <Widget>[];
                var currentDateYYYYMMDD =
                    DateFormat('yyyyMMdd').format(chat.createdAt!);

                if (!useProfileImage && !isMine) {
                  useProfileImage = true;
                  messageGroupWidget.add(
                    CircleAvatar(
                      backgroundImage:
                          Image.asset('assets/images/default_profile.png')
                              .image,
                      backgroundColor: Colors.black,
                      radius: 18,
                    ),
                  );
                } else if (!isMine) {
                  messageGroupWidget.add(
                    const SizedBox(width: 36),
                  );
                }
                messageGroupWidget.add(
                  MessageBox(
                    date: chat.createdAt ?? DateTime.now(),
                    isMine: isMine,
                    message: chat.text ?? '',
                  ),
                );
                useProfileImage = !isMine;

                return Column(
                  children: [
                    Builder(
                      builder: (context) {
                        if (lastDateYYYYMMDD == '' ||
                            lastDateYYYYMMDD != currentDateYYYYMMDD) {
                          lastDateYYYYMMDD = currentDateYYYYMMDD;
                          return _ChatDateView(dateTime: chat.createdAt!);
                        }
                        return Container();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isMine
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: messageGroupWidget,
                      ),
                    )
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ChatDateView extends StatelessWidget {
  final DateTime dateTime;

  const _ChatDateView({
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0, bottom: 15),
      child: Center(
        child: AppFont(
          DateFormat('yyyy년 MM월 dd일').format(dateTime),
          size: 13,
          color: const Color(0xff6D7179),
        ),
      ),
    );
  }
}
