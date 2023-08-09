import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


class HomeScreen extends StatelessWidget {
  //지도위치 초기화
  static final LatLng companyLatLng = LatLng(
      37.5233273, // 위도
      126.921252 // 경도
  );
// 회사 위치 마커 선언
  static final Marker marker = Marker(
    markerId: MarkerId('company'),
    position: companyLatLng,
  );
  static final Circle circle = Circle(
      circleId: CircleId('choolCheckCircle'),
      center: companyLatLng, // 원의 중심이 되는 위치, LatLng값을 제공합니다.
      fillColor: Colors.blue.withOpacity(0.5), //원의 색상
      radius: 100, // 원의 반지름(미터 단위)
      strokeColor: Colors.blue, // 원의 테두리 색
      strokeWidth: 1, // 원의 테두리 두께
  );

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(),
      body: FutureBuilder<String>(
        future: checkPermission(),
        builder: (context, snapshot){
          //로딩 상태
          if(!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          //권한 허가된 상태
          if(snapshot.data == '위치 권한이 허가 되었습니다.'){
            return Column(
              children: [
                Expanded( // 2/3만큼 공간 차지
                  flex: 2,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                        target: companyLatLng,
                        zoom: 16
                    ),
                    myLocationEnabled: true, // 내 위치 지도에 보여주기
                    markers: Set.from([marker]), //Set로 Maker 제공
                    circles: Set.from([circle]), //Set로 Circle 제공
                  ),
                ),
                Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon( // 시계 아이콘
                          Icons.timelapse_outlined,
                          color: Colors.blue,
                          size: 50.0,
                        ),
                        const SizedBox(height: 20.0),
                        ElevatedButton( //[출근하기 버튼]
                          onPressed: () async {
                            final curPosition = await Geolocator.getCurrentPosition(); // 현재 위치
                            final distance = Geolocator.distanceBetween(
                                curPosition.latitude, // 현재 위치 위도 
                                curPosition.longitude, // 현재 위치 경도 
                                companyLatLng.latitude, //회사 위치 위도
                                companyLatLng.longitude,  //회사 위치 경도
                            );
                            bool canCheck =
                                distance < 100; //100미터 이내에 있으면 출근 가능
                            showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    title: Text('출근하기'),
                                    //출근 가능 여부에 따라 다른 메시지 제공
                                    content: Text(
                                      canCheck ? '출근을 하시곘습니까?' : '출근할 수 없는 위치 입니다.',
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text('취소'),
                                      ),
                                      if(canCheck) // 출근 가능한 상태일 때만 [출근하기] 버튼 제공
                                        TextButton(
                                          // 출근하기를 누르면 true반환
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: Text('출근하기'),
                                        ),
                                    ],

                                  );
                                },
                            );
                            
                          },
                          child: Text('출근하기'),
                        ),
                      ],
                    )
                ),
              ],
            );
          }
          //권한 없는 상태
          return Center(
            child: Text(
              snapshot.data.toString(),
            ),
          );

        },
      )
    );

  }

  AppBar renderAppBar() {
    //AppBar를 구현하는 함수
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.white,
      title: Text(
        '오늘도 출첵',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),


    );
  }
  //renderAppBar() 함수 아래에 입력하기
  Future<String> checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    //위치 서비스 활성화 여부 확인
    if(!isLocationEnabled) {  // 위치 서비스 활성화 안 됨
      return '위치 서비스를 활성화해주세요.';
    }

    // 위치 권한확인
    LocationPermission checkedPermission = await Geolocator.checkPermission();

    if (checkedPermission == LocationPermission.denied) { // 위치 권한 거절됨
      //위치 권한 요청하기
      checkedPermission = await Geolocator.requestPermission();

      if(checkedPermission == LocationPermission.denied) {
        return '위치 권한을 설정에서 허가해주세요.';
      }
    }

// 위 모든 조건이 통과되면 위치 권한 허가 완료
    return '위치 권한이 허가 되었습니다.';


  }
}

