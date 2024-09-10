import 'package:bamtol_market_02/src/user/model/user_model.dart';
import 'package:bamtol_market_02/src/user/repository/user_repository.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  // 회원 데이터 접근 위해 UserRepository 주입
  final UserRepository _userRepository;

  // 조회할 회원 uid
  final String uid;

  SignupController(
    this._userRepository,
    this.uid,
  );

  // 화면에서 변경되는 값을 저장하기 위해 Rx 방식으로 변수 선언
  RxString userNickName = ''.obs;

  // 중복 닉네임 여부
  RxBool isPossibleUserNickName = false.obs;

  @override
  void onInit() {
    super.onInit();
    // TextField의 onChanged 이벤트는 키보드 칠 때 계속 입력 발생 > 완료되면 처리 위해
    // 사용자 입력이 더 이상 발생하지 않은 후 0.5초가 지나면 이벤트 발생
    // debounce(
    //   userNickName,
    //   (callback) {},
    //   time: const Duration(milliseconds: 500),
    // );

    // nickName 중복 체크
    debounce(
      userNickName,
      checkDuplicationNickName,
      time: const Duration(milliseconds: 500),
    );
  }

  // 닉네임 중복 체크
  checkDuplicationNickName(String value) async {
    var isPossibleUse = await _userRepository.checkDuplicationNickName(value);
    isPossibleUserNickName(isPossibleUse);
  }

  // 변경된 닉네임을 상태변수에 저장
  changeNickName(String nickName) {
    userNickName(nickName);
  }

  Future<String?> signup() async {
    var newUser = UserModel.create(userNickName.value, uid);
    var result = await _userRepository.signup(newUser);
    return result;
  }
}
