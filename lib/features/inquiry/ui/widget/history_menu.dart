import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/features/inquiry/logic/inquiry_cubit.dart';

class HistoryMenu {
  static void show(BuildContext context, InquiryCubit cubit) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(color: Colors.black.withOpacity(0.2)),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A).withOpacity(0.95),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.r),
                      bottomRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Expanded(child: _HistoryList(cubit: cubit)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryList extends StatelessWidget {
  final InquiryCubit cubit;

  const _HistoryList({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final groupedItems = _getGroupedHistoryItems(cubit);

    if (groupedItems.isEmpty) {
      return Center(
        child: Text(
          'no_history_available'.tr(),
          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final group = groupedItems[index];
        return _HistoryGroup(group: group, cubit: cubit);
      },
    );
  }

  List<Map<String, dynamic>> _getGroupedHistoryItems(InquiryCubit cubit) {
    final conversations = cubit.state.conversations;
    if (conversations.isEmpty) return [];

    final items = conversations.map((c) {
      final time = c.lastMessageAt ?? c.createdAt;
      return {
        'conversationId': c.conversationId,
        'title':
            c.title ??
            (c.messages.isNotEmpty
                ? c.messages.first.content
                : 'inquiry_conversation'.tr()),
        'subtitle': c.language ?? '',
        'time': time != null ? DateFormat('yyyy-MM-dd HH:mm').format(time) : '',
        'type': 'legal',
      };
    }).toList();

    return [
      {'groupTitle': 'inquiry_history'.tr(), 'items': items},
    ];
  }
}

class _HistoryGroup extends StatelessWidget {
  final Map<String, dynamic> group;
  final InquiryCubit cubit;

  const _HistoryGroup({required this.group, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final items =
        group['items'] as List<Map<String, dynamic>>? ??
        <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
          child: Text(
            group['groupTitle']?.toString() ?? '',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...items.map((item) => _HistoryItem(item: item, cubit: cubit)).toList(),
        SizedBox(height: 16.h),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final InquiryCubit cubit;

  const _HistoryItem({required this.item, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final type = item['type']?.toString() ?? 'legal';
    final title = item['title']?.toString() ?? '';
    final subtitle = item['subtitle']?.toString() ?? '';
    final conversationId = item['conversationId']?.toString();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: InkWell(
            onTap: () {
              if (conversationId != null && conversationId.isNotEmpty) {
                // Close the history menu
                Navigator.of(context).pop();
                // Open the selected conversation
                cubit.openConversation(conversationId);
              }
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: type == 'criminal'
                          ? Colors.red.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      type == 'criminal' ? Icons.gavel : Icons.business,
                      color: type == 'criminal' ? Colors.red : Colors.blue,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['time'],
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[500],
                        size: 16.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
