import 'package:bamtol_market_02/src/user/repository/authentication_repository.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final AuthenticationRepository authenticationRepository;

  LoginController(
    this.authenticationRepository,
  );

  // 구글 로그인
  void googleLogin() async {
    await authenticationRepository.signInWithGoogle();
  }

  // Apple 로그인
  void appleLogin() async {
    await authenticationRepository.signInWithApple();
  }
}
