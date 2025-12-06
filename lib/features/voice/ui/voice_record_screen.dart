import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';

class VoiceRecordScreen extends StatefulWidget {
  const VoiceRecordScreen({super.key});

  @override
  State<VoiceRecordScreen> createState() => _VoiceRecordScreenState();
}

class _VoiceRecordScreenState extends State<VoiceRecordScreen>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String _transcription = '';
  double _level = 0.0;
  double _pulseScale = 1.0;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  Future<void> _initSpeech() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        setState(() => _isAvailable = false);
        return;
      }
      final available = await _speech.initialize(
        onStatus: (status) {},
        onError: (error) {},
      );
      setState(() {
        _isAvailable = available;
      });
    } catch (_) {
      setState(() => _isAvailable = false);
    }
  }

  Future<void> _startListening() async {
    if (!_isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('mic_unavailable'.tr()),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    setState(() {
      _isListening = true;
      _transcription = _transcription.isEmpty
          ? 'listening_in_progress'.tr()
          : _transcription;
    });
    await _speech.listen(
      localeId: 'ar-JO',
      listenMode: stt.ListenMode.dictation,
      onResult: (result) {
        setState(() {
          _transcription = result.recognizedWords;
        });
      },
      onSoundLevelChange: (level) {
        setState(() {
          _level = level;
          final normalized = (level / 40.0).clamp(0.0, 0.35);
          _pulseScale = 1.0 + normalized;
        });
      },
    );
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}
    setState(() {
      _isListening = false;
      _pulseScale = 1.0;
    });
    try {
      Navigator.of(
        context,
      ).pushNamed('/voice-result', arguments: _transcription);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 200.h),

                  // Siri-like orb with wave animations
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // الدائرة الخارجية الكبيرة (الهالة الخارجية)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _isListening ? 280.w : 240.w,
                          height: _isListening ? 280.w : 240.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.brand600.withOpacity(0.0),
                                AppColors.brand600.withOpacity(
                                  _isListening ? 0.15 : 0.08,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // الدائرة المتوسطة
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isListening ? 200.w : 180.w,
                          height: _isListening ? 200.w : 180.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.brand600.withOpacity(0.1),
                                AppColors.brand600.withOpacity(
                                  _isListening ? 0.25 : 0.15,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Wave animation layer
                        if (_isListening)
                          AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size(180.w, 180.w),
                                painter: _WavePainter(
                                  animation: _waveController.value,
                                  soundLevel: _level,
                                  isListening: _isListening,
                                ),
                              );
                            },
                          ),

                        // الدائرة الرئيسية مع التأثير النابض والصورة في المنتصف
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          curve: Curves.easeOut,
                          width: (140.w) * _pulseScale,
                          height: (140.w) * _pulseScale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFE91E8C), Color(0xFFB84FC9)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFE91E8C).withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 70.w,
                              height: 70.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1A1F2E),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Live transcription
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      _transcription.isEmpty
                          ? 'voice_guidance'.tr()
                          : _transcription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(),
                  SizedBox(height: 24.h),

                  // Bottom controls
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Record / Stop button
                        GestureDetector(
                          onTap: () {
                            if (_isListening) {
                              _stopListening();
                            } else {
                              _startListening();
                            }
                          },
                          child: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(30.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: Offset(0, 6.h),
                                ),
                              ],
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: _isListening
                                    ? Container(
                                        key: const ValueKey('stop-square'),
                                        width: 20.w,
                                        height: 20.w,
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade600,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        key: const ValueKey('record-circle'),
                                        width: 20.w,
                                        height: 20.w,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        // Close button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(30.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: Offset(0, 6.h),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 26.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),

            // إطار تدرّجي على الحواف أثناء التسجيل
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _isListening ? 1.0 : 0.0,
                  child: CustomPaint(
                    painter: _GradientFramePainter(
                      colors: const [AppColors.brand600, AppColors.brand900],
                      strokeWidth: 4.0,
                      radius: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _speech.stop();
    super.dispose();
  }
}

// Wave Painter for Siri-like effect
class _WavePainter extends CustomPainter {
  final double animation;
  final double soundLevel;
  final bool isListening;

  _WavePainter({
    required this.animation,
    required this.soundLevel,
    required this.isListening,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isListening) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;
    final soundMultiplier = (soundLevel / 100).clamp(0.0, 0.3);
    final radius = baseRadius * (1.0 + soundMultiplier);

    // رسم موجات متعددة
    for (int i = 0; i < 3; i++) {
      final waveRadius = radius * (0.7 + animation * 0.3 + (i * 0.1));
      final wavePaint = Paint()
        ..color = Colors.white.withOpacity(0.2 - (i * 0.05))
        ..strokeWidth = 2.0 - (i * 0.5)
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(center, waveRadius, wavePaint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => true;
}

// Gradient Frame Painter
class _GradientFramePainter extends CustomPainter {
  final List<Color> colors;
  final double strokeWidth;
  final double radius;

  _GradientFramePainter({
    required this.colors,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientFramePainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
