import 'package:bamtol_market_02/src/chat/model/chat_group_model.dart';
import 'package:bamtol_market_02/src/chat/repository/chat_repository.dart';
import 'package:bamtol_market_02/src/common/enum/market_enum.dart';
import 'package:bamtol_market_02/src/common/model/product.dart';
import 'package:bamtol_market_02/src/common/model/product_search_option.dart';
import 'package:bamtol_market_02/src/product/repository/product_repository.dart';
import 'package:bamtol_market_02/src/user/model/user_model.dart';
import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  // 상품 데이터를 관리하기 위해
  final ProductRepository _productRepository;

  // 글쓴이 사용자
  final UserModel myUser;

  // 채팅방, 채팅유저 관리 위해
  final ChatRepository _chatRepository;

  // 생성자
  ProductDetailController(
    this._productRepository,
    this.myUser,
    this._chatRepository,
  );

  // 경로에 있는 변수(docId)를 GetX의 Get.parameters를 통해 받아옴
  // 이 값을 ProductDetailController 클래스의 docId 변수에 저장
  late String docId;

  // 데이터베이스에서 조회한 상품 데이터를 Rx 방식으로 상태 관리
  Rx<Product> product = const Product.empty().obs;

  // 판매자의 다른 상품 데이터를 Rx 방식으로 상태 관리
  RxList<Product> ownerOtherProducts = <Product>[].obs;

  // 1개의 상품에 대한 채팅방들 정보
  Rx<ChatGroupModel> chatInfo = const ChatGroupModel().obs;

  // 내 게시물인지 체크하는 getter 추가
  bool get isMine => myUser.uid == product.value.owner?.uid;

  // 수정모드인지 여부
  bool isEdited = false;

  @override
  void onInit() async {
    super.onInit();
    docId = Get.parameters['docId'] ?? '';
    await _loadProductDetailData();
    await _loadOtherProducts();
    await _loadHowManyChatThisProduct();
  }

  // 상품 조회
  Future<void> _loadProductDetailData() async {
    var result = await _productRepository.getProduct(docId);
    if (result == null) return;

    //product(result);
    product(
      result.copyWith(
        viewCount: (result.viewCount ?? 0) + 1,
      ),
    );
    _updateProductInfo();
  }

  // 판매자의 다른 상품 조회
  Future<void> _loadOtherProducts() async {
    var searchOption = ProductSearchOption(
      ownerId: product.value.owner?.uid ?? '',
      status: const [
        ProductStatusType.sale,
        ProductStatusType.reservation,
      ],
    );
    var results = await _productRepository.getProducts(searchOption);
    ownerOtherProducts.addAll(results.list);
  }

  // 상품을 업데이트 하는 내부 함수
  void _updateProductInfo() async {
    await _productRepository.editProduct(product.value);
  }

  // 즐겨찾기/관심상품 등록
  void onLikedEvent() {
    var likers = product.value.likers ?? [];
    if (likers.contains(myUser.uid)) {
      likers = likers.toList()..remove(myUser.uid);
    } else {
      likers = likers.toList()..add(myUser.uid!);
    }
    product(
      product.value.copyWith(
        likers: List.unmodifiable([...likers]),
      ),
    );
    _updateProductInfo();
  }

  // 상품 삭제
  Future<bool> deleteProduct() async {
    return await _productRepository.deleteProduct(product.value.docId!);
  }

  // 리프레쉬
  @override
  void refresh() async {
    isEdited = true;
    await _loadProductDetailData();
  }

  // 1개의 상품에 대한 채팅방 정보들
  Future<void> _loadHowManyChatThisProduct() async {
    var result = await _chatRepository.loadAllChats(product.value.docId!);
    if (result != null) {
      chatInfo(result);
    }
  }
}
