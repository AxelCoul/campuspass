class User {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role;
  final String? merchantRole;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
    this.merchantRole,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      role: json['role'] as String? ?? 'MERCHANT',
      merchantRole: json['merchantRole'] as String?,
    );
  }
}
