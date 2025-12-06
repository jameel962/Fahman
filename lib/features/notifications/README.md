# Notifications Feature

## Overview

A comprehensive notifications system for the Fahman App that supports real-time notifications, grouping by date, pagination, and various notification management actions.

## Features Implemented

### 1. **Notification Management**

- ✅ Fetch notifications with pagination
- ✅ Mark single notification as read
- ✅ Mark all notifications as read
- ✅ Delete single notification (swipe to dismiss)
- ✅ Clear all notifications
- ✅ Get unread notifications count
- ✅ Pull-to-refresh
- ✅ Infinite scroll for pagination

### 2. **UI Components**

- **NotificationsScreen**: Main screen with app bar and actions menu
- **NotificationGroupSection**: Groups notifications by date (Today, Yesterday, This Week, This Month, Older)
- **NotificationCard**: Individual notification card with dismissible functionality
- **EmptyNotificationsWidget**: Empty state when no notifications exist

### 3. **State Management**

- **NotificationCubit**: Manages notification state using BLoC pattern
- **NotificationState**: Handles loading, success, error states

### 4. **Data Layer**

- **NotificationRepository**: API calls for all notification endpoints
- **NotificationModel**: Data model with JSON serialization
- **NotificationListResponse**: Paginated response model
- **UnreadCountResponse**: Unread count response model

## API Endpoints Used

```dart
GET  /api/Notification                    // Get notifications with filters
GET  /api/Notification/unread-count       // Get unread count
PUT  /api/Notification/{id}/mark-read     // Mark as read
PUT  /api/Notification/mark-all-read      // Mark all as read
DELETE /api/Notification/{id}             // Delete notification
DELETE /api/Notification/clear-all        // Clear all notifications
```

## File Structure

```
lib/features/notifications/
├── data/
│   ├── models/
│   │   └── notification_model.dart       // Data models
│   └── repositories/
│       └── notification_repository.dart  // API repository
├── logic/
│   ├── notification_cubit.dart          // Business logic
│   └── notification_state.dart          // State definitions
├── ui/
│   └── widgets/
│       ├── notification_card.dart       // Single notification card
│       ├── notification_group_section.dart // Grouped notifications
│       └── empty_notifications_widget.dart // Empty state
└── notifications_screen.dart            // Main screen
```

## Usage

### Basic Implementation

```dart
// Navigate to notifications screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const NotificationsScreen(),
  ),
);
```

### With BLoC Provider (if already provided globally)

```dart
BlocProvider(
  create: (_) => NotificationCubit(repository: repository)
    ..loadNotifications(refresh: true),
  child: const NotificationsScreen(),
);
```

## Key Features Explained

### 1. Date Grouping

Notifications are automatically grouped into:

- **اليوم** (Today)
- **أمس** (Yesterday)
- **هذا الأسبوع** (This Week)
- **الشهر الماضي** (This Month)
- **أقدم** (Older)

### 2. Swipe to Delete

Users can swipe left on any notification to delete it.

### 3. Unread Count

The app bar shows the count of unread notifications in real-time.

### 4. Actions Menu

- **تحديد الكل كمقروء** (Mark all as read)
- **حذف الكل** (Clear all) - with confirmation dialog

### 5. Loading States

- Initial loading with centered spinner
- Load more with bottom spinner
- Pull-to-refresh support

### 6. Time Formatting

Arabic time formatting:

- الآن (Now)
- X دقيقة (X minutes)
- X ساعة (X hours)
- أمس (Yesterday)
- قبل X أسبوع (X weeks ago)
- قبل X شهر (X months ago)

## Platform Support

### Android

✅ Full FCM (Firebase Cloud Messaging) support
✅ Background notification handling
✅ Notification channel configuration

### iOS

✅ APNs (Apple Push Notification service) support
✅ Background notification handling
✅ Notification permissions

## FCM Integration Setup

### Android Configuration

1. Add `google-services.json` to `android/app/`
2. Update `android/build.gradle`:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

3. Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### iOS Configuration

1. Add `GoogleService-Info.plist` to `ios/Runner/`
2. Enable Push Notifications in Xcode capabilities
3. Configure APNs certificates in Firebase Console

### Flutter Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
```

## Customization

### Colors

```dart
const primaryColor = Color(0xFFB4B2FF);
const backgroundColor = Color(0xFF1A1A1A);
const cardColor = Color(0xFF2A2A2A);
```

### Pagination

Default page size is 20, can be modified in:

```dart
NotificationRepository.getNotifications(pageSize: 20)
```

## Error Handling

- Network errors display retry button
- API errors show snackbar messages
- Graceful handling of empty states

## Performance Optimizations

- Lazy loading with pagination
- Efficient grouping algorithm
- Dismissible widgets for smooth animations
- Cached network images

## Testing

Run the feature:

```bash
flutter run
```

Check for errors:

```bash
flutter analyze
```

## Future Enhancements

- [ ] Notification filtering by type
- [ ] Search functionality
- [ ] Notification preferences/settings
- [ ] Rich media notifications
- [ ] Action buttons in notifications
- [ ] Notification scheduling

## Notes

- All text is in Arabic (RTL support)
- Follows Material Design guidelines
- Uses BLoC pattern for state management
- Responsive design with flutter_screenutil
- Error states handled gracefully
