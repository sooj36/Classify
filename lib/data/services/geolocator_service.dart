import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
class GeolocatorService {

 //자동 위치 업데이트를 위한 위치 스트림 반환
  Stream<Position> watchLocation() async*{
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('위치 권한 확인: $permission');
      if (permission == LocationPermission.denied) {
        // 2. 권한 요청 시간 측정
        final permRequestStart = DateTime.now();
        debugPrint('권한 요청 시작: ${DateTime.now()}');
        permission = await Geolocator.requestPermission();
        debugPrint('권한 요청 완료: ${DateTime.now().difference(permRequestStart)}');
        
        if (permission == LocationPermission.denied) {
          debugPrint('위치 권한이 거부되었습니다');
        }
      }    
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
      distanceFilter: 500, // 500m 마다 업데이트
      ),
  );
}

//수동 위치 업데이트를 위한 위치 반환
Future<Position> getCurrentLocation() async {
  return await Geolocator.getCurrentPosition();
}
}