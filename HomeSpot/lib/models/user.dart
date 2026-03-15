class User {
  final int id;
  final String email;
  final String? displayName;
  final String role; // 'admin' | 'user'

  const User({
    required this.id,
    required this.email,
    this.displayName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      role: json['role'] as String,
    );
  }

  bool get isAdmin => role == 'admin';

  String get displayLabel {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    return email.split('@').first;
  }
}
