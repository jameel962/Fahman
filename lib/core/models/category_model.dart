class CategoryModel {
  final int id;
  final String name;
  final String nameAr;
  final int articleCount;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.articleCount,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      nameAr: json['name_Ar'] as String? ?? '',
      articleCount: json['articleCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_Ar': nameAr,
      'articleCount': articleCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
