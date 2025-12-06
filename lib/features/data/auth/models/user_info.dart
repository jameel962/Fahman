class UserInfo {
  final String? id;
  final String? username;
  final String? email;
  final String? profileImage;

  UserInfo({this.id, this.username, this.email, this.profileImage});

  factory UserInfo.fromMap(Map<String, dynamic> m) {
    // The API returns keys like: id, username, email, imageUrl or avatar
    final image = (m['imageUrl'] ?? m['image'] ?? m['avatar'])?.toString();
    return UserInfo(
      id: m['id']?.toString(),
      username:
          m['username']?.toString() ??
          m['userName']?.toString() ??
          m['name']?.toString(),
      email: m['email']?.toString(),
      profileImage: (image != null && image.isNotEmpty) ? image : null,
    );
  }
}
