import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theming/colors_manager.dart';

class ConsultationForm extends StatefulWidget {
  final String consultationTypeKey;
  final ValueChanged<String>? onSubmit;
  const ConsultationForm({super.key, required this.consultationTypeKey, this.onSubmit});

  @override
  State<ConsultationForm> createState() => _ConsultationFormState();
}

class _ConsultationFormState extends State<ConsultationForm> {
  final TextEditingController _detailsController = TextEditingController();
  int _maxChars = 100;
  late String _selectedType;

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
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
            child: Text('consultation_explain_title'.tr(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700)),
          ),
          SizedBox(height: 8.h),

          // Type selector
          Text('consultation_pick_type'.tr(), textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          _buildTypeRow(context),

          SizedBox(height: 16.h),

          // Details label
          Row(children: [
            Expanded(child: Text('consultation_details_label'.tr(), textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600))),
            Text('*', style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
          ]),
          SizedBox(height: 8.h),

          // Details input
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.white.withOpacity(0.2))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextField(
                controller: _detailsController,
                maxLines: 5,
                maxLength: _maxChars,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(counterText: '', hintText: 'consultation_details_hint'.tr(), hintStyle: TextStyle(color: Colors.white60, fontSize: 14.sp), border: InputBorder.none),
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('${_detailsController.text.length}/$_maxChars', style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
              ),
            ]),
          ),

          SizedBox(height: 16.h),

          // Attachment
          Text('consultation_attachment_optional'.tr(), textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.white.withOpacity(0.6), width: 1), color: Colors.white.withOpacity(0.06)),
            child: Column(children: [
              const Icon(Icons.attach_file, color: Colors.white70),
              SizedBox(height: 8.h),
              Text('consultation_attachment_hint'.tr(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
            ]),
          ),

          SizedBox(height: 16.h),

          // Confirmation
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Checkbox(value: true, onChanged: (_) {}, activeColor: AppColors.brand600, side: BorderSide(color: Colors.white.withOpacity(0.6))),
            Expanded(child: Text('consultation_confirmation'.tr(), textAlign: TextAlign.right, style: TextStyle(color: Colors.white70, fontSize: 12.sp))),
          ]),

          SizedBox(height: 12.h),

          // Submit
          GestureDetector(
            onTap: () => widget.onSubmit?.call(_detailsController.text),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.voicePillGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: Offset(0, 6.h))],
              ),
              child: Text('consultation_submit'.tr(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeRow(BuildContext context) {
    final keys = const [
      'consultation_type_legal',
      'consultation_type_tax',
      'consultation_type_insurance',
      'consultation_type_social',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) {
        final isSelected = key == _selectedType;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = key),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withOpacity(isSelected ? 0.8 : 0.2), width: 1),
                ),
                child: Text(key.tr(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}