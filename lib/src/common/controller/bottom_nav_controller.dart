import 'package:flutter/material.dart';
import 'package:get/get.dart';

// TabController 초기화할 때 TickerProvider 필요
// GetTickerProviderStateMixin 사용
class BottomNavController extends GetxController
    with GetTickerProviderStateMixin {
  late TabController tabController;

  // 메뉴 인덱스 변수 상태 관리
  RxInt menuIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // TabController 생성 (length, vsync 반드시 명시)
    tabController = TabController(length: 5, vsync: this);
  }

  // 메뉴 인덱스 값 변경
  void changeBottomNav(int index) {
    menuIndex(index);
    tabController.animateTo(index);
  }
}
