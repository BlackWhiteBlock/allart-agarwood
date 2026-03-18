import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// 五行AI 对话页面
class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: '您好，我是您的五行AI助理。基於您的八字與沉香磁場，今日有什麼我可以為您解惑的嗎？',
      isUser: false,
    ),
  ];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messageController.clear();
    });

    // 模拟AI回复
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: _getAiResponse(text),
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
    });

    _scrollToBottom();
  }

  String _getAiResponse(String input) {
    if (input.contains('運勢') || input.contains('运势')) {
      return '根據您的五行屬性，今日木火相生，利於創作與靈感迸發。建議佩戴沉香手串靜心冥想，有助於激發內在能量。';
    } else if (input.contains('手串') || input.contains('沉香')) {
      return '您的沉香手串源自海南島千年沉香，木屬性極強，能夠平衡您的五行能量。建議每日靜心佩戴，感受其溫潤氣場。';
    } else if (input.contains('冥想') || input.contains('修行')) {
      return '冥想時佩戴沉香手串，可以幫助您更快進入寧靜狀態。建議選擇清晨或黃昏，面朝東方，深呼吸三次後開始。';
    }
    return '感謝您的提問。根據您的五行命盤分析，您目前的氣場偏向木火，建議多接觸水元素來平衡。佩戴沉香手串有助於安神養氣。';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ─── 标题栏 ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              '五行AI',
              style: AppTypography.h1.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // ─── 消息列表 ───
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // ─── 输入框 ───
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: BoxDecoration(
              color: AppColors.cream,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: '詢問五行命理...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 发送按钮
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.agarwoodBrown,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            // AI头像
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.agarwoodBrown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.agarwoodBrown,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? AppColors.agarwoodBrown
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: AppTypography.bodyMedium.copyWith(
                  color: msg.isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
