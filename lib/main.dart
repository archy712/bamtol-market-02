import 'package:bamtol_market_02/firebase_options.dart';
import 'package:bamtol_market_02/src/app.dart';
import 'package:bamtol_market_02/src/chat/controller/chat_controller.dart';
import 'package:bamtol_market_02/src/chat/controller/chat_list_controller.dart';
import 'package:bamtol_market_02/src/chat/page/chat_list_page.dart';
import 'package:bamtol_market_02/src/chat/page/chat_page.dart';
import 'package:bamtol_market_02/src/chat/repository/chat_repository.dart';
import 'package:bamtol_market_02/src/common/controller/authentication_controller.dart';
import 'package:bamtol_market_02/src/common/controller/bottom_nav_controller.dart';
import 'package:bamtol_market_02/src/common/controller/common_layout_controller.dart';
import 'package:bamtol_market_02/src/common/controller/data_load_controller.dart';
import 'package:bamtol_market_02/src/common/repository/cloud_firebase_storage_repository.dart';
import 'package:bamtol_market_02/src/home/controller/home_controller.dart';
import 'package:bamtol_market_02/src/product/detail/controller/product_detail_controller.dart';
import 'package:bamtol_market_02/src/product/detail/page/product_detail_view.dart';
import 'package:bamtol_market_02/src/product/repository/product_repository.dart';
import 'package:bamtol_market_02/src/product/write/controller/product_write_controller.dart';
import 'package:bamtol_market_02/src/product/write/page/product_write_page.dart';
import 'package:bamtol_market_02/src/root.dart';
import 'package:bamtol_market_02/src/splash/controller/splash_controller.dart';
import 'package:bamtol_market_02/src/user/login/controller/login_controller.dart';
import 'package:bamtol_market_02/src/user/login/page/login_page.dart';
import 'package:bamtol_market_02/src/user/repository/authentication_repository.dart';
import 'package:bamtol_market_02/src/user/repository/user_repository.dart';
import 'package:bamtol_market_02/src/user/signup/controller/signup_controller.dart';
import 'package:bamtol_market_02/src/user/signup/page/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 전역변수 선언 (SharedPreferences)
late SharedPreferences prefs;

void main() async {
  // Firebase 초기화를 위해 WidgetsFlutterBinding 초기화 확인
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences 초기화 (한번만 생성 필요, 싱글턴 패턴)
  prefs = await SharedPreferences.getInstance();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // FireStore DB 인스턴스 생성
    var db = FirebaseFirestore.instance;

    return GetMaterialApp(
      title: '밤톨마켓',
      initialRoute: '/',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 0,
          color: Color(0xFF212133),
          titleTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFF212133),
      ),
      initialBinding: BindingsBuilder(() {
        var authenticationRepository =
            AuthenticationRepository(FirebaseAuth.instance);
        var userRepository = UserRepository(db);

        Get.put(authenticationRepository);
        Get.put(userRepository);
        Get.put(CommonLayoutController());
        Get.put(ProductRepository(db));
        Get.put(ChatRepository(db));
        Get.put(BottomNavController());
        Get.put(SplashController());
        Get.put(DataLoadController());
        Get.put(AuthenticationController(
          authenticationRepository,
          userRepository,
        ));
        Get.put(CloudFirebaseRepository(FirebaseStorage.instance));
        Get.lazyPut<ChatListController>(
          () => ChatListController(
            Get.find<ChatRepository>(),
            Get.find<ProductRepository>(),
            Get.find<UserRepository>(),
            Get.find<AuthenticationController>().userModel.value.uid ?? '',
          ),
          fenix: true,
        );
      }),
      getPages: [
        GetPage(name: '/', page: () => const App()),
        GetPage(
          name: '/home',
          page: () => const Root(),
          binding: BindingsBuilder(() {
            Get.put(HomeController(Get.find<ProductRepository>()));
          }),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut<LoginController>(
              () => LoginController(
                Get.find<AuthenticationRepository>(),
              ),
            );
          }),
        ),
        GetPage(
          name: '/signup/:uid',
          page: () => const SignupPage(),
          binding: BindingsBuilder(() {
            Get.create<SignupController>(
              () => SignupController(
                Get.find<UserRepository>(),
                Get.parameters['uid'] as String,
              ),
            );
          }),
        ),
        GetPage(
          name: '/product/write',
          page: () => const ProductWritePage(),
          binding: BindingsBuilder(() {
            Get.put(
              ProductWriteController(
                Get.find<AuthenticationController>().userModel.value,
                Get.find<ProductRepository>(),
                Get.find<CloudFirebaseRepository>(),
              ),
            );
          }),
        ),
        GetPage(
          name: '/product/detail/:docId',
          page: () => const ProductDetailView(),
          binding: BindingsBuilder(() {
            Get.put(
              ProductDetailController(
                Get.find<ProductRepository>(),
                Get.find<AuthenticationController>().userModel.value,
                Get.find<ChatRepository>(),
              ),
            );
          }),
        ),
        GetPage(
          name: '/chat/:docId/:ownerUid/:customerUid',
          page: () => const ChatPage(),
          binding: BindingsBuilder(() {
            Get.put(
              ChatController(
                Get.find<ChatRepository>(),
                Get.find<UserRepository>(),
                Get.find<ProductRepository>(),
              ),
            );
          }),
        ),
        GetPage(
          name: '/chat-list',
          page: () => const ChatListPage(useBackBtn: true),
        ),
      ],
    );
  }
}
