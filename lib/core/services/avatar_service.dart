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
      // Local avatars were removed from assets. Keep method safe by returning
      // an empty list instead of throwing when the JSON or asset files are
      // missing. The app should rely on remote avatar URLs from the API.
      return [];
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

  /// Resolve an avatar by its asset path (exact match on AvatarModel.path)
  static Future<AvatarModel?> getAvatarByPath(String path) async {
    final avatars = await getAvatars();
    try {
      return avatars.firstWhere((avatar) => avatar.path == path);
    } catch (e) {
      return null;
    }
  }

  /// مسح التخزين المؤقت
  static void clearCache() {
    _cachedAvatars = null;
  }
}
