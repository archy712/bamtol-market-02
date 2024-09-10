import 'dart:typed_data';

import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:bamtol_market_02/src/common/model/asset_value_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class MultipleImageView extends StatefulWidget {
  // 현재 선택되어 있는 이미지가 있다면 받음.
  final List<AssetValueEntity>? initImages;

  const MultipleImageView({
    super.key,
    this.initImages,
  });

  @override
  State<MultipleImageView> createState() => _MultipleImageViewState();
}

class _MultipleImageViewState extends State<MultipleImageView> {
  // 앨범 목록
  var albums = <AssetPathEntity>[];

  // 로그한 사진 정보를 저장하기 위해
  var imageList = <AssetValueEntity>[];
  int currentPage = 0;

  // 선택된 이미지를 관리하기 위해 클래스 변수로 정의
  var selectedImages = <AssetValueEntity>[];

  // 사진 페이징 처리를 위한 ScrollController
  var scrollController = ScrollController();

  int lastPage = -1;

  // StatefulWidget 생명주기 활용
  // ScrollController 이벤트를 구독하여 정보를 확인할 수 있게
  //
  // 스크롤 위치와 전체 높이를 비교해서, 두 값이 같으면 다음 페이지를 불러오도록 설정
  // 전체 높이에서 150 정도를 빼주면, 화면의 맨 아래(전체높이)에 도달하기 전에 미리 데이터를 로드
  // currentPage와 lastPage를 비교해서 중복 요청을 방지
  // 비교하지 않으면 스크롤의 위치가 maxScroll - 150 보다 커지는 순간부터
  // 계속 _pagingPhotos 함수 호출
  @override
  void initState() {
    super.initState();
    loadMyPhotos();
    scrollController.addListener(() {
      var maxScroll = scrollController.position.maxScrollExtent;
      var currentScroll = scrollController.offset;
      if (currentScroll > maxScroll - 150 && currentPage != lastPage) {
        lastPage = currentPage;
        _pagingPhotos();
      }
    });

    // 선택된 이미지가 가지고 왔다면 같이 표시
    if (widget.initImages != null) {
      selectedImages.addAll([...widget.initImages!]);
    }
  }

  // 퍼미션 권한 요청
  void loadMyPhotos() async {
    var permissionState = await PhotoManager.requestPermissionExtend();
    if (permissionState == PermissionState.limited ||
        permissionState == PermissionState.authorized) {
      // 1) 앨범 목록 불러오기. 반환된 albums는 클래스 변수로 지정하여 어디서든 접근 가능
      albums = await PhotoManager.getAssetPathList(
        // 2) 이미지만 불러올지, 오디오만 불러올지, 영상만 불러올지
        type: RequestType.image,
        //type: RequestType.all,
        // 3) 필터옵션을 이용해서 특정 크기 이상의 이미지를 불러오게
        filterOption: FilterOptionGroup(
          imageOption: const FilterOption(
            needTitle: true,
            // sizeConstraint: SizeConstraint(
            //   minWidth: 800,
            //   minHeight: 800,
            // ),
            sizeConstraint: SizeConstraint(
              minWidth: 200,
              minHeight: 200,
            ),
          ),
          // 4) 정렬 순서를 createDate 기준의 최신순으로 보이도록
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );
    }
    // 앨범을 불러왔으므로 앨범의 사진목록을 불러오는 이벤트 호출
    _pagingPhotos();
  }

  Future<void> _pagingPhotos() async {
    // 앨범이 비어있지 않은 상태에서만 사진을 로드하도록
    if (albums.isNotEmpty) {
      // 앨범의 첫번째 데이터부터 불러오기 (60개씩)
      var photos = await albums.first.getAssetListPaged(
        page: currentPage,
        size: 60,
      );

      if (currentPage == 0) {
        imageList.clear();
      }

      // 마지막 페이지에 도달했을 때 추가 요청을 멈추도록 처리 필요.
      // 이미지를 로드한 결과가 빈 상태라면 마지막 페이지에 도달한 것으로 간주하고
      // setState를 진행하지 못하게 반환해주면 됨.
      // 이렇게 하면 currentPage와 lastPage 값이 같아지면서
      // _pagingPhotos 함수가 더 이상 호출되지 않음
      if (photos.isEmpty) {
        return;
      }

      // 불러온 사진을 imageList 변수에 저장. 화면 업데이트 위해 setState 함수 호출
      setState(() {
        //imageList = photos;
        // 불러온 이미지 목록을 addAll로 기존 목록에 추가
        // 이렇게 하면 스크롤을 아래로 내릴 때 새로운 이미지가 추가
        //imageList.addAll(photos);
        for (var element in photos) {
          imageList.add(AssetValueEntity(asset: element));
        }
        currentPage++;
      });
    }
  }

  // ---------------- 이미지 표시하기 -------------------

  // 화면에서 이미지가 선택되었는지 확인하기 위해
  bool containValue(AssetValueEntity value) {
    return selectedImages.where((element) => element.id == value.id).isNotEmpty;
  }

  // 선택된 이미지가 몇 번째인지 보여주기 위한 인덱스 반환 함수
  String returnIndexValue(AssetValueEntity value) {
    var find = selectedImages.asMap().entries.where((element) {
      return element.value.id == value.id;
    });
    if (find.isEmpty) return '';
    return (find.first.key + 1).toString();
  }

  // 개별 사진 표시하는 위젯
  Widget _photoWidget(AssetValueEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                top: 0,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      bottom: 0,
                      right: 0,
                      top: 0,
                      child: Container(
                        // 선택된 이미지에 흰색 반투명 막이 씌워지는 효과
                        color: Colors.white
                            .withOpacity(containValue(asset) ? 0.5 : 0),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          _selectedImage(asset);
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // 선택된 이미지의 우상단 색상을 지정하여 선택 여부 보여줌
                            color: containValue(asset)
                                ? const Color(0xFFED7738)
                                : Colors.white.withOpacity(0.5),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              // 현재 이미지가 몇번째인지 보여줌
                              returnIndexValue(asset),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  // 이미지 우상단 영역 선택하면 _selectedImage 함수로 asset 전달
  void _selectedImage(AssetValueEntity imageList) async {
    setState(() {
      if (containValue(imageList)) {
        selectedImages.remove(imageList);
      } else {
        if (10 > selectedImages.length) {
          selectedImages.add(imageList);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 아래는 별도 추가한 부분
        // leading 옵션으로 페이지 닫는 아이콘
        // 이벤트는 GetX의 Get.back을 사용하여 간단하게 처리
        leading: GestureDetector(
          onTap: Get.back,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset('assets/svg/icons/close.svg'),
          ),
        ),
        title: const AppFont(
          '최근 항목',
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if (selectedImages.isNotEmpty) {
                Get.back(result: selectedImages);
              }
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 20.0, right: 25.0),
              child: AppFont(
                '완료',
                color: Color(0xFFED7738),
                size: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              itemCount: imageList.length,
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                return _photoWidget(imageList[index]);
              },
            ),
          )
        ],
      ),
    );
  }
}
