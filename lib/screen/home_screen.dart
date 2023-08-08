import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


class HomeScreen extends StatelessWidget {
  //지도위치 초기화
  static final LatLng companyLatLng = LatLng(
      37.5233273, // 위도
      126.921252 // 경도
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
                          onPressed: () {},
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

