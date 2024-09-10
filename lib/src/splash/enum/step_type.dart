enum StepType {
  init(''),
  dataLoad('데이터 로드'),
  authCheck('인증 체크'),
  logOut('로그아웃');

  final String name;
  const StepType(this.name);
}
