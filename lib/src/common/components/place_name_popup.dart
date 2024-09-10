import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:bamtol_market_02/src/common/components/btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaceNamePopup extends StatefulWidget {
  const PlaceNamePopup({super.key});

  @override
  State<PlaceNamePopup> createState() => _PlaceNamePopupState();
}

class _PlaceNamePopupState extends State<PlaceNamePopup> {
  bool possible = false;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Align(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 뒷 배경을 터치했을 때 화면을 닫아주기 위함
            Positioned(
              child: GestureDetector(
                onTap: Get.back,
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: const Color(0xFF212133),
                  height: 230,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppFont(
                        '선택한 곳의 장소명을 입력해 주세요',
                        fontWeight: FontWeight.bold,
                        size: 16,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        autofocus: true,
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: '예) 강남역 1번 출구, 당근빌딩 앞',
                          hintStyle:
                              TextStyle(color: Color.fromARGB(255, 95, 95, 95)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                          ),
                        ),
                        onChanged: (value) {
                          // 입력필드에 따라 버튼을 활성화/비활성화 하는 기능을 처리하기 위해
                          // 또한 value 값에 따라 저장 가능 여부를 나타내는 상태를 possible 변수에 저장
                          setState(() {
                            possible = value != '';
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      Btn(
                        // 옵션값에 따라 onTap 이벤트를 호출 여부 결정
                        // 동시에 사용자에게 버튼이 비활성화된 것처럼 보이도록 구현
                        disabled: !possible,
                        onTap: () {
                          // 입력이 완료되어 '저장' 버튼을 누르면, controller.text에 저장된 값 반환
                          Get.back(result: controller.text);
                        },
                        child: const AppFont(
                          '거래 장소 등록',
                          align: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
