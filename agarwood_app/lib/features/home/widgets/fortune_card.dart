import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// 今日运势卡片
class FortuneCard extends StatelessWidget {
  const FortuneCard({super.key});

  @override
  Widget build(BuildContext context) {
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
          // 标题行
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.agarwoodBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.agarwoodBrown,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '今日運勢',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 运势内容
          Text(
            '木火相生，利於創作與發展，宜佩戴沉香以安神。',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
