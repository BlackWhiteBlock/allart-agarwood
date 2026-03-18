import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// NFC 感应手串卡片 - 首页核心交互组件
class NfcScanCard extends StatefulWidget {
  const NfcScanCard({super.key});

  @override
  State<NfcScanCard> createState() => _NfcScanCardState();
}

class _NfcScanCardState extends State<NfcScanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1760552267090-605625ea4b8d?w=800&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.agarwoodBrown.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.5),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NFC 涟漪动效图标
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 涟漪动画
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 60 + (_rippleAnimation.value * 20),
                          height: 60 + (_rippleAnimation.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white
                                  .withOpacity(1 - _rippleAnimation.value),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                    // NFC 图标
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.agarwoodBrown.withOpacity(0.85),
                      ),
                      child: const Icon(
                        Icons.nfc_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '感應手串 NFC',
                style: AppTypography.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '驗證您的專屬沉香手串',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
