import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/shared/widgets/shared_ui_widgets.dart';
import 'package:fahman_app/core/shared/widgets/dashed_border_painter.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:file_selector/file_selector.dart';

/// نموذج الاستشارة القانونية
class ConsultationForm extends StatefulWidget {
  final String consultationTypeKey;
  final String? initialSectionId;
  final void Function({
    required String sectionId,
    required String content,
    List<XFile> files,
  })?
  onSubmit;
  final List<String> sectionNames;
  final List<String> sectionIds;
  const ConsultationForm({
    super.key,
    required this.consultationTypeKey,
    required this.sectionNames,
    required this.sectionIds,
    this.initialSectionId,
    this.onSubmit,
  });

  @override
  State<ConsultationForm> createState() => ConsultationFormState();
}

class ConsultationFormState extends State<ConsultationForm> {
  final TextEditingController _detailsController = TextEditingController();
  int _maxChars = 250; // الحد الأقصى لعدد الأحرف
  String? _selectedSectionId;
  final List<XFile> _pickedFiles = [];
  bool _isSubmitting = false;
  String? _validationError;
  bool _acceptedConsent = false; // NEW: Consent acceptance state

  @override
  void initState() {
    super.initState();
    // default to first section if provided
    if (widget.sectionIds.isNotEmpty) {
      if (widget.initialSectionId != null &&
          widget.sectionIds.contains(widget.initialSectionId)) {
        _selectedSectionId = widget.initialSectionId;
      } else {
        _selectedSectionId = widget.sectionIds.first;
      }
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ConsultationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the parent updates sections after API load, ensure selection is set
    final oldIds = oldWidget.sectionIds;
    final newIds = widget.sectionIds;
    final listsChanged =
        oldIds.length != newIds.length ||
        (oldIds.isNotEmpty &&
            newIds.isNotEmpty &&
            oldIds.first != newIds.first);

    if (listsChanged) {
      if (newIds.isNotEmpty) {
        setState(() {
          if (widget.initialSectionId != null &&
              newIds.contains(widget.initialSectionId)) {
            _selectedSectionId = widget.initialSectionId;
          } else if (_selectedSectionId == null ||
              !newIds.contains(_selectedSectionId)) {
            _selectedSectionId = newIds.first;
          }
        });
      }
    }
  }

  /// Reset form to initial state
  void resetForm() {
    setState(() {
      _detailsController.clear();
      _pickedFiles.clear();
      _isSubmitting = false;
      _validationError = null;
      _acceptedConsent = false; // Reset consent
      if (widget.sectionIds.isNotEmpty) {
        if (widget.initialSectionId != null &&
            widget.sectionIds.contains(widget.initialSectionId)) {
          _selectedSectionId = widget.initialSectionId;
        } else {
          _selectedSectionId = widget.sectionIds.first;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'consultation_explain_title'.tr(),
                      style: TextStyle(
                        color: AppColors.brand600,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(height: 20.h),

            // Visual type selector showing API sections
            Text(
              'consultation_pick_type'.tr(),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            if (widget.sectionIds.isNotEmpty) _buildVisualTypeRow(context),

            SizedBox(height: 16.h),

            // Validation error message
            if (_validationError != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  _validationError!,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.redAccent, fontSize: 12.sp),
                ),
              ),

            SizedBox(height: 25.h),

            // Details label with star colored like title and adjacent to text
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'consultation_details_label'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.brand600,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 8.h),

            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 335.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      height: 218.h,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF262626).withOpacity(0.86),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFF2A2A2A),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _detailsController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              maxLength: _maxChars,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: 'consultation_details_hint'.tr(),
                                hintStyle: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14.sp,
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${_detailsController.text.length}/$_maxChars',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            Builder(
              builder: (_) {
                final t = 'consultation_attachment_optional'.tr();
                final s = t.indexOf('(');
                final e = t.indexOf(')', s + 1);
                if (s != -1 && e != -1 && e > s) {
                  final pre = t.substring(0, s);
                  final opt = t.substring(s, e + 1);
                  final post = t.substring(e + 1);
                  return Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: pre,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: opt,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (post.trim().isNotEmpty)
                          TextSpan(
                            text: post,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    textAlign: TextAlign.right,
                  );
                }
                return Text(
                  t,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            SizedBox(height: 8.h),
            CustomPaint(
              foregroundPainter: DashedRRectPainter(
                color: AppColors.brand600,
                strokeWidth: 1.5,
                radius: 16.r,
                dashWidth: 6,
                dashGap: 4,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: const Color(0xFF262626).withOpacity(0.86),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: GestureDetector(
                              onTap: () async {
                                final typeGroup = XTypeGroup(
                                  label: 'documents',
                                  extensions: [
                                    'pdf',
                                    'doc',
                                    'docx',
                                    'png',
                                    'jpg',
                                    'jpeg',
                                  ],
                                );
                                final file = await openFile(
                                  acceptedTypeGroups: [typeGroup],
                                );
                                if (file != null) {
                                  setState(() => _pickedFiles.add(file));
                                }
                              },
                              child: Container(
                                width: 48.w,
                                height: 48.w,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF262626,
                                  ).withOpacity(0.86),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.attach_file,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'consultation_attachment_hint'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (_pickedFiles.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    for (final f in _pickedFiles)
                      Chip(
                        label: Text(
                          f.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                        backgroundColor: Colors.white10,
                        deleteIconColor: Colors.white70,
                        onDeleted: () {
                          setState(() => _pickedFiles.remove(f));
                        },
                      ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 20.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptedConsent,
                  onChanged: (value) {
                    setState(() {
                      _acceptedConsent = value ?? false;
                      _validationError = null; // Clear validation errors
                    });
                  },
                  activeColor: AppColors.brand600,
                  side: BorderSide(color: AppColors.brand600, width: 1.5),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final t = 'consultation_confirmation'.tr();
                      final link = 'consultation_consent_link'.tr();
                      final i = t.indexOf(link);
                      if (i >= 0) {
                        final pre = t.substring(0, i);
                        final post = t.substring(i + link.length);
                        return Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: pre,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.sp,
                                ),
                              ),
                              TextSpan(
                                text: link,
                                style: TextStyle(
                                  color: AppColors.brand600,
                                  fontSize: 12.sp,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.brand600,
                                  decorationThickness: 1.5,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.consentForm,
                                    );
                                  },
                              ),
                              TextSpan(
                                text: post,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.right,
                        );
                      }
                      return Text(
                        t,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 15.h),

            AbsorbPointer(
              absorbing: _isSubmitting,
              child: Opacity(
                opacity: _isSubmitting ? 0.6 : 1.0,
                child: SharedUIWidgets.submitButton(onTap: _handleSubmit),
              ),
            ),

            if (_isSubmitting)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.brand600,
                    strokeWidth: 2,
                  ),
                ),
              ),

            // Add bottom padding for safe area
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  /// Handle form submission with validation
  void _handleSubmit() {
    print('🔵 SUBMIT BUTTON CLICKED!');

    if (widget.onSubmit == null) {
      print('❌ onSubmit is null!');
      return;
    }

    if (_isSubmitting) {
      print('⚠️ Already submitting, ignoring click');
      return;
    }

    setState(() {
      _validationError = null;
    });

    // Validate section selection
    final sectionId = _selectedSectionId;
    print('📋 Selected section ID: $sectionId');

    if (sectionId == null || sectionId.isEmpty) {
      print('❌ No section selected');
      setState(() {
        _validationError = 'consultation_error_no_section'.tr();
      });
      return;
    }

    // Validate content
    final content = _detailsController.text.trim();
    print('📝 Content length: ${content.length}');

    if (content.isEmpty) {
      print('❌ Content is empty');
      setState(() {
        _validationError = 'consultation_error_empty_content'.tr();
      });
      return;
    }

    if (content.length < 10) {
      print('❌ Content too short');
      setState(() {
        _validationError = 'consultation_error_short_content'.tr();
      });
      return;
    }

    // Validate consent acceptance
    if (!_acceptedConsent) {
      print('❌ Consent not accepted');
      setState(() {
        _validationError = 'consultation_error_no_consent'.tr();
      });
      return;
    }

    // Validate files (optional but check extension if present)
    print('📎 Number of files: ${_pickedFiles.length}');
    for (final file in _pickedFiles) {
      final ext = file.name.split('.').last.toLowerCase();
      final allowedExts = ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'];
      if (!allowedExts.contains(ext)) {
        print('❌ Invalid file type: $ext');
        setState(() {
          _validationError = 'consultation_error_invalid_file'.tr();
        });
        return;
      }
    }

    // All validation passed
    print('✅ All validation passed! Submitting...');
    print('   Section ID: $sectionId');
    print(
      '   Content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...',
    );
    print('   Files: ${_pickedFiles.map((f) => f.name).toList()}');

    setState(() {
      _isSubmitting = true;
    });

    widget.onSubmit!(
      sectionId: sectionId,
      content: content,
      files: List<XFile>.from(_pickedFiles),
    );

    // Reset submitting state after a delay (will be controlled by parent bloc)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    });
  }

  /// Visual type row - displays API sections
  Widget _buildVisualTypeRow(BuildContext context) {
    if (widget.sectionNames.isEmpty || widget.sectionIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(widget.sectionNames.length, (i) {
          final sectionId = widget.sectionIds[i];
          final sectionName = widget.sectionNames[i];
          final isSelected = sectionId == _selectedSectionId;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: GestureDetector(
              onTap: () {
                print('🎨 Section selected: $sectionName (ID: $sectionId)');
                setState(() => _selectedSectionId = sectionId);
              },
              child: SizedBox(
                width: 100.w,
                height: 38.h,
                child: isSelected
                    ? Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.voicePillGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(1.5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18.5.r),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: 12,
                                  sigmaY: 12,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF262626,
                                    ).withOpacity(0.86),
                                    borderRadius: BorderRadius.circular(18.5.r),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    sectionName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          sectionName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
