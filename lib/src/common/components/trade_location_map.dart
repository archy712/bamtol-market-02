import 'package:bamtol_market_02/src/common/components/app_font.dart';
import 'package:bamtol_market_02/src/common/components/btn.dart';
import 'package:bamtol_market_02/src/common/components/place_name_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class TradeLocationMap extends StatefulWidget {
  final String? label;
  final LatLng? location;

  const TradeLocationMap({
    super.key,
    this.label,
    this.location,
  });

  @override
  State<TradeLocationMap> createState() => _TradeLocationMapState();
}

class _TradeLocationMapState extends State<TradeLocationMap> {
  final _mapController = MapController();
  String label = '';
  LatLng? location;

  @override
  void initState() {
    super.initState();
    label = widget.label ?? '';
    location = widget.location;
  }

  // 사용자로부터 위치 권한을 요청하고, 권한을 허용받을 때까지 기다림
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 비활성화 되었습니다');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되어 권한을 요청할 수 없습니다.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212133),
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: Get.back,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset('assets/svg/icons/back.svg'),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFont(
                  '이웃과 만나서\n거래하고 싶은 장소를 선택해 주세요.',
                  size: 16,
                ),
                SizedBox(height: 15),
                AppFont(
                  '만나서 거래할 때는 누구나 찾기 쉬운 공공장소가 좋아요',
                  size: 13,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Position>(
              future: _determinePosition(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // 위치 권한이 허용되면 snapshot에서 위치정보를 가져와 myLocation에 저장
                  var myLocation =
                      LatLng(snapshot.data!.latitude, snapshot.data!.longitude);
                  // 원래는 내 위치를 기준으로 지도의 중심(center)을 설정하는데,
                  // 만약에 지정된 위치 정보(location)가 있다면 그 위치로 중심을 변경
                  if (location != null) {
                    myLocation = location!;
                  }
                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                        // myLocation 변수에 담긴 위치 정보를 FlutterMap 위젯의 중심(center)에 넣어줌
                        // 이렇게 하면 지도가 내 위치를 중심으로 로드됨
                        center: myLocation,
                        // 지도를 조작할 수 있는 기능인 드래그(drag)와 핀치 줌(pinchZoom)을 설정
                        interactiveFlags:
                            InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                        onPositionChanged: (position, hasGesture) {
                          if (hasGesture) {
                            setState(() {
                              label = '';
                            });
                          }
                        }),
                    nonRotatedChildren: [
                      // 지도위에 고정적인 위젯을 배치할 수 있는 옵션
                      // 이를 통해 지도 위에 버튼이나 필요한 디자인 요소를 쉽게 추가 가능
                      if (label != '')
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color:
                                      const Color.fromARGB(255, 208, 208, 208),
                                ),
                                child: AppFont(
                                  label,
                                  color: Colors.black,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      Center(
                        child: SvgPicture.asset(
                          'assets/svg/icons/want_location_marker.svg',
                          width: 45,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: Get.mediaQuery.padding.bottom,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Btn(
                                onTap: () async {
                                  var result = await Get.dialog<String>(
                                    useSafeArea: false,
                                    const PlaceNamePopup(),
                                  );
                                  Get.back(result: {
                                    'label': result,
                                    'location': _mapController.center,
                                  });
                                },
                                child: const AppFont(
                                  '선택 완료',
                                  align: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    children: [
                      // TileLayer는 OpenStreetMap을 사용
                      // flutter_map의 장점은 다른 타일 레이어 서비스도 사용 가능
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      ),
                    ],
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: Get.mediaQuery.padding.bottom + 30),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF212133),
          child: const Icon(Icons.location_searching),
        ),
      ),
    );
  }
}

// 경량화된 지도를 표현하기 위한 위젯
class SimpleTradeLocationMap extends StatelessWidget {
  final String? label;
  final LatLng myLocation;
  final int interactiveFlags;

  const SimpleTradeLocationMap({
    super.key,
    required this.myLocation,
    this.label,
    this.interactiveFlags = InteractiveFlag.pinchZoom | InteractiveFlag.drag,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: myLocation,
        interactiveFlags: interactiveFlags,
      ),
      nonRotatedChildren: [
        if (label != '')
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: const Color.fromARGB(255, 208, 208, 208),
                  ),
                  child: AppFont(
                    label!,
                    color: Colors.black,
                    size: 12,
                  ),
                ),
                const SizedBox(height: 100)
              ],
            ),
          ),
        Center(
          child: SvgPicture.asset(
            'assets/svg/icons/want_location_marker.svg',
            width: 45,
          ),
        ),
      ],
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
      ],
    );
  }
}
