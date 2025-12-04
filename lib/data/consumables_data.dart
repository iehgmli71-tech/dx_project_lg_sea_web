// lib/data/consumables_data.dart

import 'package:flutter/material.dart';
import '../models/device_models.dart';

/// 앱 전체에서 사용하는 기본 디바이스 목록
/// - CardMode, ConsumablesOverview 등에서 공통으로 사용
final List<Device> allDevices = [
  Device(
    id: '1',
    name: 'WashingMachine',
    iconEmoji: '🧺',
    iconImage: 'images/WashingMachine.png', // 실제 이미지 경로에 맞게 수정 가능
    status: 'Off',
    detail: null,
    active: false,
    consumables: [
      Consumable(
        name: '배수 필터',
        percentage: 58,
        color: Colors.amber, // 노란색
        lastChanged: '2025년 3월 2일',
        nextChange: '2025년 6월 예정',
        price: '₩15,000',
      ),
      Consumable(
        name: '세제 투입구',
        percentage: 72,
        color: Colors.green,
        lastChanged: '2025년 2월 10일',
        nextChange: '점검 필요 시',
        price: null,
      ),
    ],
  ),

  Device(
    id: '2',
    name: 'Dryer',
    iconEmoji: '🌀',
    iconImage: 'images/DryerLayer.png',
    status: 'Off',
    detail: null,
    active: false,
    consumables: [
      Consumable(
        name: '먼지 필터',
        percentage: 58,
        color: Colors.amber,
        lastChanged: '2025년 3월 5일',
        nextChange: '2025년 5월 예정',
        price: '₩12,000',
      ),
      // 교체 불가 파트 예시 (버튼 안 뜨게 하려면 이름을 여기에서 사용)
      Consumable(
        name: '히터',
        percentage: 90,
        color: Colors.green,
        lastChanged: '2024년 10월 1일',
        nextChange: '점검 필요 시',
        price: null,
      ),
    ],
  ),

  Device(
    id: '3',
    name: 'Refrigerator',
    iconEmoji: '🧊',
    iconImage: 'images/Refrigerator.png',
    status: '34°F',
    detail: null,
    active: true,
    consumables: [
      Consumable(
        name: '탈취 필터',
        percentage: 61,
        color: Colors.yellow,
        lastChanged: '2025년 1월 30일',
        nextChange: '2025년 7월 예정',
        price: '₩19,800',
      ),
      Consumable(
        name: '냉각 시스템',
        percentage: 95,
        color: Colors.green,
        lastChanged: '2024년 9월 1일',
        nextChange: '점검 필요 시',
        price: null,
      ),
      Consumable(
        name: '냉매',
        percentage: 88,
        color: Colors.green,
        lastChanged: '2024년 8월 15일',
        nextChange: '점검 필요 시',
        price: null,
      ),
    ],
  ),

  Device(
    id: '4',
    name: 'Air Conditioner',
    iconEmoji: '❄️',
    iconImage: 'images/air_conditioner.png',
    status: 'Off',
    detail: null,
    active: false,
    consumables: [
      Consumable(
        name: '에어 필터',
        percentage: 30,
        color: Colors.red,
        lastChanged: '2025년 3월 1일',
        nextChange: '2025년 5월 예정',
        price: '₩14,000',
      ),
      Consumable(
        name: '프레온 가스',
        percentage: 92,
        color: Colors.green,
        lastChanged: '2024년 7월 12일',
        nextChange: '점검 필요 시',
        price: null,
      ),
    ],
  ),
];
