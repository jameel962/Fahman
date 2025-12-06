import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

Widget buildFieldLabel(String label) {
  return Text(
    // Accept either a translation key or already-localized text
    label.tr(),
    style: GoogleFonts.inter(
      color: Colors.white,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
    ),
    textAlign: TextAlign.right,
  );
}
