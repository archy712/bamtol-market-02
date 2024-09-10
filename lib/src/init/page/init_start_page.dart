import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:bamtol_market_02/src/common/components/btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InitStartPage extends StatelessWidget {
  // 현재 페이지를 호출하는 페이지에서 함수를 넣을 수 있도록
  final Function() onStart;

  const InitStartPage({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 이미지
            SizedBox(
              width: 99,
              height: 116,
              child: Image.asset(
                'assets/images/logo_simbol.png',
              ),
            ),
            const SizedBox(height: 40),
            const AppFont(
              '당신 근처의 밤톨마켓',
              fontWeight: FontWeight.bold,
              size: 20,
            ),
            const SizedBox(height: 15),
            AppFont(
              '중고 거래부터 동네 정보까지,\n지금 내 동네를 선택하고 시작해 보세요!',
              align: TextAlign.center,
              size: 18,
              color: Colors.white.withOpacity(0.6),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 25.0,
          right: 25.0,
          // iOS에서 하단에서 위로 쓸어올리면 나타나는 제어센터 영역 때문에
          bottom: 25 + Get.mediaQuery.padding.bottom,
        ),
        child: Btn(
          onTap: onStart,
          child: const AppFont(
            '시작하기',
            align: TextAlign.center,
            size: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
