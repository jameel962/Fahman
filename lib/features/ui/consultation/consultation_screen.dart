import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/features/ui/consultation/consultation_form.dart';

class ConsultationScreen extends StatelessWidget {
  final String initialTypeKey;
  const ConsultationScreen({super.key, this.initialTypeKey = 'consultation_type_legal'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 64.h,
        title: Row(children: [
          SizedBox(width: 16.w),
          Text('feature_consultations_title'.tr(), style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w700)),
        ]),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: ConsultationForm(
            consultationTypeKey: initialTypeKey,
            onSubmit: (details) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('coming_soon'.tr())),
              );
            },
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}