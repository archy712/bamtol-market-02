import 'dart:developer';

import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:bamtol_market_02/src/common/controller/common_layout_controller.dart';
import 'package:bamtol_market_02/src/common/enum/market_enum.dart';
import 'package:bamtol_market_02/src/common/model/asset_value_entity.dart';
import 'package:bamtol_market_02/src/common/model/product.dart';
import 'package:bamtol_market_02/src/common/repository/cloud_firebase_storage_repository.dart';
import 'package:bamtol_market_02/src/product/repository/product_repository.dart';
import 'package:bamtol_market_02/src/user/model/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductWriteController extends GetxController {
  // 물건 작성 페이지에 진입은 로그인된 회원 상태
  final UserModel owner;

  // 물건 작성 Repository
  final ProductRepository _productRepository;

  // Rx방식으로 등록한 Product 관리
  final Rx<Product> product = const Product().obs;

  // CloudFirebaseRepository
  final CloudFirebaseRepository _cloudFirebaseRepository;

  // (선택된 이미지를 Rx 방식으로 관리하기 위해 selectedChanges 변수를 RxList로 선언
  // AssetEntity 부분을 AssetValueEntity로 수정
  RxList<AssetValueEntity> selectedImages = <AssetValueEntity>[].obs;

  // 저장 기능 구현 위한 완료 버튼 활성화/비활성화 여부
  RxBool isPossibleSubmit = false.obs;

  ProductWriteController(
    this.owner,
    this._productRepository,
    this._cloudFirebaseRepository,
  );

  // 수정/삭제 구분자
  bool isEditMode = false;

  @override
  void onInit() {
    super.onInit();
    var productDocId = Get.parameters['product_doc_id'];
    log('product_doc_id : $productDocId');
    if (productDocId != null) {
      // 수정 모드
      isEditMode = true;
      _loadProductDetail(productDocId);
    }
    product.stream.listen((event) {
      _isValidSubmitPossible();
    });
  }

  // 수정 모드일 떄 값 불러오기
  _loadProductDetail(String docId) async {
    var productValue = await _productRepository.getProduct(docId);
    if (productValue != null) {
      product(productValue);
      if (productValue.imageUrls != null) {
        // 이미지 세팅
        selectedImages.addAll(
          productValue.imageUrls!
              .map<AssetValueEntity>((e) => AssetValueEntity(thumbnail: e))
              .toList(),
        );
      }
    }
  }

  // 유효성 여부 검증
  _isValidSubmitPossible() {
    if (selectedImages.isNotEmpty &&
        (product.value.productPrice ?? 0) >= 0 &&
        product.value.title != '') {
      isPossibleSubmit(true);
    } else {
      isPossibleSubmit(false);
    }
  }

  // 이미지를 상태 관리 변수에 저장하는 함수 작성
  changeSelectedImages(List<AssetValueEntity>? images) {
    selectedImages(images);
  }

  // 인덱스 번호를 통해 선택된 이미지를 삭제
  deleteImage(int index) {
    selectedImages.removeAt(index);
  }

  // Rx 방식으로 등록한 Product 모델의 제목이 입력될 때마다 copyWith를 사용하여
  // 변경된 값을 product에 업데이트
  changeTitle(String value) {
    product(product.value.copyWith(title: value));
  }

  // 카테고리 타입 선택/변경
  changeCategoryType(ProductCategoryType? type) {
    product(product.value.copyWith(categoryType: type));
  }

  // 가격 변경
  changePrice(String price) {
    if (!RegExp(r'^[0-9]+$').hasMatch(price)) return;
    product(
      product.value.copyWith(
        productPrice: int.parse(price),
        isFree: int.parse(price) == 0,
      ),
    );
  }

  // 나눔여부 변경
  changeIsFreeProduct() {
    product(product.value.copyWith(isFree: !(product.value.isFree ?? false)));
    if (product.value.isFree!) {
      changePrice('0');
    }
  }

  // 상품 설명 변경
  changeDescription(String value) {
    product(product.value.copyWith(description: value));
  }

  // 거래 희망장소 선택/변경
  changeTradeLocationMap(Map<String, dynamic> mapInfo) {
    product(
      product.value.copyWith(
        wantTradeLocationLabel: mapInfo['label'],
        wantTradeLocation: mapInfo['location'],
      ),
    );
  }

  // 거래 희망장소 삭제
  clearWantTradeLocation() {
    product(
      product.value.copyWith(
        wantTradeLocationLabel: '',
        wantTradeLocation: null,
      ),
    );
  }

  // 등록된 이미지를 Firebase 업로드
  // Firebase에 업로드한 이미지의 URL을 사용하여 상품정보(메타정보)를 데이터베이스 저장
  submit() async {
    // 로딩 시작
    CommonLayoutController.to.loading(true);

    // 메타정보 업데이트
    product(
      product.value.copyWith(
        owner: owner,
        imageUrls: selectedImages.map((e) => e.thumbnail ?? '').toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (selectedImages
        .where((selectedImages) => selectedImages.id != '')
        .toList()
        .isNotEmpty) {
      var downloadUrls = await uploadImages(selectedImages);
      product(product.value.copyWith(imageUrls: downloadUrls));
    }

    String resultMessage = '';
    if (isEditMode) {
      await _productRepository.editProduct(product.value);
      resultMessage = '물건이 수정되었습니다.';
    } else {
      await _productRepository.saveProduct(product.value.toMap());
      resultMessage = '물건이 등록되었습니다.';
    }

    // 로딩 종료
    CommonLayoutController.to.loading(false);

    // 다이얼로그 띄우기
    await showDialog(
      context: Get.context!,
      builder: (context) {
        return CupertinoAlertDialog(
          content: AppFont(
            resultMessage,
            color: Colors.black,
            size: 16,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const AppFont(
                '확인',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
    // 새로 등록된 상품이 화면에 반영되도록 새로고침 (result: true)
    Get.back(result: true);
  }

  Future<List<String>> uploadImages(List<AssetValueEntity> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      var downloadUrl = image.thumbnail ?? '';
      if (image.id != '') {
        var file = await image.file;
        if (file == null) return [];
        downloadUrl =
            await _cloudFirebaseRepository.uploadFile(owner.uid!, file);
      }

      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }
}
