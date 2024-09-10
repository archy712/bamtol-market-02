import 'package:bamtol_market_02/src/common/components/loading.dart';
import 'package:bamtol_market_02/src/common/controller/common_layout_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// CommonLayoutController에 쉽게 접근하기 위해 GetView 사용
class CommonLayout extends GetView<CommonLayoutController> {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavBar;
  final Widget? floatingActionButton;
  final bool useSafeArea;

  const CommonLayout({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.useSafeArea = false,
    this.bottomNavBar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // 변경되는 상태를 구독하기 위해 Obx 사용
      child: Obx(
        () => Stack(
          fit: StackFit.expand,
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: appBar,
              backgroundColor: const Color(0xFF212133),
              body: useSafeArea ? SafeArea(child: body) : body,
              bottomNavigationBar: bottomNavBar ?? const SizedBox(height: 1),
              floatingActionButton: floatingActionButton,
            ),
            // isLoading 상태 값에 따라 로딩 위젯을 보여줄 지, 빈 Container()를 보여줄 지 처리
            controller.isLoading.value ? const Loading() : Container(),
          ],
        ),
      ),
    );
  }
}
