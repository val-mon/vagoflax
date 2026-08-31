import 'package:flutter/material.dart';

import 'package:vagoflax/views/student/search.dart';
import 'package:vagoflax/views/student/applications.dart';

class StudentGate extends StatefulWidget {
  const StudentGate({super.key});

  @override
  State<StudentGate> createState() => _StudentGateState();
}

class _StudentGateState extends State<StudentGate> {
  int _selectedIndex = 0;

  static const _pages = [JobListScreen(), StudentApplicationsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final barWidth = isTablet
                ? 320.0
                : constraints.maxWidth -
                      32; // marge 16 de chaque côté sur phone

            return Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              child: SizedBox(
                width: barWidth,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: NavigationBarTheme(
                    data: NavigationBarThemeData(
                      labelTextStyle: WidgetStateProperty.resolveWith((states) {
                        final selected = states.contains(WidgetState.selected);
                        return TextStyle(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        );
                      }),
                      iconTheme: WidgetStateProperty.resolveWith((states) {
                        final selected = states.contains(WidgetState.selected);
                        return IconThemeData(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        );
                      }),
                    ),
                    child: NavigationBar(
                      height: 56,
                      backgroundColor: Colors.white,
                      elevation: 4,
                      indicatorColor: Colors.transparent,
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysShow,
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) =>
                          setState(() => _selectedIndex = index),
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.work_outline),
                          selectedIcon: Icon(Icons.work),
                          label: 'Jobs',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.assignment_outlined),
                          selectedIcon: Icon(Icons.assignment),
                          label: 'Applications',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
