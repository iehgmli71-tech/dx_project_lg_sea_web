// lib/models/device_models.dart
import 'package:flutter/material.dart';

class Consumable {
  final String name;
  final int percentage;
  final Color color; // progress bar 색
  final String? lastChanged;
  final String? nextChange;
  final String? price;

  Consumable({
    required this.name,
    required this.percentage,
    required this.color,
    this.lastChanged,
    this.nextChange,
    this.price,
  });

  Consumable copyWith({
    String? name,
    int? percentage,
    Color? color,
    String? lastChanged,
    String? nextChange,
    String? price,
  }) {
    return Consumable(
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
      color: color ?? this.color,
      lastChanged: lastChanged ?? this.lastChanged,
      nextChange: nextChange ?? this.nextChange,
      price: price ?? this.price,
    );
  }
}

class Device {
  final String id;
  final String name;

  // 아이콘
  final String iconEmoji;
  final String? iconImage;

  // 시간당 평균 소비전력(W)
  // 전력 탭(today / month kWh, 예상 요금)에 사용할 값
  final double averagePowerW;

  // 카드/상태용
  bool active;
  String status;
  Color cardColor;
  String? detail;

  // 소모품 리스트
  List<Consumable> consumables;

  Device({
    required this.id,
    required this.name,
    required this.iconEmoji,
    this.iconImage,
    required this.averagePowerW,
    this.active = false,
    this.status = '작동 중',
    this.cardColor = const Color(0xFFF3F4F6),
    this.detail,
    this.consumables = const [],
  });
}
