/// نموذج بيانات الأفاتار
class AvatarModel {
  final int id;
  final String path;

  const AvatarModel({required this.id, required this.path});

  /// إنشاء نموذج من JSON
  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    final dynamicPath = json['path'] ?? json['avatarUrl'] ?? json['url'];
    return AvatarModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      path: dynamicPath?.toString() ?? '',
    );
  }

  /// تحويل النموذج إلى JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'path': path};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvatarModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
