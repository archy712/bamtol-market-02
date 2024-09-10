import 'dart:developer';

import 'package:bamtol_market_02/src/common/model/product.dart';
import 'package:bamtol_market_02/src/common/model/product_search_option.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// 인스턴스 생성 시 컬렉션을 지정하여 내부 클래스 변수로 활용
class ProductRepository extends GetxService {
  late CollectionReference products;

  ProductRepository(FirebaseFirestore db) {
    products = db.collection('products');
  }

  // products 콜렉션에 저장
  Future<String?> saveProduct(Map<String, dynamic> data) async {
    try {
      var docs = await products.add(data);
      return docs.id;
    } catch (e) {
      log('products 저장 오류 : ${e.toString()}');
      return null;
    }
  }

  // products 콜렉션 조회
  Future<({List<Product> list, QueryDocumentSnapshot<Object?>? lastItem})>
      getProducts(ProductSearchOption searchOption) async {
    try {
      // 검색조건 설정
      Query<Object?> query = searchOption.toQuery(products);
      QuerySnapshot<Object?> snapshot;

      if (searchOption.lastItem == null) {
        snapshot = await query.limit(7).get();
      } else {
        snapshot = await query
            .startAfterDocument(searchOption.lastItem!)
            .limit(7)
            .get();
      }

      if (snapshot.docs.isNotEmpty) {
        return (
          list: snapshot.docs.map<Product>((product) {
            return Product.fromJson(
                product.id, product.data() as Map<String, dynamic>);
          }).toList(),
          lastItem: snapshot.docs.last,
        );
      }
      // Dart 3.x 버전에서 도입된 레코드 타입 방식
      // 페이징을 고려하여 상품 리스트와 마지막 아이템을 함께 전달
      return (list: <Product>[], lastItem: null);
    } catch (e) {
      log('getProducts() 오류 : ${e.toString()}');
      return (list: <Product>[], lastItem: null);
    }
  }

  // 상품 상세 조회
  Future<Product?> getProduct(String docId) async {
    try {
      DocumentReference docRef = products.doc(docId);
      var product = await docRef.get();
      return Product.fromJson(docId, product.data() as Map<String, dynamic>);
    } catch (e) {
      log('getProduct 오류 : ${e.toString()}');
      return null;
    }
  }

  // 파라미터로 받은 상품을 업데이트
  Future<void> editProduct(Product product) async {
    try {
      await products.doc(product.docId).update(product.toMap());
    } catch (e) {
      return;
    }
  }

  // 상품 삭제 처리
  Future<bool> deleteProduct(String docId) async {
    try {
      DocumentReference docRef = products.doc(docId);
      await docRef.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
