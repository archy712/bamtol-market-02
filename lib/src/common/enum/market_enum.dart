enum ProductCategoryType {
  none('카테고리 선택', ''),
  digital('디지털 기기', 'PT1'),
  householdAppliances('생활 가전', 'PT2'),
  furniture('가구/인테리어', 'PT3'),
  life('생활/주방', 'PT4'),
  children('유아동', 'PT5'),
  childrenBooks('유아 도서', 'PT6'),
  womenClothing('여성 의류', 'PT7'),
  womenAccessories('여성 잡화', 'PT8'),
  menFashion('남성 패션/잡화', 'PT9'),
  beauty('뷰티/미용', 'PT10'),
  sports('스포츠/레저', 'PT11'),
  hobby('취미/게임/음반', 'PT12'),
  books('도서', 'PT13'),
  ticket('티켓/교환권', 'PT14'),
  processedFood('가공 식품', 'PT15'),
  petSupplies('반려동물 용품', 'PT16'),
  plant('식물', 'PT17'),
  etc('기타 중고 물품', 'PT18');

  final String name;
  final String code;
  const ProductCategoryType(this.name, this.code);

  static ProductCategoryType? findByCode(String code) {
    var result =
        ProductCategoryType.values.where((element) => element.code == code);
    if (result.isEmpty) return null;
    return result.first;
  }
}

enum ProductStatusType {
  sale('sale', '판매 중'),
  reservation('reservation', '예약 중'),
  soldOut('soldOut', '판매 완료'),
  cancel('cancel', '취소');

  final String value;
  final String name;

  const ProductStatusType(this.value, this.name);
}
