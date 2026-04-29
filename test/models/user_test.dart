import 'package:flutter_test/flutter_test.dart';
import 'package:academic_collab_app/core/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User.fromJson should create a valid User object', () {
      final json = {
        'id': '123',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'student',
        'avatar': 'https://example.com/avatar.png',
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.role, Role.student);
      expect(user.avatar, 'https://example.com/avatar.png');
    });

    test('User.toJson should return a valid Map', () {
      const user = User(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        role: Role.lecturer,
        avatar: 'https://example.com/avatar.png',
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['role'], 'lecturer');
      expect(json['avatar'], 'https://example.com/avatar.png');
    });

    test('User.copyWith should return a new User with updated values', () {
      const user = User(
        id: '1',
        name: 'Original',
        email: 'original@example.com',
        role: Role.student,
      );

      final updatedUser = user.copyWith(name: 'Updated');

      expect(updatedUser.name, 'Updated');
      expect(updatedUser.id, '1');
      expect(updatedUser.email, 'original@example.com');
    });
  });
}
