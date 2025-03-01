import 'dart:developer';

import 'package:bamtol_market_02/src/chat/model/chat_group_model.dart';
import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:bamtol_market_02/src/common/components/btn.dart';
import 'package:bamtol_market_02/src/common/components/price_view.dart';
import 'package:bamtol_market_02/src/common/components/scroll_appbar.dart';
import 'package:bamtol_market_02/src/common/components/trade_location_map.dart';
import 'package:bamtol_market_02/src/common/components/user_temperature_widget.dart';
import 'package:bamtol_market_02/src/common/controller/authentication_controller.dart';
import 'package:bamtol_market_02/src/common/enum/market_enum.dart';
import 'package:bamtol_market_02/src/common/model/product.dart';
import 'package:bamtol_market_02/src/common/utils/data_utils.dart';
import 'package:bamtol_market_02/src/product/detail/controller/product_detail_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  void _showActionSheet(BuildContext context) {
    var actions = controller.isMine
        ? [
            CupertinoActionSheetAction(
              onPressed: () async {
                Get.back();
                var isNeedRefresh = await Get.toNamed(
                  '/product/write',
                  parameters: {
                    'product_doc_id': controller.product.value.docId ?? '',
                  },
                );
                if (isNeedRefresh != null &&
                    isNeedRefresh is bool &&
                    isNeedRefresh) {
                  controller.refresh();
                }
              },
              child: const Text('게시물 수정'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () async {
                // ActionSheet가 활성화된 상태에서 삭제 버튼을 누르면 닫혀야 함
                Get.back();
                // 민감한 부분은 한번 더 확인을 받기 위해
                var isDeleted = await showDialog<bool?>(
                  context: Get.context!,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      content: const AppFont(
                        '정말 삭제하시겠습니까?',
                        color: Colors.black,
                        size: 16,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            // 정상적으로 이루어지면 true (bool)값 반환.
                            // 이 값을 Get.back을 통해 전달하여 삭제 확인창을 닫고,
                            // 상세 페이지에서 홈화면으로 돌아감
                            var result = await controller.deleteProduct();
                            Get.back(result: result);
                          },
                          child: const AppFont(
                            '삭제',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const AppFont(
                            '취소',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    );
                  },
                );
                // 사용자가 삭제 버튼을 눌럿다면 처리가 완료된 후 true 반환
                // 이 경우 isDeleted 값이 true이면 Get.back 호출하여 상세 페이지에서 뒤로 감
                if (isDeleted != null && isDeleted) {
                  Get.back(result: isDeleted);
                }
              },
              child: const Text('삭제'),
            ),
          ]
        : [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: const Text('게시물 신고'),
            ),
          ];
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: actions,
        cancelButton: CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
          },
          child: const Text('취소'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollAppbarWidget(
      onBack: () {
        Get.back(result: controller.isEdited);
      },
      actions: [
        GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.translucent,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: SvgPicture.asset('assets/svg/icons/share.svg'),
          ),
        ),
        GestureDetector(
          onTap: () {
            _showActionSheet(context);
          },
          behavior: HitTestBehavior.translucent,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: SvgPicture.asset('assets/svg/icons/more_vertical.svg'),
          ),
        ),
        const SizedBox(width: 10),
      ],
      body: Obx(
        () => Column(
          children: [
            SizedBox(
              width: Get.width,
              height: Get.width,
              child: _ProductThumbnail(
                product: controller.product.value,
              ),
            ),
            _ProfileSection(product: controller.product.value),
            _ProductDetail(product: controller.product.value),
            _HopeTradeLocation(product: controller.product.value),
            _UserProducts(
              product: controller.product.value,
              ownerOtherProducts: controller.ownerOtherProducts.value,
            ),
          ],
        ),
      ),
      bottomNavBar: Container(
        padding: EdgeInsets.only(
          left: 5,
          right: 20,
          top: 10,
          bottom: 15 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xff4D4D4F)),
          ),
        ),
        child: Obx(() => _BottomNavWidget(
              product: controller.product.value,
              isMine: controller.isMine,
              onLikedEvent: controller.onLikedEvent,
              chatInfo: controller.chatInfo.value,
            )),
      ),
    );
  }
}

// _ProductThumbnail
class _ProductThumbnail extends StatelessWidget {
  final Product product;

  const _ProductThumbnail({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: Get.size.width - 40,
            viewportFraction: 1,
            aspectRatio: 0,
            enlargeCenterPage: false,
            scrollDirection: Axis.horizontal,
            autoPlay: false,
            autoPlayInterval: const Duration(seconds: 3),
            enableInfiniteScroll: true,
            disableCenter: true,
            onScrolled: (value) {},
            onPageChanged: (int index, _) {},
          ),
          items: List.generate(
            product.imageUrls?.length ?? 0,
            (index) => CachedNetworkImage(
              imageUrl: product.imageUrls![index],
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                child: CircularProgressIndicator(
                  value: downloadProgress.progress,
                  strokeWidth: 1,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // 이미지 슬라이드에 몇 장의 이미지가 있는지 확인하고,
            // 현재 보고 있는 이미지가 몇 번째인지 표시해주는 인디케이터 역할의 위젯
            children: List.generate(
              product.imageUrls?.length ?? 0,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF212133),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 프로필 섹션
class _ProfileSection extends StatelessWidget {
  final Product product;

  const _ProfileSection({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return product.owner == null
        // 판매자가 없을 경우 Container() 보여주어 오류 방지
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(20),
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
                      AppFont(
                        product.owner?.nickName ?? '',
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      const AppFont(
                        '제주 어딘가',
                        size: 13,
                        color: Color(0xffABAEB6),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    UserTemperatureWidget(
                      temperature: product.owner?.temperature ?? 36.7,
                    ),
                    const SizedBox(height: 5),
                    const AppFont(
                      '매너온도',
                      decoration: TextDecoration.underline,
                      color: Color(0xff878B93),
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}

// 상품 설명, _ProductDetail
class _ProductDetail extends StatelessWidget {
  final Product product;

  const _ProductDetail({
    required this.product,
  });

  Widget _statistic() {
    return Row(
      children: [
        AppFont(
          '관심 ${product.likers?.length ?? 0}',
          size: 12,
          color: const Color(0xff878B93),
        ),
        const AppFont(
          ' . ',
          size: 12,
          color: Color(0xff878B93),
        ),
        AppFont(
          '조회 ${product.viewCount}',
          size: 12,
          color: const Color(0xff878B93),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFont(
            product.title ?? '',
            size: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (product.categoryType != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AppFont(
                    product.categoryType?.name ?? '',
                    size: 12,
                    color: const Color(0xff878B93),
                    decoration: TextDecoration.underline,
                  ),
                ),
              AppFont(
                MarketDataUtils.timeagoValue(
                  product.createdAt ?? DateTime.now(),
                ),
                size: 12,
                color: const Color(0xff878B93),
              ),
            ],
          ),
          const SizedBox(height: 30),
          AppFont(
            product.description ?? '',
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(height: 30),
          _statistic(),
        ],
      ),
    );
  }
}

// _HopeTradeLocation 위젯
class _HopeTradeLocation extends StatelessWidget {
  final Product product;

  const _HopeTradeLocation({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return product.wantTradeLocation != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppFont(
                      '거래 희망 장소',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      size: 15,
                    ),
                    GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.translucent,
                      child: SvgPicture.asset('assets/svg/icons/right.svg'),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 200,
                    child: SimpleTradeLocationMap(
                      myLocation: product.wantTradeLocation!,
                      label: product.wantTradeLocationLabel,
                      interactiveFlags: InteractiveFlag.pinchZoom,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                  indent: 20, endIndent: 20, color: Color(0xff2C2C2E)),
            ],
          )
        : Container();
  }
}

// 판매자의 다른 상품
class _UserProducts extends StatelessWidget {
  final Product product;
  final List<Product> ownerOtherProducts;

  const _UserProducts({
    required this.product,
    required this.ownerOtherProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppFont(
                '${product.owner?.nickName}님의 판매 상품',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                size: 15,
              ),
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.translucent,
                child: SvgPicture.asset('assets/svg/icons/right.svg'),
              )
            ],
          ),
        ),
        SizedBox(
          // GridView를 통해 판매자의 상품을 볼 수 있도록 구성
          // clamp 함수를 사용하여 최대 6개까지만 상품 표시
          // clamp(min, max) 함수를 사용하면 주어진 범위 내에서만 처리
          height: (ownerOtherProducts.length.clamp(0, 6) * 0.5).ceil() * 220,
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.85,
            children: List.generate(
              ownerOtherProducts.length.clamp(0, 6),
              (index) => GestureDetector(
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: ownerOtherProducts[index].imageUrls!.isEmpty
                          ? const SizedBox(
                              height: 120,
                              child: Center(child: Icon(Icons.error)))
                          : SizedBox(
                              height: 120,
                              child: CachedNetworkImage(
                                imageUrl:
                                    ownerOtherProducts[index].imageUrls!.first,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
                                        child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  strokeWidth: 1,
                                )),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    const SizedBox(height: 15),
                    AppFont(
                      ownerOtherProducts[index].title ?? '',
                      maxLine: 1,
                      size: 14,
                    ),
                    const SizedBox(height: 5),
                    PriceView(
                      price: ownerOtherProducts[index].productPrice ?? 0,
                      status: ownerOtherProducts[index].status ??
                          ProductStatusType.sale,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 하단 가격/채팅 영역
class _BottomNavWidget extends StatelessWidget {
  final Product product;
  final Function() onLikedEvent;
  final bool isMine;
  final ChatGroupModel chatInfo;

  const _BottomNavWidget({
    required this.product,
    required this.onLikedEvent,
    required this.isMine,
    required this.chatInfo,
  });

  // 가격 영역
  Widget _price() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppFont(
          product.productPrice == 0
              ? '무료 나눔'
              : '${NumberFormat('###,###,###,###').format(product.productPrice)}원',
          size: 16,
          fontWeight: FontWeight.bold,
          color: product.productPrice == 0
              ? const Color(0xffED7738)
              : Colors.white,
        ),
        const SizedBox(height: 3),
        const AppFont(
          '가격 제안 불가',
          size: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xff878B93),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    log('isMine : $isMine');
    var likers = product.likers ?? [];
    var uid = Get.find<AuthenticationController>().userModel.value.uid;

    return SizedBox(
      height: 50,
      child: Row(
        children: [
          GestureDetector(
            onTap: onLikedEvent,
            behavior: HitTestBehavior.translucent,
            child: Container(
              padding: const EdgeInsets.all(15.0),
              // likers에 uid 존재 여부에 따라 SVG 아이콘 변경
              child: likers.contains(uid)
                  ? SvgPicture.asset('assets/svg/icons/like_on.svg')
                  : SvgPicture.asset('assets/svg/icons/like_off.svg'),
            ),
          ),
          const SizedBox(
            height: 30,
            child: VerticalDivider(
              color: Color(0xff34373C),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(child: _price()),
          if (!isMine)
            Btn(
              onTap: () {
                Get.toNamed(
                    '/chat/${product.docId}/${product.owner!.uid}/$uid');
              },
              child: const AppFont(
                '채팅하기',
                fontWeight: FontWeight.bold,
              ),
            ),
          if (isMine)
            Btn(
              onTap: () {
                if (chatInfo.chatters != null) {
                  Get.toNamed(
                    '/chat-list',
                    arguments: {
                      'productId': product.docId,
                    },
                  );
                }
              },
              child: AppFont(
                '채팅 ${chatInfo.chatCount}개',
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
