import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyNotificationsWidget extends StatelessWidget {
  const EmptyNotificationsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: const Color(0xFFB4B2FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/notifcation.png',
                width: 60.w,
                height: 60.h,
                color: const Color(0xFFB4B2FF),
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.notifications_none,
                    size: 60.sp,
                    color: const Color(0xFFB4B2FF),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'سيتم عرض الإشعارات الجديدة هنا',
            style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
