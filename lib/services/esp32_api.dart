import 'package:http/http.dart' as http;

class Esp32Api {
  // ===== 1) 각 보드 IP =====
  static const String washerBaseUrl = 'http://192.168.219.179';  // 세탁기
  static const String fridgeBaseUrl = 'http://192.168.219.216';  // 냉장고
  static const String acBaseUrl     = 'http://192.168.219.139';  // 에어컨

  // ===== 1-1) 가전 전원 상태 (켜짐 여부) 기억 =====
  //  - true  : 해당 가전이 "켜져 있음"
  //  - false : 해당 가전이 "꺼져 있음"
  static bool _washerOn = false;
  static bool _fridgeOn = false;
  static bool _acOn = false;

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
  //    + 전원 상태 기억
  // =========================

  /// 세탁기 전원 ON
  static Future<void> washerPowerOn() async {
    _washerOn = true; // 🔥 전원 상태 ON
    await _setLcdAndLed(
      washerBaseUrl,
      text: 'Wash Contact',
      color: 'white',
    );
  }

  /// 세탁기 전원 OFF → Hello Regen
  static Future<void> washerPowerOff() async {
    _washerOn = false; // 🔥 전원 상태 OFF
    await _setLcdAndLed(
      washerBaseUrl,
      text: 'Hello Regen',
      color: 'off',
    );
  }

  /// 냉장고 전원 ON
  static Future<void> fridgePowerOn() async {
    _fridgeOn = true; // 🔥 전원 상태 ON
    await _setLcdAndLed(
      fridgeBaseUrl,
      text: 'Fridge Contact',
      color: 'white',
    );
  }

  /// 냉장고 전원 OFF → Hello Regen
  static Future<void> fridgePowerOff() async {
    _fridgeOn = false; // 🔥 전원 상태 OFF
    await _setLcdAndLed(
      fridgeBaseUrl,
      text: 'Hello Regen',
      color: 'off',
    );
  }

  /// 에어컨 전원 ON
  static Future<void> acPowerOn() async {
    _acOn = true; // 🔥 전원 상태 ON
    await _setLcdAndLed(
      acBaseUrl,
      text: 'Aircon Contact',
      color: 'white',
    );
  }

  /// 에어컨 전원 OFF → Hello Regen
  static Future<void> acPowerOff() async {
    _acOn = false; // 🔥 전원 상태 OFF
    await _setLcdAndLed(
      acBaseUrl,
      text: 'Hello Regen',
      color: 'off',
    );
  }

  // =========================
  // 5) Prayer Schedule 모드 (Quiet / Ramadan ON)
  // =========================

  /// 🟢 Quiet Home Mode – 세 가전 모두 동일
  /// LCD: "Quiet Home Mode Run", LED: green
  static Future<void> showQuietHomeModeAll() async {
    await Future.wait([
      _setLcdAndLed(
        washerBaseUrl,
        text: 'Quiet Home Mode Run',
        color: 'green',
      ),
      _setLcdAndLed(
        fridgeBaseUrl,
        text: 'Quiet Home Mode Run',
        color: 'green',
      ),
      _setLcdAndLed(
        acBaseUrl,
        text: 'Quiet Home Mode Run',
        color: 'green',
      ),
    ]);
  }

  /// 🟡 Ramadan Mode – 세 가전 모두 동일
  /// LCD: "Ramadan Mode Run", LED: yellow
  static Future<void> showRamadanModeAll() async {
    await Future.wait([
      _setLcdAndLed(
        washerBaseUrl,
        text: 'Ramadan Mode Run',
        color: 'yellow',
      ),
      _setLcdAndLed(
        fridgeBaseUrl,
        text: 'Ramadan Mode Run',
        color: 'yellow',
      ),
      _setLcdAndLed(
        acBaseUrl,
        text: 'Ramadan Mode Run',
        color: 'yellow',
      ),
    ]);
  }

  // =========================
  // 6) Quiet / Ramadan 모드 OFF 시 기본 상태로 복귀
  //
  //    🔹 새 동작 규칙:
  //      - 해당 가전이 "켜져 있으면"  → Contact 문구
  //      - 해당 가전이 "꺼져 있으면"  → Hello Regen
  //
  //    🔹 connected 파라미터는
  //      - "보드 자체가 연결되어 있냐/말았냐" 를 표현하는 용도로 남겨두고,
  //      - 최종적으로는 (connected && *_On)이 true일 때만 Contact를 보여주도록 함.
  // =========================

  static Future<void> _restoreWasher({required bool connected}) async {
    final bool isOn = connected && _washerOn;
    if (isOn) {
      await _setLcdAndLed(
        washerBaseUrl,
        text: 'Wash Contact',
        color: 'white',
      );
    } else {
      await _setLcdAndLed(
        washerBaseUrl,
        text: 'Hello Regen',
        color: 'off',
      );
    }
  }

  static Future<void> _restoreFridge({required bool connected}) async {
    final bool isOn = connected && _fridgeOn;
    if (isOn) {
      await _setLcdAndLed(
        fridgeBaseUrl,
        text: 'Fridge Contact',
        color: 'white',
      );
    } else {
      await _setLcdAndLed(
        fridgeBaseUrl,
        text: 'Hello Regen',
        color: 'off',
      );
    }
  }

  static Future<void> _restoreAc({required bool connected}) async {
    final bool isOn = connected && _acOn;
    if (isOn) {
      await _setLcdAndLed(
        acBaseUrl,
        text: 'Aircon Contact',
        color: 'white',
      );
    } else {
      await _setLcdAndLed(
        acBaseUrl,
        text: 'Hello Regen',
        color: 'off',
      );
    }
  }

  /// Quiet Home Mode OFF → 기본 상태로 복귀
  ///  - 기본값(true/true/true)은 기존 코드와 호환용으로 유지
  ///  - 실제 동작은 내부 상태(_washerOn 등)를 보고 결정
  static Future<void> clearQuietHomeModeAll({
    bool washerConnected = true,
    bool fridgeConnected = true,
    bool acConnected = true,
  }) async {
    await Future.wait([
      _restoreWasher(connected: washerConnected),
      _restoreFridge(connected: fridgeConnected),
      _restoreAc(connected: acConnected),
    ]);
  }

  /// Ramadan Mode OFF → Quiet OFF와 동일하게 기본 상태로 복귀
  static Future<void> clearRamadanModeAll({
    bool washerConnected = true,
    bool fridgeConnected = true,
    bool acConnected = true,
  }) async {
    await clearQuietHomeModeAll(
      washerConnected: washerConnected,
      fridgeConnected: fridgeConnected,
      acConnected: acConnected,
    );
  }

  // =========================
  // 7) 개별 기능 (기존 기능 유지)
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
