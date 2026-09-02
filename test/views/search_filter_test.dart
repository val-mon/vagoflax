import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:vagoflax/widgets/search_filter.dart';

class FakeUserProvider extends ChangeNotifier implements UserProvider {
  @override
  User? currentUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget createTestWidget({required Widget child, UserProvider? userProvider}) {
  return ChangeNotifierProvider<UserProvider>.value(
    value: userProvider ?? FakeUserProvider(), // Pass a mock/dummy UserProvider
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('calls onSearch when the user types', (tester) async {
    String? query;

    await tester.pumpWidget(
      createTestWidget(
        child: SearchFilter(
          onSearch: (value) => query = value,
          onFilterTap: () {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'flutter');
    expect(query, 'flutter');
  });

  testWidgets('shows the active filter count badge', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        child: SearchFilter(
          onSearch: (_) {},
          onFilterTap: () {},
          activeFilterCount: 3,
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
  });
}
