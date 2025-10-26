# دليل تكامل API للمصادقة

## نظرة عامة
تم ربط جميع endpoints الخاصة بالمصادقة مع API كما هو موضح في الصور المرفقة. تم تنفيذ البنية التالية:

## البنية المطبقة

### 1. النماذج (Models)
- `LoginRequest` - طلب تسجيل الدخول
- `RegisterCustomerRequest` - طلب تسجيل العميل
- `ChangePasswordRequest` - طلب تغيير كلمة المرور
- `OtpRequest` - طلب التحقق من OTP
- `ResendOtpRequest` - طلب إعادة إرسال OTP
- `PasswordResetRequest` - طلب إعادة تعيين كلمة المرور
- `PasswordResetVerifyRequest` - طلب التحقق من OTP لإعادة تعيين كلمة المرور
- `PasswordResetConfirmRequest` - طلب تأكيد إعادة تعيين كلمة المرور
- `UpdateUserInfoRequest` - طلب تحديث معلومات المستخدم
- `UserInfo` - معلومات المستخدم
- `AuthResult` - نتيجة العمليات
- `ValidateResponse` - استجابة التحقق
- `OtpResponse` - استجابة OTP

### 2. API Service
تم تنفيذ جميع endpoints التالية:

#### تسجيل الدخول
- **POST** `/Auth/login`
- **المعاملات**: `identifer`, `password`, `rememberMe`
- **الاستجابة**: `token`, `refreshToken`

#### تسجيل العميل
- **POST** `/Auth/register/customer`
- **المعاملات**: `Username`, `PhoneNumber`, `Email`, `Password`, `ConfirmPassword`, `personalImage`
- **النوع**: `multipart/form-data`

#### تسجيل الخروج
- **POST** `/Auth/logout/{refreshToken}`
- **المعاملات**: `refreshToken` (path parameter)

#### تغيير كلمة المرور
- **POST** `/Auth/change-password`
- **المعاملات**: `currentPassword`, `newPassword`, `confirmNewPassword`
- **النوع**: `application/json`

#### تحديث التوكن
- **POST** `/Auth/refresh-token/{refreshToken}`
- **المعاملات**: `refreshToken` (path parameter)

#### التحقق من صحة البيانات
- **GET** `/Auth/validate-username/{username}`
- **GET** `/Auth/validate-email/{email}`
- **GET** `/Auth/validate-phone/{phone}`

#### التحقق من OTP
- **POST** `/Auth/verfiyOtp`
- **المعاملات**: `otp`, `userId` (query parameters)

#### إعادة إرسال OTP
- **POST** `/Auth/reSendAuth-otp`
- **المعاملات**: `Identifier` (query parameter)

#### الحصول على معلومات المستخدم
- **GET** `/Auth/GetUserInfo`
- **لا يتطلب معاملات**

#### إعادة تعيين كلمة المرور
- **POST** `/Auth/password/send-otp`
- **POST** `/Auth/password/verify-otp`
- **POST** `/Auth/password/reset`

#### تحديث معلومات المستخدم
- **PUT** `/Auth/UpdateUserInfo`
- **المعاملات**: `UserName`, `ProfileImage`
- **النوع**: `multipart/form-data`

### 3. Repository Pattern
تم تنفيذ `AuthRepository` للتعامل مع:
- إدارة الجلسات
- معالجة الأخطاء
- تحويل البيانات

### 4. Provider Pattern
تم تنفيذ `AuthProvider` لإدارة:
- حالة المصادقة
- معلومات المستخدم
- حالات التحميل
- رسائل الخطأ

## كيفية الاستخدام

### 1. في الواجهات
```dart
// الحصول على AuthProvider
final authProvider = context.read<AuthProvider>();

// تسجيل الدخول
await authProvider.login(
  identifer: 'username_or_email',
  password: 'password',
  rememberMe: true,
);

// تسجيل الخروج
await authProvider.logout();

// تحديث معلومات المستخدم
await authProvider.updateUserInfo(
  userName: 'new_username',
  profileImageBytes: imageBytes,
  profileImageFilename: 'profile.jpg',
);
```

### 2. في الخدمات
```dart
// استخدام AuthService مباشرة
final authService = AuthService();

final result = await authService.login(
  identifer: 'username',
  password: 'password',
  rememberMe: true,
);
```

## الميزات المطبقة

### 1. إدارة الجلسات
- حفظ التوكنات في `AuthSession`
- تحديث التوكنات تلقائياً
- مسح الجلسة عند تسجيل الخروج

### 2. معالجة الأخطاء
- رسائل خطأ باللغة العربية
- معالجة أخطاء الشبكة
- معالجة أخطاء API

### 3. تحميل البيانات
- مؤشرات التحميل
- تحديث الواجهات تلقائياً
- إدارة حالات التحميل

### 4. التحقق من البيانات
- التحقق من صحة اسم المستخدم
- التحقق من صحة البريد الإلكتروني
- التحقق من صحة رقم الهاتف

## ملاحظات مهمة

1. **أخطاء الإملاء في API**: تم ملاحظة أن API يستخدم `identifer` بدلاً من `identifier`
2. **معاملات Query**: بعض endpoints تستخدم query parameters بدلاً من request body
3. **تنسيق البيانات**: بعض endpoints تستخدم `multipart/form-data` للصور
4. **إدارة التوكنات**: تم تنفيذ نظام تحديث التوكنات التلقائي

## الاختبار

لاختبار التكامل:
1. تأكد من أن API server يعمل
2. قم بتحديث `baseUrl` في `DioClient`
3. اختبر كل endpoint بشكل منفصل
4. تحقق من حفظ التوكنات في `AuthSession`

## الدعم

في حالة وجود مشاكل:
1. تحقق من رسائل الخطأ في `AuthProvider.errorMessage`
2. راجع logs في console
3. تأكد من صحة بيانات API
4. تحقق من اتصال الشبكة




