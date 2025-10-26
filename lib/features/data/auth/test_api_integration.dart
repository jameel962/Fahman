// ملف اختبار بسيط للتأكد من تكامل API
// يمكن حذف هذا الملف بعد التأكد من عمل API

import 'package:fahman_app/features/data/auth/auth_service.dart';

class ApiIntegrationTest {
  static final AuthService _authService = AuthService();

  // اختبار تسجيل الدخول
  static Future<void> testLogin() async {
    print('🧪 اختبار تسجيل الدخول...');

    try {
      final result = await _authService.login(
        identifer: 'test_user',
        password: 'test_password',
        rememberMe: true,
      );

      if (result.success) {
        print('✅ تسجيل الدخول نجح');
        print('Token: ${result.token}');
      } else {
        print('❌ تسجيل الدخول فشل: ${result.message}');
      }
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');
    }
  }

  // اختبار التحقق من اسم المستخدم
  static Future<void> testValidateUsername() async {
    print('🧪 اختبار التحقق من اسم المستخدم...');

    try {
      final result = await _authService.validateUsername('test_user');
      print('✅ التحقق من اسم المستخدم: ${result.isValid}');
    } catch (e) {
      print('❌ خطأ في التحقق من اسم المستخدم: $e');
    }
  }

  // اختبار الحصول على معلومات المستخدم
  static Future<void> testGetUserInfo() async {
    print('🧪 اختبار الحصول على معلومات المستخدم...');

    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo != null) {
        print('✅ معلومات المستخدم: ${userInfo.username}');
      } else {
        print('❌ لم يتم العثور على معلومات المستخدم');
      }
    } catch (e) {
      print('❌ خطأ في الحصول على معلومات المستخدم: $e');
    }
  }

  // تشغيل جميع الاختبارات
  static Future<void> runAllTests() async {
    print('🚀 بدء اختبارات تكامل API...\n');

    await testLogin();
    print('');

    await testValidateUsername();
    print('');

    await testGetUserInfo();
    print('');

    print('🏁 انتهت الاختبارات');
  }
}

// مثال على الاستخدام:
// void main() async {
//   await ApiIntegrationTest.runAllTests();
// }
