import 'package:flutter/material.dart';
import '../power/power_management.dart';

class LgSeaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const LgSeaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black54,
      selectedIconTheme: const IconThemeData(color: Colors.green),
      unselectedIconTheme: const IconThemeData(color: Colors.black54),

      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home), // 선택 시 채워진 아이콘
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bolt_outlined),
          activeIcon: Icon(Icons.bolt),
          label: '전력',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          activeIcon: Icon(Icons.info),
          label: '상태 확인',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '마이페이지',
        ),
      ],
    );
  }
}
