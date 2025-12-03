// // 추후 구글날씨 API 받아올때 사용할 날씨파일
//
//
// // lib/weather_service.dart
//
// // 나중에 실제 HTTP API 쓸 때 사용할 import (지금은 주석)
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
//
// /// 날씨 정보를 담는 모델
// class WeatherData {
//   final String locationName;
//   final int temperature; // °C
//   final int humidity; // %
//   final String condition; // 예: "Cloudy"
//   final String iconEmoji; // 예: "☁️"
//
//   WeatherData({
//     required this.locationName,
//     required this.temperature,
//     required this.humidity,
//     required this.condition,
//     required this.iconEmoji,
//   });
// }
//
// /// 날씨 서비스
// class WeatherService {
//   /// 현재는 **Mock 데이터**만 반환.
//   /// 나중에 Google Weather API로 바꿀 예정.
//   Future<WeatherData> getCurrentWeather({
//     double? latitude,
//     double? longitude,
//   }) async {
//     // ⬇⬇⬇ 여기는 지금은 더미데이터, API 붙이기 전까지 그냥 사용
//     await Future.delayed(const Duration(milliseconds: 300));
//
//     return WeatherData(
//       locationName: 'Kuala Lumpur',
//       temperature: 32,
//       humidity: 80,
//       condition: 'Cloudy',
//       iconEmoji: '☁️',
//     );
//
//     // =======================================================
//     // 📝 TODO: 실제 Google / OpenWeather API 연동 시 여기를 수정
//     //
//     // 1) pubspec.yaml 에 http 패키지 추가
//     //
//     // dependencies:
//     //   http: ^1.1.0
//     //
//     // 2) 위쪽 import 주석 해제
//     //    import 'dart:convert';
//     //    import 'package:http/http.dart' as http;
//     //
//     // 3) 아래 코드로 교체 (예시: OpenWeather 기준)
//     //
//     // final lat = latitude ?? 기본위도;
//     // final lon = longitude ?? 기본경도;
//     //
//     // final url = Uri.parse(
//     //   'https://api.openweathermap.org/data/2.5/weather'
//     //   '?lat=$lat&lon=$lon&appid=YOUR_API_KEY&units=metric',
//     // );
//     //
//     // final res = await http.get(url);
//     // if (res.statusCode != 200) {
//     //   throw Exception('Weather API error: ${res.statusCode}');
//     // }
//     //
//     // final json = jsonDecode(res.body);
//     //
//     // final temp = (json['main']['temp'] as num).round();
//     // final humi = (json['main']['humidity'] as num).round();
//     // final main = json['weather'][0]['main'] as String;
//     // final cityName = json['name'] as String;
//     //
//     // return WeatherData(
//     //   locationName: cityName,
//     //   temperature: temp,
//     //   humidity: humi,
//     //   condition: main,
//     //   iconEmoji: _mapConditionToEmoji(main),
//     // );
//     // =======================================================
//   }
//
//   /// 날씨 상태를 이모지로 바꾸는 헬퍼 (API 붙일 때 같이 사용)
// //   String _mapConditionToEmoji(String condition) {
// //     final c = condition.toLowerCase();
// //     if (c.contains('rain')) return '🌧️';
// //     if (c.contains('cloud')) return '☁️';
// //     if (c.contains('sun') || c.contains('clear')) return '☀️';
// //     if (c.contains('snow')) return '❄️';
// //     return '🌡️';
// //   }
// // }
