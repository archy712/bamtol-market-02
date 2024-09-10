import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ScrollAppbarWidget extends StatefulWidget {
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavBar;
  final Function() onBack;

  const ScrollAppbarWidget({
    super.key,
    required this.body,
    this.bottomNavBar,
    this.actions,
    required this.onBack,
  });

  @override
  State<ScrollAppbarWidget> createState() => _ScrollAppbarWidgetState();
}

class _ScrollAppbarWidgetState extends State<ScrollAppbarWidget> {
  // 스크롤에 따라 투명도를 조절하기 위해 ScrollController 생성
  ScrollController controller = ScrollController();

  // 투명도
  int alpha = 0;

  @override
  void initState() {
    super.initState();
    // 생성된 ScrollController를 구독하여, 스크롤에 따라 0~255 범위의 alpha값 저장
    // clamp 설정하여 스크롤 위치가 255 넘어도 alpha 값은 255로 유지
    controller.addListener(() {
      setState(() {
        alpha = (controller.offset).clamp(0, 255).toInt();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: GestureDetector(
          behavior: HitTestBehavior.translucent,
          //onTap: Get.back,
          onTap: widget.onBack,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset('assets/svg/icons/back.svg'),
          ),
        ),
        // 변경된 alpha 값에 따라 AppBar의 backgroundColor에 alpha 값을 지정
        backgroundColor: const Color(0xff212123).withAlpha(alpha),
        elevation: 0,
        actions: widget.actions,
      ),
      backgroundColor: const Color(0xff212123),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: controller,
            child: widget.body,
          ),
          // 스크롤 하기 전에는 AppBar가 투명하기 때문에 상단에 그라데이션을 추가하여
          // 아이콘을 잘 보이도록 처리
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xff212123),
                  const Color(0xff212123).withOpacity(0),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.bottomNavBar,
    );
  }
}
