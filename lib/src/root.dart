import 'package:bamtol_market_02/src/chat/page/chat_list_page.dart';
import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:bamtol_market_02/src/common/controller/authentication_controller.dart';
import 'package:bamtol_market_02/src/common/controller/bottom_nav_controller.dart';
import 'package:bamtol_market_02/src/home/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

// controller에 접근할 수 있도록 GetView 상속 받음
// 제네릭으로 BottomNavController를 명시
// > controller가 BottomNavController 클래스임을 명확하게 알 수 있음
class Root extends GetView<BottomNavController> {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Container(
      //   color: Colors.red,
      // ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.tabController,
        children: [
          const HomePage(),
          const Center(child: AppFont('동네 생활')),
          const Center(child: AppFont('내 근처')),
          // Center(child: AppFont('채팅')),
          // Center(child: AppFont('나의 밤톨')),
          const ChatListPage(),
          Center(
            child: GestureDetector(
              onTap: () {
                Get.find<AuthenticationController>().logout();
              },
              child: const AppFont('나의 밤톨'),
            ),
          ),
        ],
      ),
      // Obx 위젯을 사용하여 상태 값이 변경될 때마다 화면이 자동으로 업데이트
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          // BottomNavController에서 상태를 관리하는 menuIndex 값을 currentIndex에 적용
          currentIndex: controller.menuIndex.value,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF212123),
          selectedItemColor: const Color(0xFFFFFFFF),
          unselectedItemColor: const Color(0xFFFFFFFF),
          selectedFontSize: 11.0,
          unselectedFontSize: 11.0,
          // 사용자가 메뉴를 선택하면 BottomNavController의 changeBottomNav 함수 호출
          onTap: controller.changeBottomNav,
          items: [
            BottomNavigationBarItem(
              label: '홈',
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset('assets/svg/icons/home-off.svg'),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset('assets/svg/icons/home-on.svg'),
              ),
            ),
            BottomNavigationBarItem(
              label: '동네 생활',
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    SvgPicture.asset('assets/svg/icons/arround-life-off.svg'),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset('assets/svg/icons/arround-life-on.svg'),
              ),
            ),
            BottomNavigationBarItem(
              label: '내 근처',
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset('assets/svg/icons/near-off.svg'),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset('assets/svg/icons/near-on.svg'),
              ),
            ),
            BottomNavigationBarItem(
              label: '채팅',
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset('assets/svg/icons/chat-off.svg'),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset('assets/svg/icons/chat-on.svg'),
              ),
            ),
            BottomNavigationBarItem(
              label: '나의 밤톨',
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset('assets/svg/icons/my-off.svg'),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset('assets/svg/icons/my-on.svg'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
