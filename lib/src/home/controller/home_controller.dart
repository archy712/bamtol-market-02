import 'dart:developer';

import 'package:bamtol_market_02/src/common/enum/market_enum.dart';
import 'package:bamtol_market_02/src/common/model/product.dart';
import 'package:bamtol_market_02/src/common/model/product_search_option.dart';
import 'package:bamtol_market_02/src/product/repository/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepository;

  HomeController(
    this._productRepository,
  );

  RxList<Product> productList = <Product>[].obs;

  // 페이징 처리를 위해 ListView에서 사용할 ScrollController 등록
  ScrollController scrollController = ScrollController();

  // 검색 조건을 생성
  // 홈 화면에서는 특정 계정의 상품을 볼 이유가 없고, 상품 상태는 판매중, 예약중 인것만
  // lastItem이 null이면 첫 페이지를 의미
  ProductSearchOption searchOption = const ProductSearchOption(
    status: [
      ProductStatusType.sale,
      ProductStatusType.reservation,
    ],
  );

  // 페이징 시 반복 호출을 방지하기 위해 로딩(isLoading) 상태를 추가
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProductList();
    _event();
  }

  // ScrollController 스크롤 이벤트를 추적하기 위해
  void _event() {
    scrollController.addListener(() {
      if (scrollController.offset >
              scrollController.position.maxScrollExtent - 100 &&
          searchOption.lastItem != null &&
          !isLoading.value) {
        _loadProductList();
      }
    });
  }

  // 기존 productList 값을 초기화
  void _initData() {
    // 상품을 등록한 후 화면을 새로고침 할 때 데이터를 다시 불러오는데
    // 이 때 lastItem을 비워줘야 함.
    searchOption = searchOption.copyWith(lastItem: null);
    productList.clear();
  }

  @override
  void refresh() async {
    _initData();
    await _loadProductList();
  }

  // 모든 상품 데이터를 조회하는 역할
  // 나중에 검색 조건을 추가하여 기능 개선 예정
  Future<void> _loadProductList() async {
    // 스크롤 중에도 중복 호출이 되지 않음
    isLoading(true);

    var result = await _productRepository.getProducts(searchOption);
    //log('상품 갯수 : ${result.list.length.toString()}');

    // 페이징을 위한 시간 지연
    await Future.delayed(const Duration(milliseconds: 1000));

    // lastItem 조건에 따라 검색 필터 모델에 추가
    if (result.lastItem != null) {
      searchOption = searchOption.copyWith(lastItem: result.lastItem);
    } else {
      searchOption = searchOption.copyWith(lastItem: null);
    }

    productList.addAll(result.list);

    // 다시 다음 페이지를 호출할 수 있는 상태로 만듬
    isLoading(false);
  }
}
