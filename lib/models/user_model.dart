/// Représente un utilisateur retourné par l'API de profil.
class UserModel {
  final int id;
  final String username;
  final String email;
  final String? phone;
  final String? avatar;
  final String? role; // "parent" ou "teacher"

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.avatar,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final parsedId = idValue is int
        ? idValue
        : int.tryParse(idValue?.toString() ?? '') ?? 0;

    final username =
        json['username'] ??
        json['name'] ??
        json['full_name'] ??
        [json['first_name'], json['last_name']]
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .join(' ')
            .trim();

    return UserModel(
      id: parsedId,
      username: username?.toString() ?? 'Utilisateur',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['telephone']?.toString(),
      avatar: json['avatar']?.toString() ?? json['photo']?.toString(),
      role: json['role']?.toString(),
    );
  }

  bool get isTeacher => role == 'teacher';
  bool get isParent => role == 'parent';
}
