import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vagoflax/providers/app_state.dart';
import 'package:vagoflax/views/auth_gate.dart';
import 'package:vagoflax/views/login_screen.dart';
import 'package:vagoflax/views/signup_1_emailpw_screen.dart';
import 'package:vagoflax/views/signup_2_type_screen.dart';
import 'package:vagoflax/views/signup_3_employer_screen.dart';
import 'package:vagoflax/views/signup_3_student_screen.dart';
import 'package:vagoflax/views/signup_end_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'utils/theme.dart';

import 'package:provider/provider.dart';

import 'providers/job_provider.dart';
import 'repositories/firestore_job_repository.dart';
import 'utils/firebase_options.dart';

import 'package:go_router/go_router.dart';

import 'views/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

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

final _router = GoRouter(
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
      path: '/signup/2',
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
      path: '/signup/finish',
      pageBuilder: (context, state) =>
          buildSlidePage(state: state, child: const SignUpEndScreen()),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) =>
          buildSlidePage(state: state, child: const AboutScreen()),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApplicationState()),
        ChangeNotifierProvider(
          create: (_) => JobProvider(FirestoreJobRepository()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Vagoflax',
        theme: buildThemeData(),
        routerConfig: _router,
      ),
    );
  }
}
