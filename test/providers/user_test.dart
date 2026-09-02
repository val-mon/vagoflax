import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/models/enum/user_role.dart';
import 'package:vagoflax/providers/user.dart';

import '../fakes/user.dart';

User _user(String id) => User(
  id: id,
  email: '$id@test.ch',
  role: UserRole.student,
  profilePictureUrl: '',
  createdAt: DateTime(2026, 1, 1),
  canton: 'VS',
  address: 'Sion',
  description: '',
);

void main() {
  late FakeUserRepository repository;
  late UserProvider provider;

  setUp(() {
    repository = FakeUserRepository();
    provider = UserProvider(repository);
  });

  test('reflects users emitted by the repository', () async {
    repository.emit([_user('a'), _user('b')]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.users.map((u) => u.id), ['a', 'b']);
    expect(provider.isLoading, isFalse);
  });

  test('addUser sets currentUser', () async {
    await provider.addUser(_user('new'));

    expect(provider.currentUser?.id, 'new');
    expect(repository.added?.id, 'new');
  });

  test('getUserFromId returns null when not found', () async {
    repository.emit([_user('a')]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.getUserFromId('zzz'), isNull);
  });

  test('clearUser resets currentUser', () async {
    await provider.addUser(_user('x'));
    provider.clearUser();

    expect(provider.currentUser, isNull);
  });
}
