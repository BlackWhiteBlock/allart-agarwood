import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// 数位孪生凭证页面 - NFT 展示
class NftCertificatePage extends StatelessWidget {
  const NftCertificatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // ─── 标题 ───
              Text(
                '數位孿生憑證',
                style: AppTypography.h1.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              // ─── NFT 卡片 ───
              _buildNftCard(context),
              const SizedBox(height: 24),
              // ─── 溯源信息 ───
              _buildTraceInfo(),
              const SizedBox(height: 24),
              // ─── 区块链信息 ───
              _buildBlockchainInfo(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNftCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 真品认证标签
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '真品認證',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 区块链图标
              const Icon(
                Icons.tag,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 手串圆形图片
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.divider,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.agarwoodBrown.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1760552267090-605625ea4b8d?w=400&h=400&fit=crop',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 手串名称
          Text(
            '海南沉香·木韻',
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Token #2026031500001',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraceInfo() {
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
            '溯源信息',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on_outlined, '產地溯源', '中國 海南省'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildInfoRow(Icons.calendar_today_outlined, '鑄造日期', '2026.03.15'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildInfoRow(Icons.eco_outlined, '結香年份', '約15年'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildInfoRow(Icons.category_outlined, '五行屬性', '木'),
        ],
      ),
    );
  }

  Widget _buildBlockchainInfo() {
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
            '區塊鏈信息',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.fingerprint, '區塊鏈哈希', '0x8A9F...2C4B'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildInfoRow(Icons.link, '合約地址', '0x3B7E...9D1F'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildInfoRow(Icons.account_balance_wallet_outlined, '持有者', '0xA1C2...F8E9'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildInfoRow(Icons.swap_horiz, '網絡', 'BSC (BNB Smart Chain)'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.agarwoodBrown),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
