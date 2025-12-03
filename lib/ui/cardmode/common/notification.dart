import 'package:flutter/material.dart';

/// 알림 하나에 대한 데이터 모델
class AppNotification {
  final String id;
  final String type; // 'success' | 'warning' | 'error' | 'info' | 'special'
  final String icon; // 'bell' | 'wrench' | 'shield' | 'zap' | 'mosque' | 'check'
  final String title;
  final String message;
  final String time;
  final String? actionLabel;
  final VoidCallback? onAction;

  final Gradient? bgGradient;
  final Color borderColor;
  final Color iconBg;
  final Color iconColor;
  final Color? actionColor;

  AppNotification({
    required this.id,
    required this.type,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    this.actionLabel,
    this.onAction,
    this.bgGradient,
    required this.borderColor,
    required this.iconBg,
    required this.iconColor,
    this.actionColor,
  });
}

/// 바텀시트 안에 실제로 그려지는 레이어
class NotificationLayer extends StatefulWidget {
  const NotificationLayer({super.key});

  @override
  State<NotificationLayer> createState() => _NotificationLayerState();
}

class _NotificationLayerState extends State<NotificationLayer> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();

    _notifications = [
      AppNotification(
        id: '1',
        type: 'success',
        icon: 'bell',
        title: '세탁기 세탁 완료',
        message: '세탁이 완료되었습니다. 세탁물을 꺼내주세요.',
        time: '5분 전',
        bgGradient: const LinearGradient(
          colors: [Color(0xFFE8F9F1), Color(0xFFE0F7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: const Color(0xFFA7F3D0),
        iconBg: const Color(0xFFD1FAE5),
        iconColor: const Color(0xFF16A34A),
      ),
      AppNotification(
        id: '2',
        type: 'warning',
        icon: 'wrench',
        title: '세탁조(통) 청소 권장',
        message: '다음 세탁 후 세탁조 청소를 권장합니다.',
        time: '30분 전',
        actionLabel: '청소 시작하기 →',
        onAction: () {
          debugPrint('Start cleaning');
        },
        bgGradient: const LinearGradient(
          colors: [Color(0xFFE8F9F1), Color(0xFFE8F9F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: const Color(0xFFA7F3D0),
        iconBg: const Color(0xFFD1FAE5),
        iconColor: const Color(0xFF16A34A),
        actionColor: const Color(0xFF16A34A),
      ),
      AppNotification(
        id: '3',
        type: 'error',
        icon: 'shield',
        title: '건조기 필터 교체 필요',
        message: '린트 필터 교체 시기입니다. (30%)',
        time: '1시간 전',
        actionLabel: '교체 안내 보기 →',
        onAction: () {
          debugPrint('View replacement guide');
        },
        bgGradient: const LinearGradient(
          colors: [Color(0xFFFEE2E2), Color(0xFFFFE4B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: const Color(0xFFFCA5A5),
        iconBg: const Color(0xFFFEE2E2),
        iconColor: const Color(0xFFDC2626),
        actionColor: const Color(0xFFDC2626),
      ),
      AppNotification(
        id: '4',
        type: 'special',
        icon: 'mosque',
        title: 'Prayer Mode 활성화',
        message: 'Asr 시간입니다. 모든 가전이 조용히 작동합니다.',
        time: '2시간 전',
        bgGradient: const LinearGradient(
          colors: [Color(0xFFFEF9C3), Color(0xFFFEF9C3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: const Color(0xFFFDE68A),
        iconBg: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFCA8A04),
      ),
      AppNotification(
        id: '5',
        type: 'success',
        icon: 'zap',
        title: '전력 절약 모드 권장',
        message: 'Token 잔량 20%. 절약 모드를 활성화하세요.',
        time: '어제',
        actionLabel: '절약 모드 켜기 →',
        onAction: () {
          debugPrint('Enable power saving');
        },
        bgGradient: const LinearGradient(
          colors: [Color(0xFFE8F9F1), Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: const Color(0xFFA7F3D0),
        iconBg: const Color(0xFFD1FAE5),
        iconColor: const Color(0xFF16A34A),
        actionColor: const Color(0xFF16A34A),
      ),
      AppNotification(
        id: '6',
        type: 'special',
        icon: 'mosque',
        title: 'Ramadan Eco Mode 준비',
        message: '라마단 기간 동안 절전 모드를 활성화하세요.',
        time: '2일 전',
        actionLabel: '설정하기 →',
        onAction: () {
          debugPrint('Configure Ramadan mode');
        },
        bgGradient: const LinearGradient(
          colors: [Color(0xFFFEF9C3), Color(0xFFFFF7ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: const Color(0xFFFDE68A),
        iconBg: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFCA8A04),
        actionColor: const Color(0xFFCA8A04),
      ),
      AppNotification(
        id: '7',
        type: 'info',
        icon: 'check',
        title: 'Halal Zone 온도 확인',
        message: 'Halal 식품 보관 온도가 정상입니다. (4°C)',
        time: '3일 전',
        bgGradient: const LinearGradient(
          colors: [Color(0xFFE0F2F1), Color(0xFFE0F7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: const Color(0xFF99F6E4),
        iconBg: const Color(0xFFCCFBF1),
        iconColor: const Color(0xFF0D9488),
      ),
    ];
  }

  void _markAllAsRead() {
    setState(() {
      _notifications.clear();
    });
  }

  void _removeNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  Widget _buildIcon(AppNotification n) {
    switch (n.icon) {
      case 'bell':
        return Icon(Icons.notifications_none,
            color: n.iconColor, size: 24);
      case 'wrench':
        return Icon(Icons.build_outlined,
            color: n.iconColor, size: 24);
      case 'shield':
        return Icon(Icons.shield_outlined,
            color: n.iconColor, size: 24);
      case 'zap':
        return Icon(Icons.bolt_outlined,
            color: n.iconColor, size: 24);
      case 'mosque':
        return const Text('🕌', style: TextStyle(fontSize: 24));
      case 'check':
        return const Text('✅', style: TextStyle(fontSize: 24));
      default:
        return Icon(Icons.notifications_none,
            color: n.iconColor, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    // showModalBottomSheet 안에서 사용할 실제 컨테이너
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_none,
                          size: 20, color: Colors.black87),
                      const SizedBox(width: 6),
                      const Text(
                        '알림',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (_notifications.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${_notifications.length})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      if (_notifications.isNotEmpty)
                        TextButton(
                          onPressed: _markAllAsRead,
                          child: const Text(
                            '모두 읽음',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // 리스트 영역
            Flexible(
              child: _notifications.isEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 32, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFFF3F4F6),
                      child: Icon(Icons.notifications_none,
                          size: 36, color: Color(0xFF9CA3AF)),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '알림이 없습니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemBuilder: (context, index) {
                  final n = _notifications[index];
                  return Dismissible(
                    key: ValueKey(n.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _removeNotification(n.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(Icons.delete_outline,
                          color: Colors.red.shade400),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: n.bgGradient ??
                            LinearGradient(
                              colors: [
                                Colors.grey.shade100,
                                Colors.grey.shade100,
                              ],
                            ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: n.borderColor),
                      ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: n.iconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: _buildIcon(n)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            n.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n.time,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          if (n.actionLabel != null &&
                              n.onAction != null) ...[
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: n.onAction,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                n.actionLabel!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: n.actionColor ??
                                      const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: _notifications.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 바깥에서 쉽게 쓰도록 helper 함수
Future<void> showNotificationLayer(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) {
      return const FractionallySizedBox(
        heightFactor: 0.85, // 85vh 느낌
        child: NotificationLayer(),
      );
    },
  );
}
