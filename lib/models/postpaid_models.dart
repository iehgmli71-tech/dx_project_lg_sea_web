// lib/models/postpaid_models.dart

/// 개별 청구서(월별 요금 내역)를 표현하는 모델
class BillSummary {
  final int billId;      // 청구서 PK (백엔드 BillEntity.id)
  final int year;        // 청구 연도 (예: 2024)
  final int month;       // 청구 월 (예: 8, 9, 10)
  final double amount;   // 청구 금액
  final String status;   // 청구 상태 (PAID / UNPAID)

  BillSummary({
    required this.billId,
    required this.year,
    required this.month,
    required this.amount,
    required this.status,
  });

  /// 백엔드에서 넘어온 JSON(Map)을 BillSummary 객체로 변환
  factory BillSummary.fromJson(Map<String, dynamic> json) {
    return BillSummary(
      billId: json['billId'] as int,
      year: json['year'] as int,
      month: json['month'] as int,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
}

/// 후불(Postpaid) 대시보드 전체 정보를 담는 모델
/// - 상단 카드(예상 요금, 결제일, 오늘/이번달 사용량)
/// - 아래 청구 내역 리스트까지 한 번에 담는다.
class PostpaidDashboard {
  final double todayUsageKwh;    // 오늘 사용량 (kWh)
  final double monthUsageKwh;    // 이번 달 사용량 (kWh)
  final double expectedAmount;   // 이번 달 예상 요금
  final String? dueDate;         // 결제일 ("2024-11-05" 같은 문자열, 없으면 null 가능)
  final List<BillSummary> bills; // 최근 청구 내역 리스트

  PostpaidDashboard({
    required this.todayUsageKwh,
    required this.monthUsageKwh,
    required this.expectedAmount,
    required this.dueDate,
    required this.bills,
  });

  /// JSON -> PostpaidDashboard
  /// 백엔드에서 내려온 전체 JSON을 받아서
  /// - 숫자 필드는 double로 캐스팅
  /// - bills 배열은 List<BillSummary>로 변환
  factory PostpaidDashboard.fromJson(Map<String, dynamic> json) {
    // json['bills']가 null일 수도 있으니, 없으면 빈 리스트로 처리
    final billsJson = json['bills'] as List<dynamic>? ?? [];

    return PostpaidDashboard(
      todayUsageKwh: (json['todayUsageKwh'] as num).toDouble(),
      monthUsageKwh: (json['monthUsageKwh'] as num).toDouble(),
      expectedAmount: (json['expectedAmount'] as num).toDouble(),
      dueDate: json['dueDate'] as String?, // null 허용
      bills: billsJson
          .map((e) => BillSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
