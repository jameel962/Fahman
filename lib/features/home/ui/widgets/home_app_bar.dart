import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/features/notifications/logic/notification_cubit.dart';
import 'package:fahman_app/features/notifications/logic/notification_state.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load unread count when app bar is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().loadUnreadCount();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload unread count when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationCubit>().loadUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64.h,
      titleSpacing: 0,
      title: Row(
        children: [
          SizedBox(width: 16.w),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Text(
              'app_title'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      actions: [
        BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, notificationState) {
            final unreadCount = notificationState.unreadCount;

            return Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.notifications);
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8.w,
                    top: 8.h,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18.r,
                        minHeight: 18.r,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        SizedBox(width: 8.w),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.profile);
          },
        ),
        SizedBox(width: 12.w),
      ],
    );
  }
}
