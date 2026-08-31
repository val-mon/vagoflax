import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/widgets/search_filter.dart';

void main() {
  testWidgets('calls onSearch when the user types', (tester) async {
    String? query;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchFilter(
            onSearch: (value) => query = value,
            onFilterTap: () {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'flutter');

    expect(query, 'flutter');
  });

  testWidgets('shows the active filter count badge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchFilter(
            onSearch: (_) {},
            onFilterTap: () {},
            activeFilterCount: 3,
          ),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
  });
}
