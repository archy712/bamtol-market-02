import 'package:bamtol_market_02/src/splash/enum/step_type.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  Rx<StepType> loadStep = StepType.dataLoad.obs;

  changeStep(StepType type) {
    loadStep(type);
  }
}
