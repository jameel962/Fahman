/// نموذج بيانات الأفاتار
class AvatarModel {
  final int id;
  final String path;
  final String name;
  final String category;

  const AvatarModel({
    required this.id,
    required this.path,
    required this.name,
    required this.category,
  });

  /// إنشاء نموذج من JSON
  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['id'] as int,
      path: json['path'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
    );
  }

  /// تحويل النموذج إلى JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'path': path, 'name': name, 'category': category};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvatarModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
