// power_management.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/postpaid_models.dart'; // 방금 만든 모델

import 'dart:async'; // Timer 사용
import 'package:dx_projecet_lg_sea/services/power_usage_manager.dart';

class PowerManagement extends StatefulWidget {
  final int userId;

  const PowerManagement({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<PowerManagement> createState() => _PowerManagementState();
}

enum PaymentType { prepaid, postpaid }

class _PowerManagementState extends State<PowerManagement> {
  PaymentType paymentType = PaymentType.prepaid;

  bool _isSavingPrepaid = false; // 선불 저장 중인지 표시용

  bool showAddTokenPopup = false;
  String addTokenMeterBrand = '';
  String addTokenInput = '';
  double addTotalTokens = 0;
  final List<double> addTokenHistory = [];

  double savedTotalToken = 0;
  double savedUsedToken = 0; // 아직 사용량 로직 없으니 0으로 유지

  final TextEditingController _tokenInputController =
  TextEditingController();

  PostpaidDashboard? _postpaidDashboard; // 백엔드에서 받은 후불 대시보드 데이터
  bool _isLoadingPostpaid = false;       // 로딩 중 여부
  String? _postpaidError;                // 에러 메시지(있으면)

  Timer? _timer; // 타이머 추가

  void _startUsageTimer() {
    // 혹시 이전에 타이머가 돌아가고 있었다면 정리
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        PowerUsageManager.instance.tick();  // ✅ 30초마다 today/month kWh 누적
      });
    });
  }

  @override
  void initState() {
    super.initState();

    // 🔹 유저별(로그인한 userId 기준) 사용량 복구
    PowerUsageManager.instance.init(widget.userId).then((_) {
      if (mounted) {
        setState(() {});  // 복구된 today/month kWh를 화면에 반영
      }
    });

    // 🔹 선불/후불 대시보드 가져오기
    _loadPrepaidDashboard();
    _loadPostpaidDashboard();

    // 🔹 30초마다 tick() + setState (이 안에서 Timer.periodic 돌도록 구현)
    _startUsageTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tokenInputController.dispose();
    super.dispose();
  }

  Future<void> _loadPrepaidDashboard() async {
    final userId = widget.userId;
    final uri = Uri.parse(
      'http://10.0.2.2:8082/api/users/$userId/prepaid-dashboard',
    );

    try {
      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        setState(() {
          savedTotalToken =
              (data['totalTokenKwh'] as num?)?.toDouble() ?? 0.0;
          savedUsedToken =
              (data['usedTokenKwh'] as num?)?.toDouble() ?? 0.0;
        });
      } else {
        // 에러는 로그만 찍고, UI는 그냥 0 토큰 카드 유지
        print(
            'prepaid-dashboard API error: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      print('prepaid-dashboard network error: $e');
    }
  }

  Future<void> _loadPostpaidDashboard() async {
    setState(() {
      _isLoadingPostpaid = true;
      _postpaidError = null;
    });

    final userId = widget.userId; // TODO: 로그인 연동되면 실제 유저 id로 교체

    // 안드로이드 에뮬레이터면 10.0.2.2, iOS 시뮬레이터면 localhost
    final uri = Uri.parse(
      'http://10.0.2.2:8082/api/users/$userId/postpaid-dashboard',
    );

    try {
      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(resp.body);
        setState(() {
          _postpaidDashboard = PostpaidDashboard.fromJson(data);
        });
      } else {
        setState(() {
          _postpaidError = 'API 오류: ${resp.statusCode}';
        });
        print('API error: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      setState(() {
        _postpaidError = '네트워크 오류: $e';
      });
      print('API call failed: $e');
    } finally {
      setState(() {
        _isLoadingPostpaid = false;
      });
    }
  }


  Future<void> _handleCalculateAddToken() async {
    // 기본 검증: 브랜드 선택 + 토큰이 0보다 커야 함
    if (addTokenMeterBrand.isEmpty || addTotalTokens <= 0) return;

    setState(() {
      _isSavingPrepaid = true;
    });

    final userId = widget.userId; // TODO: 나중에 로그인 연동 후 실제 userId로 교체
    final uri = Uri.parse(
      'http://10.0.2.2:8082/api/users/$userId/prepaid-topup',
    );

    final body = json.encode({
      'brand': addTokenMeterBrand,   // "Itron", "Hexing", "Actaris"
      'amountKwh': addTotalTokens,   // 누적 입력한 토큰 값 (예: 5000)
    });

    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;

        final double newTotal =
        (data['totalTokenKwh'] as num).toDouble();
        final double newUsed =
        (data['usedTokenKwh'] as num).toDouble();

        setState(() {
          // 서버에서 받은 최신 값으로 게이지 갱신
          savedTotalToken = newTotal;
          savedUsedToken = newUsed;

          // 팝업 내부 상태 초기화
          showAddTokenPopup = false;
          addTokenMeterBrand = '';
          addTokenInput = '';
          _tokenInputController.clear();
          addTotalTokens = 0;
          addTokenHistory.clear();
        });
      } else {
        // API 에러
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('토큰 저장 실패: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      // 네트워크 에러
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    } finally {
      setState(() {
        _isSavingPrepaid = false;
      });
    }
  }

  void _handleAddTokenForAddTokenPopup() {
    if (addTokenInput.isNotEmpty) {
      final value = double.tryParse(addTokenInput);
      if (value != null && value > 0) {
        setState(() {
          addTokenHistory.add(value);
          addTotalTokens += value;
          addTokenInput = '';
          _tokenInputController.clear();
        });
      }
    }
  }

  void _handleResetAddTokens() {
    setState(() {
      addTokenHistory.clear();
      addTotalTokens = 0;
      addTokenInput = '';
      _tokenInputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 전력 사용량 매니저에서 값 읽기
    final mgr   = PowerUsageManager.instance;
    final today = mgr.todayKwh;               // 오늘 사용량 (kWh)
    final month = mgr.monthKwh;               // 이번달 사용량 (kWh)

    // 이번 달 사용량을 선불 모드의 "사용 토큰"으로 사용
    final double usedThisMonth = month;

    // 잔여 토큰 = 총 토큰 - 이번 달 사용량
    final double remainingToken =
    (savedTotalToken - usedThisMonth).clamp(0, double.infinity);

    // 인도네시아 하루 평균 29kWh 기준 예상일수 (소수점 버림)
    const double dailyAverageKwh = 29.0;
    final int expectedDays = remainingToken <= 0
        ? 0
        : (remainingToken / dailyAverageKwh).floor();

    // 후불용: 이번 달 예상 요금
    final bill  = mgr.estimatedMonthlyBillIdr;
    final effectiveBill = _postpaidDashboard?.expectedAmount ?? bill;

    // 후불 청구서 리스트
    final bills = _postpaidDashboard?.bills ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: Image.asset(
                                        'images/Lg_logo.png', // TODO: 실제 경로로 변경
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Regen',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  '전력 관리',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              '전력 관리 방식',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _PaymentTypeButton(
                                    label: '선불',
                                    icon: Icons.bolt,
                                    selected:
                                    paymentType == PaymentType.prepaid,
                                    onTap: () {
                                      setState(() {
                                        paymentType = PaymentType.prepaid;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _PaymentTypeButton(
                                    label: '후불',
                                    icon: Icons.access_time,
                                    selected:
                                    paymentType == PaymentType.postpaid,
                                    onTap: () {
                                      setState(() {
                                        paymentType = PaymentType.postpaid;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Body
                      if (paymentType == PaymentType.prepaid)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              // Gauge or Add token CTA
                              if (savedTotalToken > 0)
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 200,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CustomPaint(
                                              size: const Size(double.infinity, 200),
                                              painter: _TokenGaugePainter(
                                                total: savedTotalToken,
                                                used: usedThisMonth, // 이번 달 사용량 기준으로 게이지 감소
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 16,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        remainingToken.toStringAsFixed(2), // 소수점 둘째 자리까지
                                                        style: const TextStyle(
                                                          fontSize: 28,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      const Text(
                                                        'kWh',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black87,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  const Text(
                                                    '잔여 토큰',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _TokenInfoItem(
                                              label: '총 토큰',
                                              value:
                                              '${savedTotalToken.toStringAsFixed(2)} kWh',
                                            ),
                                          ),
                                          Expanded(
                                            child: _TokenInfoItem(
                                              label: '사용 토큰',
                                              // 🔹 이번 달 사용량을 사용 토큰으로 표시, 소수점 2자리
                                              value: '${usedThisMonth.toStringAsFixed(2)} kWh',
                                            ),
                                          ),
                                          Expanded(
                                            child: _TokenInfoItem(
                                              label: '예상 기간',
                                              value: '$expectedDays 일',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            const Color(0xFF22C55E),
                                            foregroundColor: Colors.white,
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(22),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              showAddTokenPopup = true;
                                            });
                                          },
                                          child: const Text(
                                            '+ 토큰 추가하기',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFEFFDF4),
                                        Color(0xFFE0FFE8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFBBF7D0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xFF22C55E),
                                        foregroundColor: Colors.white,
                                        elevation: 6,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(22),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 32, vertical: 14),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          showAddTokenPopup = true;
                                        });
                                      },
                                      child: const Text(
                                        '+ 토큰 추가하기',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              // Token Dashboard
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.bolt,
                                        size: 20, color: Colors.blue),
                                    const SizedBox(width: 6),
                                    const Text(
                                      '토큰 대시보드',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SmallStatCard(
                                      icon: Icons.trending_down,
                                      label: '오늘 사용량',
                                      value: today.toStringAsFixed(2),   // 매니저 값
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _SmallStatCard(
                                      icon: Icons.bolt,
                                      label: '이번 달 사용량',
                                      value: month.toStringAsFixed(2),   // 매니저 값
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Power report (disabled)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: null, // disabled 상태
                                  style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor:
                                    const Color(0xFF22C55E),
                                    disabledForegroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    '전력 레포트',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                      // POSTPAID UI
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF22C55E),
                                      Color(0xFF16A34A),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '이번 달 예상 요금',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Icon(Icons.access_time,
                                            color: Colors.white, size: 20),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    // 예상 요금: 서버 데이터 적용

                                    Text(
                                      'Rp ${effectiveBill.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // 결제일: 서버 데이터 적용
                                    Text(
                                      _postpaidDashboard?.dueDate == null
                                          ? '결제일 정보 없음'
                                          : '결제일: ${_postpaidDashboard!.dueDate}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SmallStatCard(
                                      icon: Icons.trending_down,
                                      label: '오늘 사용량',
                                      value: _postpaidDashboard == null
                                          ? today.toStringAsFixed(2)
                                          : _postpaidDashboard!.todayUsageKwh.toStringAsFixed(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _SmallStatCard(
                                      icon: Icons.bolt,
                                      label: '이번 달 사용량',
                                      value: _postpaidDashboard == null
                                          ? month.toStringAsFixed(2)
                                          : _postpaidDashboard!.monthUsageKwh.toStringAsFixed(2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  '청구 내역',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              if (_isLoadingPostpaid) ...[
                                const Center(child: CircularProgressIndicator()),
                              ] else if (_postpaidError != null) ...[
                                Text(
                                  _postpaidError!,
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ] else if (bills.isEmpty) ...[
                                const Text(
                                  '청구 내역이 없습니다.',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ] else ...[
                                Column(
                                  children: [
                                    for (final b in bills) ...[
                                      _BillingItem(
                                        month: '${b.year}년 ${b.month}월',
                                        amount: 'Rp ${b.amount.toStringAsFixed(0)}',
                                        status: b.status == 'PAID' ? '완납' : '미납',
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Add Token Popup (full-screen overlay)
          if (showAddTokenPopup)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.95),
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '토큰 추가',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    showAddTokenPopup = false;
                                    addTokenMeterBrand = '';
                                    addTokenInput = '';
                                    _tokenInputController.clear();
                                    addTotalTokens = 0;
                                    addTokenHistory.clear();
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Meter brand
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.battery_charging_full, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  '계량기 브랜드 선택',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              for (final brand in ['Itron', 'Hexing', 'Actaris'])
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          addTokenMeterBrand = brand;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(22),
                                          border: Border.all(
                                            color: addTokenMeterBrand == brand
                                                ? const Color(0xFF22C55E)
                                                : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          color: addTokenMeterBrand == brand
                                              ? const Color(0xFF22C55E)
                                              : Colors.white,
                                          boxShadow: addTokenMeterBrand ==
                                              brand
                                              ? [
                                            BoxShadow(
                                              color: Colors
                                                  .green.shade200
                                                  .withOpacity(0.5),
                                              blurRadius: 8,
                                              offset:
                                              const Offset(0, 4),
                                            )
                                          ]
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          brand,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color:
                                            addTokenMeterBrand == brand
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Token input
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.bolt, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  '구입 토큰 입력 (kWh)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _tokenInputController,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '예: 500',
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      addTokenInput = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: (double.tryParse(addTokenInput) ??
                                    0) >
                                    0
                                    ? _handleAddTokenForAddTokenPopup
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                  disabledBackgroundColor:
                                  Colors.grey.shade300,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: const Text(
                                  '추가',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (addTotalTokens > 0)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFEFFDF4),
                                    Color(0xFFE0FFE8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: const Color(0xFFBBF7D0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '누적 토큰',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _handleResetAddTokens,
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          '초기화',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        addTotalTokens.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'kWh',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (addTokenHistory.isNotEmpty) ...[
                                    const Text(
                                      '입력 내역:',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 60,
                                      child: ListView.builder(
                                        itemCount: addTokenHistory.length,
                                        itemBuilder: (context, index) {
                                          final v = addTokenHistory[index];
                                          return Row(
                                            children: [
                                              Container(
                                                width: 18,
                                                height: 18,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFF22C55E),
                                                ),
                                                alignment: Alignment.center,
                                                margin:
                                                const EdgeInsets.only(
                                                    right: 6, bottom: 2),
                                                child: Text(
                                                  '${index + 1}',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '$v kWh',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                  onPressed: (addTokenMeterBrand.isNotEmpty &&
                                      addTotalTokens > 0 &&
                                      !_isSavingPrepaid)
                                      ? () {
                                    _handleCalculateAddToken(); // async지만 그냥 호출하면 됨
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    disabledBackgroundColor: Colors.grey.shade300,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    elevation: 6,
                                  ),
                                  child: _isSavingPrepaid
                                      ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                      : const Text(
                                    '설정 완료 및 저장',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                )
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTypeButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF22C55E) : const Color(0xFFF3F4F6);
    final fg = selected ? Colors.white : Colors.grey.shade800;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.green.shade200.withOpacity(0.6),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: fg,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _TokenInfoItem({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SmallStatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'kWh',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillingItem extends StatelessWidget {
  final String month;
  final String amount;
  final String status;

  const _BillingItem({
    Key? key,
    required this.month,
    required this.amount,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                month,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// 반원 게이지용 커스텀 페인터
class _TokenGaugePainter extends CustomPainter {
  final double total;
  final double used;

  _TokenGaugePainter({required this.total, required this.used});

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height * 0.9);
    final radius = math.min(size.width / 2 * 0.8, size.height * 0.8);

    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    const startAngle = math.pi; // 180도
    const sweepAngle = math.pi;

    // 전체 배경 반원
    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);

    final remaining = (total - used).clamp(0, total);
    final ratio = remaining / total;
    final remainingSweep = sweepAngle * ratio;

    // 남은 토큰 부분
    canvas.drawArc(rect, startAngle, remainingSweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _TokenGaugePainter oldDelegate) {
    return total != oldDelegate.total || used != oldDelegate.used;
  }
}
