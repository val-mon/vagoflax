import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vagoflax/models/job.dart';

import 'package:vagoflax/views/about_us.dart';
import 'package:vagoflax/views/employer/add_job.dart';
import 'package:vagoflax/views/auth/auth_gate.dart';
import 'package:vagoflax/views/employer/job_applications.dart';
import 'package:vagoflax/views/job/details.dart';
import 'package:vagoflax/views/auth/login/login.dart';
import 'package:vagoflax/views/auth/signup/emailpw.dart';
import 'package:vagoflax/views/auth/signup/face_recognition.dart';
import 'package:vagoflax/views/auth/signup/type.dart';
import 'package:vagoflax/views/auth/signup/employer.dart';
import 'package:vagoflax/views/auth/signup/student.dart';
import 'package:vagoflax/views/profile.dart';
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
      path: '/signup/face',
      builder: (context, state) => const FaceRegistrationScreen(),
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
    GoRoute(
      path: '/profile/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return buildSlidePage(
          state: state,
          child: ProfileScreen(userId: id),
        );
      },
    ),
  ],
);
