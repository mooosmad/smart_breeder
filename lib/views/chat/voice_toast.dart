import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Widget pour visualiser l'amplitude du microphone
class MicrophoneVisualizer extends StatefulWidget {
  final double amplitude; // 0.0 à 1.0
  final bool isActive;
  
  const MicrophoneVisualizer({
    super.key,
    required this.amplitude,
    this.isActive = true,
  });

  @override
  State<MicrophoneVisualizer> createState() => _MicrophoneVisualizerState();
}

class _MicrophoneVisualizerState extends State<MicrophoneVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MicrophoneVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(100, 100),
          painter: MicrophoneVisualizerPainter(
            amplitude: widget.amplitude,
            pulseScale: _pulseAnimation.value,
            isActive: widget.isActive,
          ),
        );
      },
    );
  }
}

class MicrophoneVisualizerPainter extends CustomPainter {
  final double amplitude;
  final double pulseScale;
  final bool isActive;

  MicrophoneVisualizerPainter({
    required this.amplitude,
    required this.pulseScale,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Cercle de base
    final basePaint = Paint()
      ..color = isActive ? Colors.red[100]! : Colors.grey[300]!
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.6, basePaint);

    // Cercles d'amplitude
    if (isActive) {
      for (int i = 0; i < 3; i++) {
        final amplitudeRadius = radius * (0.7 + (amplitude * 0.3)) * pulseScale * (1 + i * 0.1);
        final amplitudePaint = Paint()
          ..color = Colors.red.withOpacity(0.3 - (i * 0.1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        
        canvas.drawCircle(center, amplitudeRadius, amplitudePaint);
      }
    }

    // Icône microphone
    final micPaint = Paint()
      ..color = isActive ? Colors.red[700]! : Colors.grey[600]!
      ..style = PaintingStyle.fill;

    // Dessiner l'icône du microphone
    final micRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 8),
        width: 16,
        height: 20,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(micRect, micPaint);

    // Pied du microphone
    final footPath = Path()
      ..moveTo(center.dx - 12, center.dy + 15)
      ..lineTo(center.dx + 12, center.dy + 15)
      ..moveTo(center.dx, center.dy + 8)
      ..lineTo(center.dx, center.dy + 15);
    
    final footPaint = Paint()
      ..color = isActive ? Colors.red[700]! : Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(footPath, footPaint);
  }

  @override
  bool shouldRepaint(covariant MicrophoneVisualizerPainter oldDelegate) {
    return amplitude != oldDelegate.amplitude ||
           pulseScale != oldDelegate.pulseScale ||
           isActive != oldDelegate.isActive;
  }
}

/// Widget pour afficher le statut de la synthèse vocale
class SpeechStatusIndicator extends StatefulWidget {
  final String text;
  final bool isActive;
  
  const SpeechStatusIndicator({
    super.key,
    required this.text,
    this.isActive = false,
  });

  @override
  State<SpeechStatusIndicator> createState() => _SpeechStatusIndicatorState();
}

class _SpeechStatusIndicatorState extends State<SpeechStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_controller);

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SpeechStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isActive ? Colors.orange[100] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isActive ? Colors.orange[300]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.volume_up,
            size: 16,
            color: widget.isActive ? Colors.orange[700] : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          if (widget.isActive)
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(40, 16),
                  painter: SoundWavePainter(
                    wavePhase: _waveAnimation.value,
                    color: Colors.orange[700]!,
                  ),
                );
              },
            )
          else
            Text(
              widget.text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}

class SoundWavePainter extends CustomPainter {
  final double wavePhase;
  final Color color;

  SoundWavePainter({
    required this.wavePhase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final waveCount = 3;

    for (int i = 0; i < waveCount; i++) {
      final x = (size.width / (waveCount - 1)) * i;
      final amplitude = 6 * math.sin(wavePhase + i * 0.8);
      
      canvas.drawLine(
        Offset(x, centerY - amplitude),
        Offset(x, centerY + amplitude),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SoundWavePainter oldDelegate) {
    return wavePhase != oldDelegate.wavePhase;
  }
}

/// Widget pour les suggestions rapides avec animations
class AnimatedQuickSuggestion extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final int index;

  const AnimatedQuickSuggestion({
    super.key,
    required this.text,
    required this.onTap,
    required this.index,
  });

  @override
  State<AnimatedQuickSuggestion> createState() => _AnimatedQuickSuggestionState();
}

class _AnimatedQuickSuggestionState extends State<AnimatedQuickSuggestion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    // Démarrer l'animation avec un délai
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green[50]!,
                      Colors.green[100]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.green[200]!),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget pour les notifications toast personnalisées
class VoiceToast extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onDismiss;

  const VoiceToast({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
    this.onDismiss,
  });

  static void show(BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: VoiceToast(
          message: message,
          icon: icon,
          color: color,
          onDismiss: () => entry.remove(),
        ),
      ),
    );

    overlay.insert(entry);

    Timer(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onDismiss != null)
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close,
                  color: Colors.grey[600],
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}