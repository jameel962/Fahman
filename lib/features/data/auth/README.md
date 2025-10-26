# Auth API Integration

هذا المجلد يحتوي على جميع ملفات ربط الـ API للـ Authentication.

## البنية

```
lib/features/data/auth/
├── models/
│   └── auth_models.dart          # جميع الـ models للـ Auth API
├── datasources/
│   └── remote/
│       └── auth_api.dart         # API calls للـ Auth endpoints
├── repositories/
│   └── auth_repository.dart      # Repository pattern للـ Auth
├── auth_service.dart             # خدمة Auth الرئيسية
├── auth_exports.dart             # ملف exports لجميع ملفات Auth
└── README.md                     # هذا الملف
```

## الـ API Endpoints المدعومة

### Authentication
- `POST /Auth/login` - تسجيل الدخول
- `POST /Auth/logout/{refreshToken}` - تسجيل الخروج
- `POST /Auth/register/customer` - تسجيل عميل جديد
- `POST /Auth/change-password` - تغيير كلمة المرور
- `POST /Auth/refresh-token/{refreshToken}` - تحديث التوكن

### Validation
- `GET /Auth/validate-username/{username}` - التحقق من اسم المستخدم
- `GET /Auth/validate-email/{email}` - التحقق من البريد الإلكتروني
- `GET /Auth/validate-phone/{phone}` - التحقق من رقم الهاتف

### OTP
- `POST /Auth/verfiyOtp` - التحقق من رمز OTP
- `POST /Auth/reSendAuth-otp` - إعادة إرسال رمز OTP

### User Info
- `GET /Auth/GetUserInfo` - الحصول على معلومات المستخدم
- `PUT /Auth/UpdateUserInfo` - تحديث معلومات المستخدم

### Password Reset
- `POST /Auth/password/send-otp` - إرسال رمز OTP لإعادة تعيين كلمة المرور
- `POST /Auth/password/verify-otp` - التحقق من رمز OTP لإعادة تعيين كلمة المرور
- `POST /Auth/password/reset` - إعادة تعيين كلمة المرور

## الاستخدام

### 1. استخدام AuthService (الطريقة المفضلة)

```dart
import 'package:fahman_app/features/data/auth/auth_service.dart';

final authService = AuthService();

// تسجيل الدخول
final loginResult = await authService.login(
  identifier: 'user@example.com',
  password: 'password123',
  rememberMe: true,
);

// تسجيل جديد
final registerResult = await authService.registerCustomer(
  username: 'username',
  phoneNumber: '+962123456789',
  email: 'user@example.com',
  password: 'password123',
  confirmPassword: 'password123',
);

// تسجيل الخروج
final logoutResult = await authService.logout();
```

### 2. استخدام AuthRepository مباشرة

```dart
import 'package:fahman_app/features/data/auth/repositories/auth_repository.dart';
import 'package:fahman_app/features/data/auth/models/auth_models.dart';

final repository = AuthRepository();

final request = LoginRequest(
  identifier: 'user@example.com',
  password: 'password123',
  rememberMe: true,
);

final result = await repository.login(request);
```

### 3. استخدام AuthApi مباشرة

```dart
import 'package:fahman_app/features/data/auth/datasources/remote/auth_api.dart';
import 'package:fahman_app/features/data/auth/models/auth_models.dart';

final api = AuthApi();

final request = LoginRequest(
  identifier: 'user@example.com',
  password: 'password123',
  rememberMe: true,
);

final response = await api.login(request);
```

## الـ Models

### LoginRequest
```dart
LoginRequest({
  required String identifier,
  required String password,
  required bool rememberMe,
})
```

### RegisterCustomerRequest
```dart
RegisterCustomerRequest({
  required String username,
  required String phoneNumber,
  required String email,
  required String password,
  required String confirmPassword,
  List<int>? personalImageBytes,
  String? personalImageFilename,
})
```

### UserInfo
```dart
UserInfo({
  String? id,
  String? username,
  String? email,
  String? phoneNumber,
  String? firstName,
  String? lastName,
  String? profileImage,
  String? role,
})
```

## Error Handling

جميع الـ methods ترجع `AuthResult` أو `ValidateResponse` أو `OtpResponse` مع معلومات الخطأ:

```dart
final result = await authService.login(...);

if (result.token != null) {
  // نجح تسجيل الدخول
  print('Token: ${result.token}');
} else {
  // فشل تسجيل الدخول
  print('Error: ${result.error}');
}
```

## Base URL

الـ base URL محدد في `lib/core/network/dio_client.dart`:
```dart
baseUrl: 'http://fahmaan.runasp.net'
```

## Authentication Token

عند تسجيل الدخول بنجاح، يتم حفظ التوكن تلقائياً في `AuthSession` وإضافته إلى headers الـ API calls.

## Refresh Token

يتم دعم refresh token تلقائياً. عند انتهاء صلاحية التوكن، يمكن استخدام `authService.refreshToken()` لتحديثه.




