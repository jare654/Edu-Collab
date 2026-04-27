enum Role { student, lecturer }

class User {
  final String id;
  final String name;
  final String email;
  final Role role;
  final String? avatar;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final roleValue = (json['role'] ?? 'student').toString();
    final role = roleValue == 'lecturer' ? Role.lecturer : Role.student;
    return User(
      id: json['id'].toString(),
      name: json['name'].toString(),
      email: json['email'].toString(),
      role: role,
      avatar: (json['avatar'] ?? json['avatar_url'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'avatar': avatar,
      };

  User copyWith({
    String? id,
    String? name,
    String? email,
    Role? role,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
    );
  }
}
