import 'package:fahman_app/core/networking/api/api_consumer.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiConsumer apiConsumer;

  NotificationRepository({required this.apiConsumer});

  /// Get notifications with optional filters
  Future<NotificationListResponse> getNotifications({
    bool? isRead,
    String? notificationType,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      };

      if (isRead != null) {
        queryParams['IsRead'] = isRead;
      }

      if (notificationType != null && notificationType.isNotEmpty) {
        queryParams['NotificationType'] = notificationType;
      }

      final response = await apiConsumer.get(
        '/api/Notification',
        queryParameters: queryParams,
      );

      return NotificationListResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final response = await apiConsumer.get('/api/Notification/unread-count');
      final unreadResponse = UnreadCountResponse.fromJson(response);
      return unreadResponse.count;
    } catch (e) {
      rethrow;
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String id) async {
    try {
      await apiConsumer.put('/api/Notification/$id/mark-read');
    } catch (e) {
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await apiConsumer.put('/api/Notification/mark-all-read');
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String id) async {
    try {
      await apiConsumer.delete('/api/Notification/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await apiConsumer.delete('/api/Notification/clear-all');
    } catch (e) {
      rethrow;
    }
  }
}
