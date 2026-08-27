import 'package:flutter/material.dart';

import 'package:vagoflax/views/student_search.dart';
import 'package:vagoflax/views/student_applications.dart';

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

      // Index stack keeps the state (search, filters, scroll) of each page
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CrystalNavigationBar(
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.white70,
          // Translucent: the blurred content behind shows through (glass look)
          backgroundColor: Colors.black.withValues(alpha: 0.55),
          borderWidth: 1,
          outlineBorderColor: Colors.white24,
          // Items are laid out with spaceBetween, so a narrower bar brings the
          // two buttons closer to the center
          marginR: const EdgeInsets.symmetric(horizontal: 110, vertical: 20),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            /// Jobs
            CrystalNavigationBarItem(
              icon: Icons.work,
              unselectedIcon: Icons.work_outline,
              selectedColor: Colors.white,
            ),

            /// Applications
            CrystalNavigationBarItem(
              icon: Icons.assignment,
              unselectedIcon: Icons.assignment_outlined,
              selectedColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
