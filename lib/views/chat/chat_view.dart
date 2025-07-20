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
        title: Row(
          children: [
            const Text('SmartBreeder AI'),
            const Spacer(),
            Obx(() => controller.isSpeaking.value 
              ? const VoiceIndicator(color: Colors.orange)
              : const SizedBox.shrink()),
          ],
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          Obx(() => IconButton(
            icon: controller.isSpeaking.value
                ? const Icon(Icons.volume_off)
                : const Icon(Icons.volume_up),
            onPressed: controller.isSpeaking.value
                ? controller.stopSpeaking
                : null,
            tooltip: controller.isSpeaking.value 
                ? 'Arrêter la lecture' 
                : 'Audio activé',
          )),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Effacer l\'historique'),
                onTap: controller.clearHistory,
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indicateur de contexte animal
            Obx(() => controller.selectedAnimalContext.value.isNotEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.green[50],
                    child: Row(
                      children: [
                        Icon(Icons.pets, size: 16, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Contexte: ${controller.getAnimalContextName()}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => controller.setAnimalContext(null),
                          child: Icon(Icons.close, size: 16, color: Colors.green[700]),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),

            // Messages et indicateur d'enregistrement
            Expanded(
              child: Stack(
                children: [
                  Obx(() => ListView(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Messages existants
                      ...controller.messages
                          .map((msg) => _buildChatMessage(msg.message, msg.sender == 'ai', msg.isVoiceMessage))
                          .toList(),
                      
                      // Indicateur de frappe
                      if (controller.isTyping.value) _buildTypingIndicator(),
                    ],
                  )),

                  // Overlay d'enregistrement vocal
                  Obx(() => controller.isRecording.value
                      ? _buildRecordingOverlay()
                      : const SizedBox.shrink()),
                ],
              ),
            ),

            // Suggestions rapides
            if (controller.messages.isEmpty) _buildQuickSuggestions(),

            // Zone de saisie
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(String message, bool isBot, bool isVoiceMessage) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: Get.width * 0.8),
        decoration: BoxDecoration(
          color: isBot ? Colors.grey[100] : Colors.green[100],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isBot ? const Radius.circular(4) : const Radius.circular(16),
            bottomRight: isBot ? const Radius.circular(16) : const Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône pour message vocal
            if (isVoiceMessage && !isBot)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Message vocal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Contenu du message
            isBot
                ? MarkdownBody(
                    data: message,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                      strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
                      h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      listBullet: const TextStyle(fontSize: 15, color: Colors.black87),
                      blockquote: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                      code: const TextStyle(
                        fontFamily: 'monospace', 
                        backgroundColor: Colors.transparent,
                        color: Colors.deepPurple,
                      ),
                    ),
                  )
                : Text(
                    message,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
          ],
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
        constraints: BoxConstraints(maxWidth: Get.width * 0.6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy, size: 16, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text(
              "SmartBreeder réfléchit",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            const TypingDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animation d'enregistrement
              const RecordingAnimation(),
              const SizedBox(height: 20),
              
              // Status de l'enregistrement
              Obx(() => Text(
                controller.recordingStatus.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              )),
              
              const SizedBox(height: 20),
              
              // Bouton d'annulation
              ElevatedButton(
                onPressed: controller.stopVoiceInput,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  foregroundColor: Colors.red[700],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 18),
                    SizedBox(width: 8),
                    Text('Annuler'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions fréquentes :',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.quickQuestions
                .map((question) => GestureDetector(
                      onTap: () => controller.sendQuickQuestion(question),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: Colors.green[200]!),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          question,
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton vocal avec animation
          Obx(() => GestureDetector(
            onTap: controller.isRecording.value 
                ? controller.stopVoiceInput 
                : controller.startVoiceInput,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: controller.isRecording.value 
                    ? Colors.red[100] 
                    : Colors.green[100],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (controller.isRecording.value ? Colors.red : Colors.green)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: controller.isRecording.value ? 4 : 0,
                  ),
                ],
              ),
              child: Icon(
                controller.isRecording.value ? Icons.stop : Icons.mic,
                color: controller.isRecording.value 
                    ? Colors.red[700] 
                    : Colors.green[700],
                size: 24,
              ),
            ),
          )),
          
          const SizedBox(width: 12),
          
          // Champ de saisie
          Expanded(
            child: TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                hintText: 'Posez votre question vétérinaire...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.green[400]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onSubmitted: (text) => controller.sendMessage(text),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Bouton d'envoi
          GestureDetector(
            onTap: () => controller.sendMessage(controller.messageController.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green[700],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour les points de frappe animés
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
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = _dotCount == 3 ? 1 : _dotCount + 1;
        });
      }
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

/// Animation d'enregistrement vocal
class RecordingAnimation extends StatefulWidget {
  const RecordingAnimation({super.key});

  @override
  State<RecordingAnimation> createState() => _RecordingAnimationState();
}

class _RecordingAnimationState extends State<RecordingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.mic,
              color: Colors.red[700],
              size: 40,
            ),
          ),
        );
      },
    );
  }
}

/// Indicateur vocal dans l'AppBar
class VoiceIndicator extends StatefulWidget {
  final Color color;
  
  const VoiceIndicator({super.key, required this.color});

  @override
  State<VoiceIndicator> createState() => _VoiceIndicatorState();
}

class _VoiceIndicatorState extends State<VoiceIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.volume_up,
                color: widget.color,
                size: 18,
              ),
              const SizedBox(width: 4),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}






