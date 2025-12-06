import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;

  NotificationCubit({required this.repository})
    : super(const NotificationState());

  /// Load notifications
  Future<void> loadNotifications({
    bool refresh = false,
    bool? isRead,
    String? notificationType,
  }) async {
    try {
      if (refresh) {
        emit(
          state.copyWith(
            status: NotificationStatus.loading,
            currentPage: 1,
            hasMore: true,
          ),
        );
      } else if (state.currentPage > 1) {
        emit(state.copyWith(status: NotificationStatus.loadingMore));
      } else {
        emit(state.copyWith(status: NotificationStatus.loading));
      }

      final response = await repository.getNotifications(
        isRead: isRead,
        notificationType: notificationType,
        pageNumber: refresh ? 1 : state.currentPage,
        pageSize: 20,
      );

      final notifications = refresh
          ? response.items
          : [...state.notifications, ...response.items];

      emit(
        state.copyWith(
          status: NotificationStatus.success,
          notifications: notifications,
          hasMore: response.hasNext,
          currentPage: response.pageNumber,
          errorMessage: null,
        ),
      );

      // Also load unread count
      await loadUnreadCount();
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Load more notifications
  Future<void> loadMore() async {
    if (!state.hasMore || state.status == NotificationStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(currentPage: state.currentPage + 1));
    await loadNotifications();
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      final count = await repository.getUnreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (e) {
      // Don't emit error state, just log it
      print('Failed to load unread count: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      await repository.markAsRead(id);

      // Update the notification in the list
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == id) {
          return notification.copyWith(isRead: true, readAt: DateTime.now());
        }
        return notification;
      }).toList();

      emit(
        state.copyWith(
          notifications: updatedNotifications,
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to mark notification as read'));
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      emit(state.copyWith(isMarkingAllRead: true));
      await repository.markAllAsRead();

      // Update all notifications in the list
      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(isRead: true, readAt: DateTime.now());
      }).toList();

      emit(
        state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
          isMarkingAllRead: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to mark all as read',
          isMarkingAllRead: false,
        ),
      );
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String id) async {
    try {
      await repository.deleteNotification(id);

      // Remove notification from the list
      final notification = state.notifications.firstWhere(
        (n) => n.id == id,
        orElse: () => state.notifications.first,
      );

      final updatedNotifications = state.notifications
          .where((notification) => notification.id != id)
          .toList();

      emit(
        state.copyWith(
          notifications: updatedNotifications,
          unreadCount: !notification.isRead && state.unreadCount > 0
              ? state.unreadCount - 1
              : state.unreadCount,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete notification'));
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      emit(state.copyWith(isClearingAll: true));
      await repository.clearAllNotifications();

      emit(
        state.copyWith(notifications: [], unreadCount: 0, isClearingAll: false),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to clear all notifications',
          isClearingAll: false,
        ),
      );
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }
}
