import 'package:flutter/material.dart';
import '../../models/device_models.dart';
import '../../data/consumables_data.dart';
import 'consumablesLayer.dart';

/// 간편 AS 신청 모달
class EasyASModal extends StatefulWidget {
  final List<Device> devices;

  const EasyASModal({
    super.key,
    required this.devices,
  });


  @override
  State<EasyASModal> createState() => _EasyASModalState();
}

enum AsStep { device, symptom, datetime, confirm }

class _EasyASModalState extends State<EasyASModal> {
  AsStep _step = AsStep.device;

  Device? _selectedDevice;
  String _selectedSymptom = '';
  String _selectedDate = '';
  String _selectedTime = '';

  // ───────────────── 각 단계 이동 ─────────────────

  void _goNext() {
    setState(() {
      if (_step == AsStep.device) {
        _step = AsStep.symptom;
      } else if (_step == AsStep.symptom) {
        _step = AsStep.datetime;
      } else if (_step == AsStep.datetime) {
        _step = AsStep.confirm;
      }
    });
  }

  void _goPrev() {
    setState(() {
      if (_step == AsStep.confirm) {
        _step = AsStep.datetime;
      } else if (_step == AsStep.datetime) {
        _step = AsStep.symptom;
      } else if (_step == AsStep.symptom) {
        _step = AsStep.device;
      }
    });
  }

  // ───────────────── 날짜 / 시간 선택 ─────────────────

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = '${picked.year}.${picked.month}.${picked.day}';
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    final stepIndex = AsStep.values.indexOf(_step);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 드래그 핸들
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(999),
              ),
            ),

            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '간편 AS 신청',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 진행 단계 표시 (1~4)
            _buildStepIndicator(stepIndex),
            const SizedBox(height: 16),

            // 실제 컨텐츠
            Flexible(child: _buildStepContent()),

            const SizedBox(height: 16),

            // 하단 버튼들
            Row(
              children: [
                if (_step != AsStep.device)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goPrev,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('이전'),
                    ),
                  ),
                if (_step != AsStep.device) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onPrimaryPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _step == AsStep.confirm ? 'AS 신청하기' : '다음',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onPrimaryPressed() {
    if (_step != AsStep.confirm) {
      _goNext();
      return;
    }

    // 최종 신청 처리 (데모용: SnackBar)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AS 신청이 접수되었습니다.'),
      ),
    );
    Navigator.of(context).pop();
  }

  // ───────────────── 서브 위젯들 ─────────────────


  Widget _buildStepIndicator(int stepIndex) {
    const labels = ['기기 선택', '증상 선택', '날짜/시간', '확인'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(labels.length, (i) {
        final isActive = i <= stepIndex;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF22C55E) : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
              if (i < labels.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: i < stepIndex
                        ? const Color(0xFF22C55E)
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case AsStep.device:
        return _buildDeviceStep();
      case AsStep.symptom:
        return _buildSymptomStep();
      case AsStep.datetime:
        return _buildDatetimeStep();
      case AsStep.confirm:
        return _buildConfirmStep();
    }
  }

  // 1단계: 기기 선택
  Widget _buildDeviceStep() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: widget.devices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final device = widget.devices[index];
        final selected = _selectedDevice?.id == device.id;

        return ListTile(
          onTap: () {
            setState(() => _selectedDevice = device);
            _goNext();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          tileColor: selected ? const Color(0xFFE0F2FE) : Colors.grey.shade100,
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 28,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: _buildDeviceImage(device),
            ),
          ),
          title: Text(device.name),
          subtitle: Text(device.status),
          trailing: selected
              ? const Icon(Icons.check_circle, color: Color(0xFF22C55E))
              : null,
        );
      },
    );
  }
  String? _imageAssetForDevice(String name) {
    switch (name) {
      case 'WashingMachine':
        return 'images/WashingMachine.png';
      case 'Dryer':
        return 'images/DryerLayer.png';
      case 'Refrigerator':
        return 'images/Refrigerator.png';
      case 'Air Conditioner':
        return 'images/air_conditioner.png';
    }
    return null;
  }

  Widget _buildDeviceImage(Device device) {
    final asset = _imageAssetForDevice(device.name);   // ← 오류 사라짐
    if (asset != null) {
      return Image.asset(
        asset,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      );
    }

    return Text(device.iconEmoji, style: const TextStyle(fontSize: 26));
  }


  // 2단계: 증상 선택
  Widget _buildSymptomStep() {
    final symptoms = [
      '작동하지 않음',
      '이상한 소음 발생',
      '냄새가 남',
      '성능이 저하가 됨',
      '물이 새거나 누수',
      '온도 조절이 안됨',
      '기타'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '어떤 문제가 있나요?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: symptoms.map((s) {
            final selected = _selectedSymptom == s;
            return ChoiceChip(
              label: Text(s),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedSymptom = s);
              },
              selectedColor: const Color(0xFF22C55E).withOpacity(0.15),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 3단계: 날짜/시간 선택
  Widget _buildDatetimeStep() {
    final timeSlots = [
      '09:00 - 11:00',
      '11:00 - 13:00',
      '13:00 - 15:00',
      '15:00 - 17:00',
      '17:00 - 19:00',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '방문 가능한 날짜와 시간을 선택해주세요',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),

        // 날짜 선택 버튼
        OutlinedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_today_outlined, size: 16),
          label: Text(
            _selectedDate.isEmpty ? '날짜 선택' : _selectedDate,
          ),
        ),

        const SizedBox(height: 24),

        // 시간 선택 섹션
        const Row(
          children: [
            Icon(Icons.access_time, size: 18),
            SizedBox(width: 6),
            Text(
              '방문 시간',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 시간 버튼 2열(Grid) 배치
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: timeSlots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,     // 2 columns
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.7, // 버튼 비율 (넓고 낮게)
          ),
          itemBuilder: (context, index) {
            final slot = timeSlots[index];
            final isSelected = _selectedTime == slot;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTime = slot;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF22C55E) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }


  // 4단계: 확인
  Widget _buildConfirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '신청 내용을 확인해주세요',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),
        _confirmRow('기기', _selectedDevice?.name ?? '-'),
        const SizedBox(height: 8),
        _confirmRow('증상', _selectedSymptom.isEmpty ? '-' : _selectedSymptom),
        const SizedBox(height: 8),
        _confirmRow('희망 시간', _selectedDate.isEmpty && _selectedTime.isEmpty
            ? '-'
            : '$_selectedDate $_selectedTime'),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _confirmRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
