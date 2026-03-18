import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_page.dart';
import 'features/ai_chat/ai_chat_page.dart';
import 'features/nft_certificate/nft_certificate_page.dart';
import 'features/profile/profile_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const AgarwoodApp());
}

class AgarwoodApp extends StatelessWidget {
  const AgarwoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '眾藝鏈',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.orientalMinimal,
      home: const MainShell(),
    );
  }
}

/// 主界面壳 - 包含底部导航栏
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    AiChatPage(),
    NftCertificatePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, '首頁'),
                _buildNavItem(1, Icons.auto_awesome, '五行AI'),
                _buildNavItem(2, Icons.nfc_rounded, '數位憑證'),
                _buildNavItem(3, Icons.person_outline_rounded, '我的'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF9B9B9B);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
