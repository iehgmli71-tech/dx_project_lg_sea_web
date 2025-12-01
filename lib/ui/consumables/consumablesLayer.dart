// 상태확인 레이아웃 페이지 UI만 구성하는 페이지임

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dx_projecet_lg_sea/models/device_models.dart';

/// ─────────────────────────────────────────────────────────────
///  소모품 레이어 (Bottom Sheet + Dimmed 백드롭)
/// 사용 예시:
/// showDialog(
///   context: context,
///   barrierColor: Colors.transparent,
///   builder: (_) => ConsumablesLayer(device: device, onClose: () => Navigator.pop(context)),
/// );
/// ─────────────────────────────────────────────────────────────

class ConsumablesLayer extends StatefulWidget {
  final Device device;
  final VoidCallback onClose;

  const ConsumablesLayer({
    Key? key,
    required this.device,
    required this.onClose,
  }) : super(key: key);

  @override
  State<ConsumablesLayer> createState() => _ConsumablesLayerState();
}

class _ConsumablesLayerState extends State<ConsumablesLayer> {
  Consumable? _selectedConsumable;
  bool _showOrderConfirm = false;

  late List<Consumable> _consumableStates;

  bool _showResetNotification = false;
  String _resetConsumableName = '';
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();

    // 🔥 consumables가 null이어도 안전하게 처리
    final initial = widget.device.consumables ?? <Consumable>[];
    _consumableStates = List<Consumable>.from(initial);
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  // React 의 handleResetConsumable
  void _handleResetConsumable(int index, String name) {
    final updated = List<Consumable>.from(_consumableStates);
    updated[index] = updated[index].copyWith(
      percentage: 100,
      color: const Color(0xFF22C55E), // green-500
      lastChanged: _formatToday(),
    );

    setState(() {
      _consumableStates = updated;
      _resetConsumableName = name;
      _showResetNotification = true;
    });

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showResetNotification = false);
      }
    });
  }

  String _formatToday() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일';
  }

  Color _statusColor(int percentage) {
    if (percentage < 40) return const Color(0xFFDC2626); // red-600
    if (percentage < 70) return const Color(0xFFCA8A04); // yellow-600
    return const Color(0xFF059669); // green-600
  }

  BoxDecoration _statusBgDecoration(int percentage) {
    if (percentage < 40) {
      return BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA), width: 2),
      );
    }
    if (percentage < 70) {
      return BoxDecoration(
        color: const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
      );
    }
    return BoxDecoration(
      color: const Color(0xFFDCFCE7),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
    );
  }

  String _statusText(int percentage) {
    if (percentage < 40) return '교체 필요';
    if (percentage < 70) return '교체 권장';
    return '양호';
  }

  void _handleOrder(Consumable consumable) {
    setState(() {
      _selectedConsumable = consumable;
      _showOrderConfirm = true;
    });
  }

  /// 디바이스 이름 → 이미지 asset 경로 매핑
  String? _imageAssetForDevice(String name) {
    final lower = name.toLowerCase();

    if (lower.contains('washing')) {
      return 'images/WashingMachine.png';
    }
    if (lower.contains('dryer')) {
      return 'images/DryerLayer.png';
    }
    if (lower.contains('refrigerator') || lower.contains('fridge')) {
      return 'images/Refrigerator.png';
    }
    if (lower.contains('air') && lower.contains('conditioner')) {
      return 'images/air_conditioner.png';
    }

    // 혹시 나중에 한국어 이름을 쓰는 경우
    switch (name) {
      case '세탁기':
        return 'images/WashingMachine.png';
      case '건조기':
        return 'images/DryerLayer.png';
      case '냉장고':
        return 'images/Refrigerator.png';
      case '에어컨':
        return 'images/air_conditioner.png';
    }
    return null;
  }

  /// 헤더에 표시할 디바이스 이름 정리
  String _deviceDisplayName(String raw) {
    switch (raw) {
      case 'WashingMachine':
      case 'Washing Machine':
        return 'Washing Machine';
      case 'DryerLayer':
      case 'Dryer':
        return 'Dryer';
      case 'Refrigerator':
        return 'Refrigerator';
      case 'AirConditioner':
      case 'Air Conditioner':
        return 'Air Conditioner';
      default:
        return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final criticalCount =
        _consumableStates.where((c) => c.percentage < 40).length;

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            color: Colors.black.withOpacity(0.4),
          ),
        ),

        // Bottom sheet
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.9,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 24,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ▒▒▒ 상단 Header ▒▒▒
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child:
                              Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFF5EEFF),
                                          Color(0xFFFFE4EB),
                                        ],
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: _buildDeviceImage(device),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // 🔥 여기만 수정: 제목을 각 가전 이름으로
                                  Expanded(child:
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _deviceDisplayName(device.name),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        '디바이스 소모품 상태를 확인하고 관리하세요',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ),
                                ],
                              ),
                              ),
                              IconButton(
                                onPressed: widget.onClose,
                                icon: const Icon(Icons.close,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Summary card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFDCFCE7),
                                  Color(0xFFFFE4E6),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.inventory_2_outlined,
                                            size: 20,
                                            color: Color(0xFF16A34A)),
                                        SizedBox(width: 6),
                                        Text(
                                          '전체 소모품',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${_consumableStates.length}개',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Divider(
                                  height: 1,
                                  color: Colors.green.shade200,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '교체 필요',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '$criticalCount개',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ▒▒▒ 소모품 리스트 ▒▒▒
                          Column(
                            children: List.generate(
                              _consumableStates.length,
                                  (idx) {
                                final c = _consumableStates[idx];
                                final statusColor = _statusColor(c.percentage);

                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom:
                                    idx == _consumableStates.length - 1
                                        ? 0
                                        : 12,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration:
                                  _statusBgDecoration(c.percentage),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                    children: [
                                      // header
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(14),
                                              color: c.percentage < 40
                                                  ? const Color(0xFFFEE2E2)
                                                  : c.percentage < 70
                                                  ? const Color(
                                                  0xFFFEF9C3)
                                                  : const Color(
                                                  0xFFDCFCE7),
                                            ),
                                            child: Icon(
                                              c.percentage < 40
                                                  ? Icons
                                                  .warning_amber_rounded
                                                  : c.percentage < 70
                                                  ? Icons
                                                  .warning_amber_rounded
                                                  : Icons.check_circle,
                                              color: statusColor,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  c.name,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _statusText(c.percentage),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '${c.percentage}%',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // progress bar
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(
                                          begin: 0,
                                          end: c.percentage.toDouble(),
                                        ),
                                        duration:
                                        const Duration(milliseconds: 500),
                                        builder: (context, value, _) {
                                          return Container(
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                              BorderRadius.circular(999),
                                            ),
                                            alignment: Alignment.centerLeft,
                                            child: FractionallySizedBox(
                                              widthFactor: value / 100,
                                              child: Container(
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: c.color,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      999),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),

                                      // 날짜 정보
                                      if (c.lastChanged != null ||
                                          c.nextChange != null)
                                        Row(
                                          children: [
                                            if (c.lastChanged != null)
                                              Expanded(
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        12),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Row(
                                                        children: const [
                                                          Icon(
                                                            Icons
                                                                .calendar_today_outlined,
                                                            size: 14,
                                                            color:
                                                            Colors.grey,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            '마지막 교체',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                              Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 4),
                                                      Text(
                                                        c.lastChanged!,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                          Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            if (c.lastChanged != null &&
                                                c.nextChange != null)
                                              const SizedBox(width: 8),
                                            if (c.nextChange != null)
                                              Expanded(
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        12),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Row(
                                                        children: const [
                                                          Icon(
                                                            Icons
                                                                .trending_down,
                                                            size: 14,
                                                            color:
                                                            Colors.grey,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            '예상 교체',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                              Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 4),
                                                      Text(
                                                        c.nextChange!,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                          Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),

                                      if (c.price != null) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(14),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    '정품 소모품 가격',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    c.price!,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    _handleOrder(c),
                                                style: ElevatedButton
                                                    .styleFrom(
                                                  backgroundColor:
                                                  c.percentage < 40
                                                      ? const Color(
                                                      0xFFEF4444)
                                                      : c.percentage < 70
                                                      ? const Color(
                                                      0xFFEAB308)
                                                      : const Color(
                                                      0xFF22C55E),
                                                  foregroundColor:
                                                  Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 14,
                                                    vertical: 10,
                                                  ),
                                                  shape:
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        14),
                                                  ),
                                                  elevation: 4,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: const [
                                                    Icon(
                                                      Icons.shopping_cart,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text('주문하기'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // 필터 교체 초기화 버튼
                                        if (![
                                          '드럼',
                                          '히터',
                                          '냉각 시스템',
                                          '냉매',
                                        ].contains(c.name))
                                          const SizedBox(height: 8),
                                        if (![
                                          '드럼',
                                          '히터',
                                          '냉각 시스템',
                                          '냉매',
                                        ].contains(c.name))
                                          OutlinedButton(
                                            onPressed: () =>
                                                _handleResetConsumable(
                                                    idx, c.name),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              backgroundColor:
                                              const Color(0xFFE0F2FE),
                                              side: const BorderSide(
                                                color: Color(0xFFBFDBFE),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.refresh,
                                                    size: 18,
                                                    color:
                                                    Color(0xFF2563EB)),
                                                SizedBox(width: 6),
                                                Text(
                                                  '필터 교체 완료 (초기화)',
                                                  style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    color:
                                                    Color(0xFF2563EB),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],

                                      // Warning
                                      if (c.percentage < 40) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            border: Border.all(
                                              color: const Color(0xFFFCA5A5),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: const [
                                              Icon(
                                                Icons
                                                    .warning_amber_rounded,
                                                color: Color(0xFFDC2626),
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      '교체가 필요합니다',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                        color: Color(
                                                            0xFFB91C1C),
                                                      ),
                                                    ),
                                                    SizedBox(height: 2),
                                                    Text(
                                                      '제품 성능 저하를 방지하기 위해 빠른 시일 내에 교체해주세요.',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Color(
                                                            0xFFB91C1C),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tips
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE0F2FE),
                                  Color(0xFFCCFBF1),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2563EB),
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '💡',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '소모품 관리 팁',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _tipItem('정기적인 소모품 교체로 제품 수명을 연장하세요'),
                                _tipItem('정품 소모품 사용 시 최적의 성능을 보장합니다'),
                                _tipItem('자동 알림 설정으로 교체 시기를 놓치지 마세요'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 주문 확인 모달
        if (_showOrderConfirm && _selectedConsumable != null)
          _buildOrderConfirmModal(context),

        // reset 알림
        if (_showResetNotification) _buildResetNotification(),
      ],
    );
  }

  Widget _buildDeviceImage(Device device) {
    final asset = _imageAssetForDevice(device.name);
    if (asset != null) {
      return Image.asset(asset, fit: BoxFit.cover);
    }
    return Center(
      child: Text(
        device.iconEmoji,
        style: const TextStyle(fontSize: 26),
      ),
    );
  }

  Widget _tipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderConfirmModal(BuildContext context) {
    final c = _selectedConsumable!;
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _showOrderConfirm = false);
          },
          child: Container(
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Color(0xFF7C3AED),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '주문 확인',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${c.name}을(를) 주문하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _orderRow('제품', c.name),
                      const SizedBox(height: 4),
                      _orderRow('가격', c.price ?? '-'),
                      const SizedBox(height: 8),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      _orderRow(
                        '총 결제금액',
                        c.price ?? '-',
                        valueColor: const Color(0xFF7C3AED),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _showOrderConfirm = false);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.grey.shade200,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: 주문 로직 추가
                          setState(() => _showOrderConfirm = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: const Text('주문하기'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _orderRow(
      String label,
      String value, {
        Color? valueColor,
        bool isBold = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor ?? Colors.black87,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildResetNotification() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                '$_resetConsumableName 소모품이 100%로 재설정되었습니다.',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
