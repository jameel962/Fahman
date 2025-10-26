import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/shared/widgets/shared_ui_widgets.dart';
import 'package:fahman_app/shared/widgets/dashed_border_painter.dart';
import 'package:file_selector/file_selector.dart';

/// نموذج الاستشارة القانونية
class ConsultationForm extends StatefulWidget {
  final String consultationTypeKey;
  final ValueChanged<String>? onSubmit;
  const ConsultationForm({
    super.key,
    required this.consultationTypeKey,
    this.onSubmit,
  });

  @override
  State<ConsultationForm> createState() => _ConsultationFormState();
}

class _ConsultationFormState extends State<ConsultationForm> {
  final TextEditingController _detailsController = TextEditingController();
  int _maxChars = 100; // الحد الأقصى لعدد الأحرف
  late String _selectedType; // نوع الاستشارة المختار

  @override
  void initState() {
    super.initState();
    _selectedType = widget.consultationTypeKey;
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
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

          // Type selector
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
          _buildTypeRow(context),

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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${'consultation_attachment_optional'.tr()}: ${file.name}',
                                    ),
                                  ),
                                );
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

          SizedBox(height: 20.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: true,
                onChanged: (_) {},
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
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor: const Color(0xFF1E1E1E),
                                      title: Text(
                                        'consultation_consent_title'.tr(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      content: Text(
                                        'consultation_consent_body'.tr(),
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text(
                                            'common_close'.tr(),
                                            style: TextStyle(
                                              color: AppColors.brand600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    );
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 50.h),

          SharedUIWidgets.submitButton(
            onTap: () => widget.onSubmit?.call(_detailsController.text),
          ),
        ],
      ),
    );
  }

  /// بناء صف أنواع الاستشارات
  Widget _buildTypeRow(BuildContext context) {
    final keys = const [
      'consultation_type_legal',
      'consultation_type_tax',
      'consultation_type_insurance',
      'consultation_type_social',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: keys.map((key) {
          final isSelected = key == _selectedType;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = key),
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
                                    key.tr(),
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
                          key.tr(),
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
        }).toList(),
      ),
    );
  }
}
