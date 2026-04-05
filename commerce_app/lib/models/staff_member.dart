class StaffMember {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String role;
  final String? merchantRole;
  final String? createdAt;

  StaffMember({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    required this.role,
    this.merchantRole,
    this.createdAt,
  });

  String get displayName {
    final name = [firstName, lastName].where((e) => (e ?? '').isNotEmpty).join(' ');
    return name.isNotEmpty ? name : (email ?? 'Utilisateur');
  }

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: (json['id'] as num).toInt(),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String? ?? 'MERCHANT',
      merchantRole: json['merchantRole'] as String?,
      createdAt: json['createdAt']?.toString(),
    );
  }
}

