import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/avatar_model.dart';

/// خدمة إدارة الأفاتارات
class AvatarService {
  static List<AvatarModel>? _cachedAvatars;

  /// جلب جميع الأفاتارات المتاحة
  static Future<List<AvatarModel>> getAvatars() async {
    if (_cachedAvatars != null) {
      return _cachedAvatars!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/avatars.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> avatarsJson = jsonData['avatars'] as List<dynamic>;

      _cachedAvatars = avatarsJson
          .map((json) => AvatarModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return _cachedAvatars!;
    } catch (e) {
      // في حالة الخطأ، إرجاع قائمة فارغة
      return [];
    }
  }

  /// جلب أفاتار محدد بالمعرف
  static Future<AvatarModel?> getAvatarById(int id) async {
    final avatars = await getAvatars();
    try {
      return avatars.firstWhere((avatar) => avatar.id == id);
    } catch (e) {
      return null;
    }
  }

  /// جلب أفاتارات حسب الفئة
  static Future<List<AvatarModel>> getAvatarsByCategory(String category) async {
    final avatars = await getAvatars();
    return avatars.where((avatar) => avatar.category == category).toList();
  }

  /// مسح التخزين المؤقت
  static void clearCache() {
    _cachedAvatars = null;
  }
}
