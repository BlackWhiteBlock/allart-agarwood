import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// 五行能量条展示组件
class FiveElementsBar extends StatelessWidget {
  const FiveElementsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final elements = [
      _ElementData('土', AppColors.earthOcher, 0.6),
      _ElementData('火', AppColors.fireRed, 0.8),
      _ElementData('水', AppColors.waterBlue, 0.5),
      _ElementData('木', AppColors.woodGreen, 0.9),
      _ElementData('金', AppColors.metalSilver, 0.4),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '五行能量',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: elements
                .map((e) => _buildElementItem(e))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildElementItem(_ElementData data) {
    return Column(
      children: [
        // 圆形能量指示器
        SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景圈
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: data.value,
                  strokeWidth: 3,
                  backgroundColor: data.color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(data.color),
                ),
              ),
              // 文字
              Text(
                data.name,
                style: AppTypography.labelMedium.copyWith(
                  color: data.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(data.value * 100).toInt()}%',
          style: AppTypography.caption.copyWith(
            color: data.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ElementData {
  final String name;
  final Color color;
  final double value;

  _ElementData(this.name, this.color, this.value);
}
