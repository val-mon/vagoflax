import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vagoflax/models/job.dart';
import 'package:vagoflax/models/job_filters.dart';
import 'package:vagoflax/models/enum/role.dart';
import 'package:vagoflax/models/enum/industry.dart';
import 'package:vagoflax/widgets/job/filter_drawer.dart';

Job _job() => Job(
  id: '1',
  userUuid: 'owner',
  title: 'Dev',
  description: '',
  diplomas: const [],
  role: Role.intern,
  industry: Industry.informationTechnology,
  perks: const [],
  languages: const [],
  visible: true,
  translations: const [],
);

void main() {
  testWidgets('renders a chip for the role present in jobs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobFilterDrawer(
            jobs: [_job()],
            initialFilters: const JobFilters(),
            onApply: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Roles'), findsOneWidget);
    await tester.tap(find.text('Roles'));
    await tester.pumpAndSettle();
    expect(find.text('Intern'), findsOneWidget);
  });

  testWidgets('calls onApply when Apply filters is tapped', (tester) async {
    var applied = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobFilterDrawer(
            jobs: [_job()],
            initialFilters: const JobFilters(),
            onApply: (_) => applied = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Apply filters'));
    await tester.pump();

    expect(applied, isTrue);
  });
}
