import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:bamtol_market_02/src/common/components/checkbox.dart';
import 'package:bamtol_market_02/src/common/components/common_text_field.dart';
import 'package:bamtol_market_02/src/common/components/multiple_image_view.dart';
import 'package:bamtol_market_02/src/common/components/product_category_selector.dart';
import 'package:bamtol_market_02/src/common/components/trade_location_map.dart';
import 'package:bamtol_market_02/src/common/enum/market_enum.dart';
import 'package:bamtol_market_02/src/common/layout/common_layout.dart';
import 'package:bamtol_market_02/src/common/model/asset_value_entity.dart';
import 'package:bamtol_market_02/src/product/write/controller/product_write_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ProductWritePage extends GetView<ProductWriteController> {
  const ProductWritePage({super.key});

  // Divider
  Widget get _divider => const Divider(
        color: Color(0xFF3C3C3E),
        indent: 25,
        endIndent: 25,
      );

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      appBar: AppBar(
        // leading 옵션으로 페이지 닫는 아이콘
        // 이벤트는 GetX의 Get.back을 사용하여 간단하게 처리
        leading: GestureDetector(
          onTap: Get.back,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset('assets/svg/icons/close.svg'),
          ),
        ),
        centerTitle: true,
        title: const AppFont(
          '내 물건 팔기',
          fontWeight: FontWeight.bold,
          size: 18,
        ),
        actions: [
          Obx(
            () => GestureDetector(
              onTap: () {
                if (controller.isPossibleSubmit.value) {
                  controller.submit();
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 25.0),
                child: AppFont(
                  '완료',
                  color: controller.isPossibleSubmit.value
                      ? const Color(0xFFED7738)
                      : Colors.grey,
                  fontWeight: FontWeight.bold,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const _PhotoSelectView(),
                  _divider,
                  const _ProductTitleView(),
                  _divider,
                  const _CategorySelectView(),
                  _divider,
                  const _PriceSettingView(),
                  _divider,
                  const _ProductDescription(),
                  // 설명 입력 하단에 두꺼운 경계선. 위젯 간 경계 명확하게 해 주는 효과
                  Container(
                    height: 5,
                    color: const Color.fromARGB(255, 12, 12, 15),
                  ),
                  const _HopeTradeLocationMap(),
                ],
              ),
            ),
          ),
          Container(
            height: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFF3C3C3E),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/svg/icons/photo_small.svg'),
                    const SizedBox(width: 10),
                    const AppFont(
                      '0/10',
                      size: 13,
                      color: Colors.white,
                    ),
                  ],
                ),
                GestureDetector(
                  // 키보드 내리기 아이콘을 눌렀을 때 키보드를 숨기려면,
                  // FocusScope의 unfocus 이벤트를 사용하여 textField를 비활성 처리
                  onTap: FocusScope.of(context).unfocus,
                  behavior: HitTestBehavior.translucent,
                  child: SvgPicture.asset('assets/svg/icons/keyboard-down.svg'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 1) 이미지 편집 영역
// 선택된 이미지를 반환받아 관리하기 위해 GetView로 변경
class _PhotoSelectView extends GetView<ProductWriteController> {
  const _PhotoSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: Row(
        children: [
          _photoSelectIcon(),
          Expanded(
            child: _selectedImageList(),
          ),
        ],
      ),
    );
  }

  // 1-1) 이미지 선택 버튼
  Widget _photoSelectIcon() {
    return GestureDetector(
      onTap: () async {
        // 페이지 이동 시 반환 타입을 제네릭으로 미리 선언
        var selectedImages = await Get.to<List<AssetValueEntity>?>(
          () => MultipleImageView(
            // ProductWriteController에서 관리하는 selectedImages (선택된 이미지)를
            // MultipleImageView 클래스에 전달
            initImages: controller.selectedImages,
          ),
        );
        // 넘겨받은 이미지를 changeSelectedImages 통해 controller로 전달
        // ProductWriteController 내에서 상태를 관리
        controller.changeSelectedImages(selectedImages);
      },
      child: Container(
        width: 77,
        height: 77,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF42464E)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/svg/icons/camera.svg'),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 선택된 이미지의 개수를 표시하기 위해 Obx 사용하여 상태 구독
                Obx(
                  () => AppFont(
                    '${controller.selectedImages.length}',
                    size: 13,
                    color: const Color(0xFF868B95),
                  ),
                ),
                const AppFont(
                  '/10',
                  size: 13,
                  color: Color(0xFF868B95),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 1-2) 이미지 선택 리스트
  Widget _selectedImageList() {
    return Container(
      margin: const EdgeInsets.only(left: 15),
      height: 77,
      // 선택된 이미지를 보여주기 위해 Obx를 사용하여 상태를 구독
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 67,
                      height: 67,
                      child: controller.selectedImages[index].thumbnail != null
                          ? CachedNetworkImage(
                              imageUrl:
                                  controller.selectedImages[index].thumbnail!,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  strokeWidth: 1,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                            )
                          : FutureBuilder(
                              future: controller.selectedImages[index].file,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.file(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10.0,
                  child: GestureDetector(
                    onTap: () {
                      controller.deleteImage(index);
                    },
                    child: SvgPicture.asset('assets/svg/icons/remove.svg'),
                  ),
                ),
              ],
            );
          },
          // 선택된 이미지 개수만큼 ListView를 그리기 위해,
          // controller에서 선택된 이미지 개수를 가져와 사용
          itemCount: controller.selectedImages.length,
        ),
      ),
    );
  }
}

// 2) 글 제목 영역
class _ProductTitleView extends GetView<ProductWriteController> {
  const _ProductTitleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Obx(
        () => CommonTextField(
          hintText: '글 제목',
          initText: controller.product.value.title,
          onChange: controller.changeTitle,
          hintColor: const Color(0xFF6D7179),
        ),
      ),
    );
  }
}

// 3) 카테고리 선택 영역
class _CategorySelectView extends GetView<ProductWriteController> {
  const _CategorySelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      child: GestureDetector(
        onTap: () async {
          //await Get.dialog(const ProductCategorySelector());
          var selectedCategoryType = await Get.dialog<ProductCategoryType?>(
            ProductCategorySelector(
              initType: controller.product.value.categoryType,
            ),
          );
          controller.changeCategoryType(selectedCategoryType);
        },
        behavior: HitTestBehavior.translucent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => AppFont(
                controller.product.value.categoryType!.name,
                size: 16,
                color: Colors.white,
              ),
            ),
            SvgPicture.asset('assets/svg/icons/right.svg'),
          ],
        ),
      ),
    );
  }
}

// 4) 가격 입력 필드 + [나눔] 체크박스 적용
class _PriceSettingView extends GetView<ProductWriteController> {
  const _PriceSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => CommonTextField(
                hintColor: const Color(0xFF6D7179),
                hintText: '₩ 가격 (선택 사항)',
                textInputType: TextInputType.number,
                initText: controller.product.value.productPrice.toString(),
                onChange: controller.changePrice,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')),
                ],
              ),
            ),
          ),
          Obx(
            () => CheckBox(
              label: '나눔',
              isChecked: controller.product.value.isFree ?? false,
              toggleCallBack: controller.changeIsFreeProduct,
            ),
          ),
        ],
      ),
    );
  }
}

// 5) 상품 상세 설명 영역
class _ProductDescription extends GetView<ProductWriteController> {
  const _ProductDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Obx(
        () => CommonTextField(
          hintColor: const Color(0xFF6D7179),
          hintText: '신도림에 올릴 게시글 내용을 작성해 주세요\n(판매 금지 물품은 게시가 제한될 수 있어요)',
          textInputType: TextInputType.multiline,
          initText: controller.product.value.description,
          maxLines: 10,
          onChange: controller.changeDescription,
        ),
      ),
    );
  }
}

// 6) 희망하는 거래 장소 설정 영역
class _HopeTradeLocationMap extends GetView<ProductWriteController> {
  const _HopeTradeLocationMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
      child: GestureDetector(
        onTap: () async {
          var result = await Get.to<Map<String, dynamic>?>(
            TradeLocationMap(
              label: controller.product.value.wantTradeLocationLabel,
              location: controller.product.value.wantTradeLocation,
            ),
          );
          if (result != null) {
            // TradeLocationMap()에서 받아온 정보를 관리하기 위해 업데이트
            controller.changeTradeLocationMap(result);
          }
        },
        behavior: HitTestBehavior.translucent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppFont(
              '거래 희망 장소',
              size: 16,
              color: Colors.white,
            ),
            // 희망 장소 정보의 유무에 따라 다르게 표시되도록
            // 정보가 없으면 : '장소 선택' 문구와 아이콘 나타나고
            // 정보가 있으면 저장된 이름과 삭제 아이콘이 함께 표시
            Obx(
              () => controller.product.value.wantTradeLocationLabel == null ||
                      controller.product.value.wantTradeLocationLabel == ''
                  ? Row(
                      children: [
                        const AppFont(
                          '장소 선택',
                          size: 13,
                          color: Color(0xFF6D7179),
                        ),
                        SvgPicture.asset('assets/svg/icons/right.svg')
                      ],
                    )
                  : Row(
                      children: [
                        AppFont(
                          controller.product.value.wantTradeLocationLabel ?? '',
                          size: 13,
                          color: Colors.white,
                        ),
                        GestureDetector(
                          // 삭제 아이콘을 누르면 기존 데이터를 제거하는 로직 추가
                          onTap: () => controller.clearWantTradeLocation(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                SvgPicture.asset('assets/svg/icons/delete.svg'),
                          ),
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
