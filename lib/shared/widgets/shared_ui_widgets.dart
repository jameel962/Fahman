import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';

/// Shared UI widgets for consistent design across the app
class SharedUIWidgets {
  /// Custom Text Field with consistent styling
  static Widget customTextField({
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int? maxLines,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function()? onTap,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines ?? 1,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  /// Custom Button with gradient background
  static Widget customButton({
    required String text,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
    TextStyle? textStyle,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        padding: padding ?? EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.brand600,
          gradient: backgroundColor == null
              ? LinearGradient(
                  colors: [AppColors.brand600, AppColors.brand700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          boxShadow:
              boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: Offset(0, 4.h),
                ),
              ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? Colors.white,
                    ),
                  ),
                ),
              )
            : Text(
                text,
                textAlign: TextAlign.center,
                style:
                    textStyle ??
                    TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
              ),
      ),
    );
  }

  /// Custom Card with consistent styling
  static Widget customCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) {
    return Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        border:
            border ??
            Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2.h),
              ),
            ],
      ),
      child: child,
    );
  }

  /// Custom Icon Button
  static Widget customIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
    double? size,
    double? padding,
    double? borderRadius,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding ?? 12.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: size ?? 20.sp,
        ),
      ),
    );
  }

  /// Custom Avatar Widget
  static Widget customAvatar({
    required String imagePath,
    double? size,
    double? borderRadius,
    Widget? child,
  }) {
    return Container(
      width: size ?? 50.w,
      height: size ?? 50.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 25.r),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: child,
    );
  }

  /// Custom Loading Indicator
  static Widget customLoadingIndicator({
    Color? color,
    double? size,
    String? text,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 30.w,
            height: size ?? 30.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.brand600,
              ),
            ),
          ),
          if (text != null) ...[
            SizedBox(height: 16.h),
            Text(
              text,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Custom Divider
  static Widget customDivider({
    Color? color,
    double? height,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: 16.h),
      height: height ?? 1.h,
      color: color ?? Colors.white.withOpacity(0.1),
    );
  }

  /// Custom Section Header
  static Widget sectionHeader({
    required String title,
    String? subtitle,
    Widget? action,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  /// زر النشر للمقالات
  static Widget publishButton({required VoidCallback onTap, String? text}) {
    return customButton(text: text ?? 'publish'.tr(), onTap: onTap);
  }

  /// زر الإرسال للاستشارات
  static Widget submitButton({required VoidCallback onTap, String? text}) {
    return customButton(text: text ?? 'consultation_submit'.tr(), onTap: onTap);
  }
}
