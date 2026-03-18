import 'package:flutter/material.dart';

/// 众艺链 App 设计系统 - 字体定义
/// 东方极简风格：优雅衬线体 + 清晰无衬线体
class AppTypography {
  AppTypography._();

  // ─── 字体家族 ───
  static const String displayFont = 'Noto Serif SC'; // 宋体/衬线体用于标题
  static const String bodyFont = 'Noto Sans SC'; // 无衬线体用于正文

  // ─── 标题样式 ───
  static const TextStyle h1 = TextStyle(
    fontFamily: displayFont,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: displayFont,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: displayFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ─── 正文样式 ───
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ─── 标签/按钮样式 ───
  static const TextStyle labelLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // ─── 辅助样式 ───
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: Color(0xFF9B9B9B),
  );

  static const TextStyle overline = TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 1.5,
  );
}
