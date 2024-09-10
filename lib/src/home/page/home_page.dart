import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:bamtol_market_02/src/common/components/price_view.dart';
import 'package:bamtol_market_02/src/common/controller/authentication_controller.dart';
import 'package:bamtol_market_02/src/common/enum/market_enum.dart';
import 'package:bamtol_market_02/src/common/layout/common_layout.dart';
import 'package:bamtol_market_02/src/common/model/product.dart';
import 'package:bamtol_market_02/src/home/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      // 기본적으로 leading 옵션 위젯은 정사각형으로 고정
      // 이를 넓히기 위해 leadingWidth 옵션을 사용
      appBar: AppBar(
        leadingWidth: Get.width * 0.6,
        leading: Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Row(
            children: [
              const AppFont(
                '신도림',
                fontWeight: FontWeight.bold,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              SvgPicture.asset('assets/svg/icons/bottom_arrow.svg'),
            ],
          ),
        ),
        actions: [
          SvgPicture.asset('assets/svg/icons/search.svg'),
          const SizedBox(width: 15),
          SvgPicture.asset('assets/svg/icons/list.svg'),
          const SizedBox(width: 15),
          SvgPicture.asset('assets/svg/icons/bell.svg'),
          const SizedBox(width: 25),
          // 아래 로그아웃 부분 추가
          GestureDetector(
            onTap: () {
              Get.find<AuthenticationController>().logout();
            },
            child: const SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: const _ProductList(),
      floatingActionButton: GestureDetector(
        onTap: () async {
          // Get.toNamed 사용하여 라우팅.
          var isNeedRefresh = await Get.toNamed('/product/write');
          if (isNeedRefresh is bool && isNeedRefresh) {
            Get.find<HomeController>().refresh();
          }
        },
        behavior: HitTestBehavior.translucent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: const Color(0xFFED7738),
              ),
              child: Row(
                children: [
                  SvgPicture.asset('assets/svg/icons/plus.svg'),
                  const SizedBox(width: 6),
                  const AppFont(
                    '글쓰기',
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 상품 리스트를 별도의 위젯 클래스로 분리
// 장점 : Stateful, Stateless 선택 가능
class _ProductList extends GetView<HomeController> {
  const _ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.separated(
        controller: controller.scrollController,
        padding: const EdgeInsets.only(left: 25.0, top: 20, right: 25),
        itemBuilder: (context, index) {
          if (index == controller.productList.length) {
            return controller.searchOption.lastItem != null
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 1),
                  )
                : Container();
          }
          return _productOne(controller.productList[index]);
        },
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(
            color: Color(0xFF3C3C3E),
          ),
        ),
        itemCount: controller.productList.length + 1,
      ),
    );
  }

  // 상품 카드 위젯
  Widget _productOne(Product product) {
    return GestureDetector(
      onTap: () async {
        //Get.toNamed('/product/detail/${product.docId}');

        // 상세 페이지에서 홈으로 돌아올 때 삭제가 이루어지면 true 값 반환
        // HomeControllerdp 새로고침 함수 호출
        var isNeedReload =
            await Get.toNamed('/product/detail/${product.docId}');
        if (isNeedReload != null && isNeedReload) {
          controller.refresh();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지에 둥근 모서리를 하기 위해
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.network(
                product.imageUrls?.first ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                AppFont(
                  product.title ?? '',
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(height: 5),
                _subInfo(product),
                const SizedBox(height: 5),
                PriceView(
                  price: product.productPrice ?? 0,
                  status: product.status ?? ProductStatusType.sale,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 글쓴이, 날짜를 보여주는 위젯
  Widget _subInfo(Product product) {
    return Row(
      children: [
        AppFont(
          product.owner?.nickName ?? '',
          color: const Color(0xFF878B93),
          size: 12,
        ),
        const AppFont(
          ' . ',
          color: Color(0xFF878B93),
          size: 12,
        ),
        AppFont(
          DateFormat('yyyy.MM.dd').format(product.createdAt!),
          color: const Color(0xFF878B93),
          size: 12,
        ),
      ],
    );
  }
}
