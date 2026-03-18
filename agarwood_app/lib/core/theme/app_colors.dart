import 'package:flutter/material.dart';

/// 众艺链 App 设计系统 - 颜色定义
/// 东方极简风格：米白、沉香褐主色调，五行对应点缀色
class AppColors {
  AppColors._();

  // ─── 主色调 ───
  /// 米白背景色
  static const Color cream = Color(0xFFF8F5F0);
  /// 沉香褐 - 主要品牌色
  static const Color agarwoodBrown = Color(0xFF8B6914);
  /// 深沉香褐 - 按钮/强调
  static const Color agarwoodDark = Color(0xFF6B4F0E);
  /// 浅沉香褐 - 卡片/容器
  static const Color agarwoodLight = Color(0xFFD4B970);

  // ─── 五行色系 ───
  /// 金 - 银灰
  static const Color metalSilver = Color(0xFFB8B8B8);
  /// 木 - 青绿
  static const Color woodGreen = Color(0xFF6B8E6B);
  /// 水 - 深蓝
  static const Color waterBlue = Color(0xFF4A6B8A);
  /// 火 - 朱红
  static const Color fireRed = Color(0xFFC25450);
  /// 土 - 赭石
  static const Color earthOcher = Color(0xFFB8860B);

  // ─── 中性色 ───
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9B9B9B);
  static const Color divider = Color(0xFFE8E3DC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAF8F5);

  // ─── 功能色 ───
  static const Color success = Color(0xFF5B8C5A);
  static const Color warning = Color(0xFFD4A017);
  static const Color error = Color(0xFFC25450);
  static const Color info = Color(0xFF4A6B8A);

  // ─── 五行色彩映射 ───
  static Color getElementColor(String element) {
    switch (element) {
      case '金':
        return metalSilver;
      case '木':
        return woodGreen;
      case '水':
        return waterBlue;
      case '火':
        return fireRed;
      case '土':
        return earthOcher;
      default:
        return agarwoodBrown;
    }
  }
}
