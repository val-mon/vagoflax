enum UserRole {
  student,
  employer,
  admin,
  unknown;

  factory UserRole.fromFirestore(Object? value) {
    if (value is! String) {
      return UserRole.unknown;
    }

    final normalizedValue = value.trim().toLowerCase();

    return UserRole.values.firstWhere(
      (role) => role.name == normalizedValue,
      orElse: () => UserRole.unknown,
    );
  }

  String toFirestore() => name;
}
