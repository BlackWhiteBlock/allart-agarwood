import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'widgets/nfc_scan_card.dart';
import 'widgets/fortune_card.dart';
import 'widgets/five_elements_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // ─── 顶部欢迎栏 ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '歡迎，緣主',
                        style: AppTypography.h1.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '今日運勢',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // 用户头像
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.agarwoodLight.withOpacity(0.5),
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ─── NFC 感应卡片 ───
              const NfcScanCard(),
              const SizedBox(height: 24),
              // ─── 今日运势卡片 ───
              const FortuneCard(),
              const SizedBox(height: 24),
              // ─── 五行能量条 ───
              const FiveElementsBar(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
