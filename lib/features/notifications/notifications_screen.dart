import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'data/repositories/notification_repository.dart';
import 'logic/notification_cubit.dart';
import 'logic/notification_state.dart';
import 'ui/widgets/notification_group_section.dart';
import 'ui/widgets/empty_notifications_widget.dart';
import 'data/models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize repository
    final dio = Dio();
    final apiConsumer = DioConsumer(dio: dio);
    final repository = NotificationRepository(apiConsumer: apiConsumer);

    return BlocProvider(
      create: (_) =>
          NotificationCubit(repository: repository)
            ..loadNotifications(refresh: true),
      child: const NotificationsScreenContent(),
    );
  }
}

class NotificationsScreenContent extends StatefulWidget {
  const NotificationsScreenContent({super.key});

  @override
  State<NotificationsScreenContent> createState() =>
      _NotificationsScreenContentState();
}

class _NotificationsScreenContentState
    extends State<NotificationsScreenContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<NotificationCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: _buildAppBar(context),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == NotificationStatus.loading &&
              state.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB4B2FF)),
            );
          }

          if (state.status == NotificationStatus.error &&
              state.notifications.isEmpty) {
            return _buildErrorState(context);
          }

          if (state.notifications.isEmpty) {
            return const EmptyNotificationsWidget();
          }

          return RefreshIndicator(
            onRefresh: () => context.read<NotificationCubit>().refresh(),
            color: const Color(0xFFB4B2FF),
            backgroundColor: const Color(0xFF2A2A2A),
            child: _buildNotificationsList(state),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      leading: IconButton(
        icon: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          return Text(
            'الإشعارات${state.unreadCount > 0 ? ' (${state.unreadCount})' : ''}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
      centerTitle: true,
      actions: [
        BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state.notifications.isEmpty) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white, size: 24.sp),
              color: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, color: Colors.white, size: 20.sp),
                      SizedBox(width: 12.w),
                      Text(
                        'تحديد الكل كمقروء',
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'حذف الكل',
                        style: TextStyle(color: Colors.red, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  context.read<NotificationCubit>().markAllAsRead();
                } else if (value == 'clear_all') {
                  _showClearAllConfirmation(context);
                }
              },
            );
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildNotificationsList(NotificationState state) {
    final groupedNotifications = _groupNotificationsByDate(state.notifications);

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(20.w),
      itemCount:
          groupedNotifications.length +
          (state.status == NotificationStatus.loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == groupedNotifications.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Color(0xFFB4B2FF)),
            ),
          );
        }

        final group = groupedNotifications[index];
        return NotificationGroupSection(
          title: group['title'] as String,
          notifications: group['notifications'] as List<NotificationModel>,
          onNotificationTap: (notification) {
            if (!notification.isRead) {
              context.read<NotificationCubit>().markAsRead(notification.id);
            }
          },
          onNotificationDismiss: (id) {
            context.read<NotificationCubit>().deleteNotification(id);
          },
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ في تحميل الإشعارات',
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<NotificationCubit>().refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB4B2FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('retry'.tr(), style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupNotificationsByDate(
    List<NotificationModel> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));
    final thisMonth = today.subtract(const Duration(days: 30));

    final todayNotifications = <NotificationModel>[];
    final yesterdayNotifications = <NotificationModel>[];
    final thisWeekNotifications = <NotificationModel>[];
    final thisMonthNotifications = <NotificationModel>[];
    final olderNotifications = <NotificationModel>[];

    for (final notification in notifications) {
      final notificationDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      if (notificationDate.isAtSameMomentAs(today)) {
        todayNotifications.add(notification);
      } else if (notificationDate.isAtSameMomentAs(yesterday)) {
        yesterdayNotifications.add(notification);
      } else if (notificationDate.isAfter(thisWeek)) {
        thisWeekNotifications.add(notification);
      } else if (notificationDate.isAfter(thisMonth)) {
        thisMonthNotifications.add(notification);
      } else {
        olderNotifications.add(notification);
      }
    }

    final groups = <Map<String, dynamic>>[];

    if (todayNotifications.isNotEmpty) {
      groups.add({'title': 'اليوم', 'notifications': todayNotifications});
    }
    if (yesterdayNotifications.isNotEmpty) {
      groups.add({'title': 'أمس', 'notifications': yesterdayNotifications});
    }
    if (thisWeekNotifications.isNotEmpty) {
      groups.add({
        'title': 'هذا الأسبوع',
        'notifications': thisWeekNotifications,
      });
    }
    if (thisMonthNotifications.isNotEmpty) {
      groups.add({
        'title': 'الشهر الماضي',
        'notifications': thisMonthNotifications,
      });
    }
    if (olderNotifications.isNotEmpty) {
      groups.add({'title': 'أقدم', 'notifications': olderNotifications});
    }

    return groups;
  }

  void _showClearAllConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'حذف جميع الإشعارات؟',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.right,
        ),
        content: Text(
          'هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<NotificationCubit>().clearAllNotifications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'حذف',
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
