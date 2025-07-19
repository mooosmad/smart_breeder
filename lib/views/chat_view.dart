import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:smart_breeder/controllers/chat_controller.dart';

class ChatView extends StatelessWidget {
  final ChatController controller = Get.find();

  ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant IA'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: controller.startVoiceInput,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() => ListView(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  ...controller.messages
                      .map((msg) => _buildChatMessage(msg.message, msg.isFromAI))
                      .toList(),
                  if (controller.isTyping.value) _buildTypingIndicator(),
                ],
              )),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      decoration: InputDecoration(
                        hintText: 'Tapez votre message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: controller.sendMessage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: () => controller.sendMessage(controller.messageController.text),
                    backgroundColor: Colors.green[700],
                    mini: true,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(String message, bool isBot) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        decoration: BoxDecoration(
          color: isBot ? Colors.grey[100] : Colors.green[100],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isBot ? const Radius.circular(0) : const Radius.circular(16),
            bottomRight: isBot ? const Radius.circular(16) : const Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: isBot
            ? MarkdownBody(
                data: message,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 15, color: Colors.black87),
                  strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
                  h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  listBullet: const TextStyle(fontSize: 15, color: Colors.black87),
                  blockquote: const TextStyle(color: Colors.grey),
                  code: const TextStyle(fontFamily: 'monospace', color: Colors.deepPurple),
                ),
              )
            : Text(
                message,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: Get.width * 0.55),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "L'IA réfléchit",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            TypingDots(),
          ],
        ),
      ),
    );
  }
}

/// Widget animé pour les points "..."
class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots> with SingleTickerProviderStateMixin {
  int _dotCount = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        _dotCount = _dotCount == 3 ? 1 : _dotCount + 1;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '.' * _dotCount,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
