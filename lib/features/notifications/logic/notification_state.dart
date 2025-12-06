import '../data/models/notification_model.dart';

enum NotificationStatus { initial, loading, success, error, loadingMore }

class NotificationState {
  final NotificationStatus status;
  final List<NotificationModel> notifications;
  final String? errorMessage;
  final int unreadCount;
  final int currentPage;
  final bool hasMore;
  final bool isMarkingAllRead;
  final bool isClearingAll;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
    this.unreadCount = 0,
    this.currentPage = 1,
    this.hasMore = true,
    this.isMarkingAllRead = false,
    this.isClearingAll = false,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    String? errorMessage,
    int? unreadCount,
    int? currentPage,
    bool? hasMore,
    bool? isMarkingAllRead,
    bool? isClearingAll,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
      isClearingAll: isClearingAll ?? this.isClearingAll,
    );
  }
}
