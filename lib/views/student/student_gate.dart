import 'package:flutter/material.dart';

import 'package:vagoflax/views/student/student_search.dart';
import 'package:vagoflax/views/student/student_applications.dart';

import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';

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
            final screenWidth = constraints.maxWidth;

            final barWidth = screenWidth < 600 ? 220.0 : 280.0;

            return Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: barWidth,
                height: 80,
                child: Transform.scale(
                  scaleY: 0.9,
                  alignment: Alignment.bottomCenter,
                  child: CrystalNavigationBar(
                    currentIndex: _selectedIndex,

                    unselectedItemColor: Colors.white70,

                    backgroundColor: Colors.black.withValues(alpha: 0.5),

                    borderWidth: 1.5,

                    outlineBorderColor: Colors.white.withValues(alpha: 0.8),

                    borderRadius: 32,

                    paddingR: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),

                    itemPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),

                    marginR: EdgeInsets.zero,

                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },

                    items: [
                      // jobs list
                      CrystalNavigationBarItem(
                        icon: Icons.work,
                        unselectedIcon: Icons.work_outline,
                        selectedColor: Colors.white,
                      ),

                      // applications list
                      CrystalNavigationBarItem(
                        icon: Icons.assignment,
                        unselectedIcon: Icons.assignment_outlined,
                        selectedColor: Colors.white,
                      ),
                    ],
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
