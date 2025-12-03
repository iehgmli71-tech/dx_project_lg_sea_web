import 'package:http/http.dart' as http;

class Esp32Api {
  // ===== 1) 각 보드 IP =====
  static const String washerBaseUrl = 'http://192.168.219.125';  // 세탁기
  static const String fridgeBaseUrl = 'http://192.168.0.51';     // 냉장고
  static const String acBaseUrl     = 'http://192.168.0.52';     // 에어컨

  // ===== 2) 공통 헬퍼 함수 =====
  static Future<void> _setLcd(String baseUrl, String text) async {
    final encoded = Uri.encodeQueryComponent(text);
    await http.get(Uri.parse('$baseUrl/lcd?text=$encoded'));
  }

  static Future<void> _setLed(String baseUrl, String color) async {
    final encoded = Uri.encodeQueryComponent(color);
    await http.get(Uri.parse('$baseUrl/led?color=$encoded'));
  }

  static Future<void> _setLcdAndLed(
      String baseUrl, {
        required String text,
        required String color,
      }) async {
    await Future.wait([
      _setLcd(baseUrl, text),
      _setLed(baseUrl, color),
    ]);
  }

  // =========================
  // 3) Hello ThinQ / Hello Regen
  // =========================

  /// 앱을 켰을 때: "Hello ThinQ" + LED OFF
  static Future<void> showHelloThinqAll() async {
    await Future.wait([
      _setLcd(washerBaseUrl, 'Hello ThinQ'),
      _setLcd(fridgeBaseUrl, 'Hello ThinQ'),
      _setLcd(acBaseUrl, 'Hello ThinQ'),
      _setLed(washerBaseUrl, 'off'),
      _setLed(fridgeBaseUrl, 'off'),
      _setLed(acBaseUrl, 'off'),
    ]);
  }

  /// LG Regen 페이지 진입: "Hello Regen" + LED OFF
  static Future<void> showHelloRegenAll() async {
    await Future.wait([
      _setLcd(washerBaseUrl, 'Hello Regen'),
      _setLcd(fridgeBaseUrl, 'Hello Regen'),
      _setLcd(acBaseUrl, 'Hello Regen'),
      _setLed(washerBaseUrl, 'off'),
      _setLed(fridgeBaseUrl, 'off'),
      _setLed(acBaseUrl, 'off'),
    ]);
  }

  // =========================
  // 4) 각 가전 전원 ON → Contact + 흰색 LED
  // =========================

  /// 세탁기 전원 ON
  static Future<void> washerPowerOn() async {
    await _setLcdAndLed(
      washerBaseUrl,
      text: 'Wash Contact',   // ✅ 요구사항대로 변경
      color: 'white',
    );
  }

  /// 냉장고 전원 ON
  static Future<void> fridgePowerOn() async {
    await _setLcdAndLed(
      fridgeBaseUrl,
      text: 'Fridge Contact', // ✅ 요구사항
      color: 'white',
    );
  }

  /// 에어컨 전원 ON
  static Future<void> acPowerOn() async {
    await _setLcdAndLed(
      acBaseUrl,
      text: 'AC Contact',     // ✅ 요구사항
      color: 'white',
    );
  }

  // =========================
  // 5) Prayer Schedule 모드
  // =========================

  /// Quiet Home Mode – 세 가전 모두 동일
  static Future<void> showQuietHomeModeAll() async {
    await Future.wait([
      _setLcdAndLed(
        washerBaseUrl,
        text: 'Quiet Home Mode Running',
        color: 'green',
      ),
      _setLcdAndLed(
        fridgeBaseUrl,
        text: 'Quiet Home Mode Running',
        color: 'green',
      ),
      _setLcdAndLed(
        acBaseUrl,
        text: 'Quiet Home Mode Running',
        color: 'green',
      ),
    ]);
  }

  /// Ramadan Mode – 세 가전 모두 동일
  static Future<void> showRamadanModeAll() async {
    await Future.wait([
      _setLcdAndLed(
        washerBaseUrl,
        text: 'Ramadan Mode Running',
        color: 'yellow',
      ),
      _setLcdAndLed(
        fridgeBaseUrl,
        text: 'Ramadan Mode Running',
        color: 'yellow',
      ),
      _setLcdAndLed(
        acBaseUrl,
        text: 'Ramadan Mode Running',
        color: 'yellow',
      ),
    ]);
  }

  // =========================
  // 6) 개별 기능 (필요 시 그대로 사용)
  // =========================

  static Future<void> showWasherTaharaRinse() async {
    await _setLcdAndLed(
      washerBaseUrl,
      text: 'Tahara Rinse Running',
      color: 'blue',
    );
  }

  static Future<void> showFridgeBoostMode() async {
    await _setLcdAndLed(
      fridgeBaseUrl,
      text: 'Boost Mode Running',
      color: 'blue',
    );
  }

  static Future<void> showAcWudhuMode() async {
    await _setLcdAndLed(
      acBaseUrl,
      text: 'Wudhu Mode Running',
      color: 'blue',
    );
  }
}
