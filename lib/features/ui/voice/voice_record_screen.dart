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

class _VoiceRecordScreenState extends State<VoiceRecordScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String _transcription = '';
  double _level = 0.0;
  double _pulseScale = 1.0;
  // تم حذف دعم الويب؛ التطبيق يستهدف الموبايل فقط

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      // Request microphone permission on mobile
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
      _transcription = _transcription.isEmpty ? 'listening_in_progress'.tr() : _transcription;
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
          // طبّق تغيير الحجم مباشرة حسب مستوى الصوت المقاس
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
    // Navigate to result screen with the captured transcription
    try {
      Navigator.of(context).pushNamed('/voice-result', arguments: _transcription);
    } catch (_) {}
  }

  // تم حذف جميع توابع الويب

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // المحتوى الأساسي للشاشة بدون تعبئة خلفية
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 200.h),
                // Center orb visual with pulse animation
                Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180.w,
                    height: 180.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.03),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 40, spreadRadius: 10),
                      ],
                    ),
                  ),
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
                        colors: [
                          AppColors.brand600.withOpacity(0.9),
                          AppColors.accentMauve.withOpacity(0.9),
                        ],
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.0),
                    ),
                  ),
                  Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Live transcription or guiding text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                _transcription.isEmpty
                    ? 'voice_guidance'.tr()
                    : _transcription,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
            const Spacer(),
            SizedBox(height: 24.h),
            // Bottom controls
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: Offset(0, 6.h))],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _isListening
                              ? Container(
                                  key: const ValueKey('stop-square'),
                                  width: 20.w,
                                  height: 20.w,
                                  decoration: BoxDecoration(color: Colors.red.shade600, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(4)),
                                )
                              : Container(
                                  key: const ValueKey('record-circle'),
                                  width: 20.w,
                                  height: 20.w,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: Offset(0, 6.h))],
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 26.sp),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],
          ),
        ),
            // إطار تدرّجي على الحواف فقط أثناء التسجيل
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
    super.dispose();
  }
}

class _GradientFramePainter extends CustomPainter {
  final List<Color> colors;
  final double strokeWidth;
  final double radius;

  _GradientFramePainter({required this.colors, required this.strokeWidth, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect.deflate(strokeWidth / 2), Radius.circular(radius));
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