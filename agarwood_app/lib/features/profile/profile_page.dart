import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// 个人设定页面
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _selectedLanguage = '繁體中文';
  String _selectedStyle = '東方極簡 (V1)';

  final List<String> _languages = ['繁體中文', 'English', '日本語', 'العربية'];
  final List<String> _styles = ['東方極簡 (V1)', '賽博未來 (V2)'];

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
              // ─── 标题 ───
              Text(
                '系統設定',
                style: AppTypography.h1.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              // ─── 用户信息卡片 ───
              _buildProfileCard(),
              const SizedBox(height: 24),
              // ─── 语言切换 ───
              _buildLanguageSection(),
              const SizedBox(height: 24),
              // ─── 介面风格 ───
              _buildStyleSection(),
              const SizedBox(height: 32),
              // ─── 登出按钮 ───
              _buildLogoutButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
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
      child: Row(
        children: [
          // 头像
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.agarwoodLight.withOpacity(0.5),
                width: 2,
              ),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User_8A9F',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                // Premium 标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.agarwoodBrown.withOpacity(0.15),
                        AppColors.agarwoodLight.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.agarwoodBrown.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        size: 14,
                        color: AppColors.agarwoodBrown,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.agarwoodBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
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
          Row(
            children: [
              const Icon(
                Icons.language,
                size: 22,
                color: AppColors.agarwoodBrown,
              ),
              const SizedBox(width: 10),
              Text(
                '語言 (Language)',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _languages.map((lang) {
              final isSelected = _selectedLanguage == lang;
              return GestureDetector(
                onTap: () => setState(() => _selectedLanguage = lang),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.agarwoodBrown
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.agarwoodBrown
                          : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    lang,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSection() {
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
          Row(
            children: [
              const Icon(
                Icons.palette_outlined,
                size: 22,
                color: AppColors.agarwoodBrown,
              ),
              const SizedBox(width: 10),
              Text(
                '介面風格',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: _styles.map((style) {
              final isSelected = _selectedStyle == style;
              final isOriental = style.contains('東方');
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedStyle = style),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      right: isOriental ? 5 : 0,
                      left: isOriental ? 0 : 5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isOriental
                              ? AppColors.cream
                              : const Color(0xFF1A1A2E))
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.agarwoodBrown
                            : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // 预览圆
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOriental
                                ? AppColors.agarwoodBrown.withOpacity(0.2)
                                : const Color(0xFF00E5FF).withOpacity(0.2),
                          ),
                          child: Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOriental
                                    ? AppColors.agarwoodBrown
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          style,
                          style: AppTypography.labelSmall.copyWith(
                            color: isOriental
                                ? AppColors.textPrimary
                                : (isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                '確認登出',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
              content: Text(
                '您確定要登出嗎？',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '取消',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '登出',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.error.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          '登出',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}
