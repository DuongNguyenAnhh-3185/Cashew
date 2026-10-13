/// Entity đại diện cho người dùng ứng dụng
class AppUserEntity {
  final String id; // Firebase UID
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;

  const AppUserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
  });

  AppUserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return AppUserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUserEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
