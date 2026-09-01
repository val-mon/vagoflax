import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/models/enum/user_role.dart';

void main() {
  final user = User(
    id: '1',
    canton: 'ZH',
    address: 'Zurich',
    description: 'Test user',
    email: 'test@example.com',
    profilePictureUrl: 'https://example.com/image.jpg',
    role: UserRole.student,
  );

  final mapUser = {
    'canton': 'ZH',
    'city': 'Zurich',
    'description': 'Test user',
    'email': 'test@example.com',
    'profilePictureUrl': 'https://example.com/image.jpg',
    'role': 'student',
  };
  test('toFirestore includes profilePictureUrl', () {
    expect(
      user.toFirestore()['profilePictureUrl'],
      'https://example.com/image.jpg',
    );
  });

  test('toFirestore includes canton', () {
    expect(user.toFirestore()['canton'], 'ZH');
  });

  test('toFirestore includes city', () {
    expect(user.toFirestore()['city'], 'Zurich');
  });

  test('toFirestore includes description', () {
    expect(user.toFirestore()['description'], 'Test user');
  });

  test('toFirestore includes email', () {
    expect(user.toFirestore()['email'], 'test@example.com');
  });

  test('toFirestore includes role', () {
    expect(user.toFirestore()['role'], 'student');
  });

  test('fromFirestore includes id', () {
    expect(User.fromFirestore(mapUser, '1').id, '1');
  });

  test('fromFirestore includes canton', () {
    expect(User.fromFirestore(mapUser, '1').canton, 'ZH');
  });

  test('fromFirestore includes city', () {
    expect(User.fromFirestore(mapUser, '1').address, 'Zurich');
  });

  test('fromFirestore includes description', () {
    expect(User.fromFirestore(mapUser, '1').description, 'Test user');
  });

  test('fromFirestore includes email', () {
    expect(User.fromFirestore(mapUser, '1').email, 'test@example.com');
  });

  test('fromFirestore includes role', () {
    expect(User.fromFirestore(mapUser, '1').role, UserRole.student);
  });
}
