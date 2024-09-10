import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MessageBox extends StatelessWidget {
  final bool isMine;
  final String message;
  final DateTime date;

  const MessageBox({
    super.key,
    this.isMine = false,
    required this.date,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMine)
            SizedBox(
              width: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppFont(
                    DateFormat('HH:mm').format(date),
                    color: const Color(0xff6D7179),
                    size: 12,
                  ),
                ],
              ),
            ),
          const SizedBox(width: 10),
          Container(
            //constraints: BoxConstraints(minWidth: 100, maxWidth: Get.width * 0.7),
            constraints:
                BoxConstraints(minWidth: 100, maxWidth: Get.width * 0.6),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: isMine ? const Color(0xffED7738) : const Color(0xff2B2E32),
            ),
            child: AppFont(
              message,
              maxLine: null,
            ),
          ),
          const SizedBox(width: 10),
          if (!isMine)
            SizedBox(
              width: 50,
              child: Row(
                children: [
                  AppFont(
                    DateFormat('HH:mm').format(date),
                    color: const Color(0xff6D7179),
                    size: 12,
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
