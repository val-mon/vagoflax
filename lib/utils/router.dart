import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vagoflax/models/job_model.dart';

import 'package:vagoflax/views/about_screen.dart';
import 'package:vagoflax/views/add_job_screen.dart';
import 'package:vagoflax/views/auth_gate.dart';
import 'package:vagoflax/views/job_applications_screen.dart';
import 'package:vagoflax/views/job_details.dart';
import 'package:vagoflax/views/login_screen.dart';
import 'package:vagoflax/views/signup_1_emailpw_screen.dart';
import 'package:vagoflax/views/signup_2_type_screen.dart';
import 'package:vagoflax/views/signup_3_employer_screen.dart';
import 'package:vagoflax/views/signup_3_student_screen.dart';
import 'package:vagoflax/views/profile_screen.dart';
import 'package:vagoflax/widgets/profile_edit_form.dart';

CustomTransitionPage buildSlidePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child, // destination
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      );
    },
  );
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          buildSlidePage(state: state, child: const LoginScreen()),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) =>
          buildSlidePage(state: state, child: const SignUpEmailPwScreen()),
    ),
    GoRoute(
      path: '/signup/role',
      pageBuilder: (context, state) =>
          buildSlidePage(state: state, child: const SignUpTypeScreen()),
    ),
    GoRoute(
      path: '/signup/student',
      pageBuilder: (context, state) =>
          buildSlidePage(state: state, child: const SignUpStudentScreen()),
    ),
    GoRoute(
      path: '/signup/employer',
      pageBuilder: (context, state) =>
          buildSlidePage(state: state, child: const SignUpEmployerScreen()),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) =>
          buildSlidePage(state: state, child: const AboutScreen()),
    ),
    GoRoute(
      path: '/add-job',
      pageBuilder: (context, state) {
        final job = state.extra as Job?;
        return buildSlidePage(
          state: state,
          child: AddJobScreen(job: job),
        );
      },
    ),
    GoRoute(
      path: '/job-details',
      pageBuilder: (context, state) {
        final job = state.extra as Job?;
        return buildSlidePage(
          state: state,
          child: JobDetails(job: job),
        );
      },
    ),
    GoRoute(
      path: '/job-applications',
      pageBuilder: (context, state) {
        final job = state.extra as Job?;
        return buildSlidePage(
          state: state,
          child: JobApplicationsScreen(
            jobId: job?.id ?? '',
            jobTitle: job?.title ?? '',
          ),
        );
      },
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) =>
          buildSlidePage(state: state, child: const ProfileScreen()),
    ),
    GoRoute(
      path: '/profile/edit',
      pageBuilder: (context, state) =>
          buildSlidePage(state: state, child: const ProfileEditForm()),
    ),
  ],
);
