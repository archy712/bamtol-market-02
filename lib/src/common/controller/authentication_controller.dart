import 'dart:developer';

import 'package:bamtol_market_02/src/common/enum/authentication_status.dart';
import 'package:bamtol_market_02/src/user/model/user_model.dart';
import 'package:bamtol_market_02/src/user/repository/authentication_repository.dart';
import 'package:bamtol_market_02/src/user/repository/user_repository.dart';
import 'package:get/get.dart';

class AuthenticationController extends GetxController {
  // 사용할 AuthenticationRepository
  final AuthenticationRepository _authenticationRepository;

  // 사용자(user) 정보 DB 조회를 위한 Repository
  final UserRepository _userRepository;

  AuthenticationController(
    this._authenticationRepository,
    this._userRepository,
  );

  // RxBool isLogined = false.obs;

  // AuthenticaationStatus 등록하여 초기화 상태를 init 으로 설정
  Rx<AuthenticationStatus> status = AuthenticationStatus.init.obs;

  // 관리할 사용자 정보
  Rx<UserModel> userModel = const UserModel().obs;

  void authCheck() async {
    // await Future.delayed(const Duration(milliseconds: 1000));
    // isLogined(true);
    // log('authCheck 완료');
    _authenticationRepository.user.listen((user) {
      _userStateChangedEvent(user);
    });
  }

  void _userStateChangedEvent(UserModel? user) async {
    if (user == null) {
      // unknown
      status(AuthenticationStatus.unknown);
      log('AuthenticationController : AuthenticationStatus.unknown');
    } else {
      // authentication or unAuthentication
      // UserRepository 이용하여 사용자 정보 DB 조회
      var result = await _userRepository.findUserOne(user.uid!);
      if (result == null) {
        userModel(user);
        status(AuthenticationStatus.unAuthenticated);
        log('AuthenticationController : AuthenticationStatus.unAuthentication');
      } else {
        status(AuthenticationStatus.authentication);
        userModel(result);
        log('AuthenticationController : AuthenticationStatus.authentication');
      }
    }
  }

  // 책에는 안나와 있고, Github 소스에는 있음
  // 회원가입 이후에 새로고침 필요
  void reload() {
    _userStateChangedEvent(userModel.value);
  }

  void logout() async {
    //isLogined(false);
    await _authenticationRepository.logout();
    log('AuthenticationController : logout 완료');
  }
}
