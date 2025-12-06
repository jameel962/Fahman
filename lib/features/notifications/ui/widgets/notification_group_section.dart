import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/notification_model.dart';

class NotificationGroupSection extends StatelessWidget {
  final String title;
  final List<NotificationModel> notifications;
  final Function(NotificationModel) onNotificationTap;
  final Function(String) onNotificationDismiss;

  const NotificationGroupSection({
    Key? key,
    required this.title,
    required this.notifications,
    required this.onNotificationTap,
    required this.onNotificationDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h, top: 16.h, right: 4.w),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        ...notifications.map((notification) {
          return _buildNotificationItem(notification);
        }).toList(),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onNotificationDismiss(notification.id),
      background: _buildDismissBackground(),
      child: GestureDetector(
        onTap: () => onNotificationTap(notification),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: notification.isRead
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFB4B2FF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.r),
            border: notification.isRead
                ? Border.all(color: Colors.grey.withOpacity(0.2), width: 1)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: notification.isRead
                                  ? Colors.grey[400]
                                  : const Color(0xFFB4B2FF),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13.sp,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              _buildIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFB4B2FF).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/notifcation.png',
          width: 28.w,
          height: 28.h,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.notifications,
              color: const Color(0xFFB4B2FF),
              size: 24.sp,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.delete_outline, color: Colors.white, size: 24.sp),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} يوم';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'قبل $weeks ${weeks == 1 ? 'أسبوع' : 'أسابيع'}';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'قبل $months ${months == 1 ? 'شهر' : 'شهور'}';
    }
  }
}
